# ADR-005 — Week-3 Diagnostic acceleration (Bullhorn MCP deferred)

**Status:** Accepted (2026-05-24, Day 13)
**Author:** Founder (Maddox) + Claude Code
**Companion:** `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)
**Supersedes:** N/A
**Ratifies via:** `review-architecture-decision.md` Codex skill (next round)

---

## Context

ULTRAPLAN.md §8.1 specifies the v1.0 build sequence:

| Week | Master plan calls for |
|---|---|
| 1-2 | Renderer + `_shared/` + voice corpus + schema v0.2 |
| 3 | **Bullhorn MCP server build** (auth, read endpoints, write endpoints, webhook subscription) per ULTRAPLAN line 752 |
| 4 | **Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint** per ULTRAPLAN line 753 |
| 5 | Janitor (Bullhorn R+W) |
| 6 | Scribe |
| 7-8 | Cash Conductor |
| 9 | Sourcing Scout |
| 10-13 | Concierge |

As of Day 13 (end of Week 2):

- **Week 1-2 work landed early** (Day 8, commits a279226 → fe56e93). Renderer + `_shared/` + v0.2 schema + voice corpus all live + ratified.
- **Bullhorn Sub-decisions A + B remain Proposed.** Founder submitted Bullhorn partnerships form 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (commit `dc15692`); response expected 2-5 business days.
- **Without Sub-decision A answered, Week-3 Bullhorn-MCP work is structurally blocked:** we don't know whether marketplace registration is required for production OR whether direct-tier developer-program access suffices.
- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."

## Decision

**Week 3 (Days 13-20) is repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build. Week 4 (Days 21-27) is repurposed from Diagnostic-build to Diagnostic-polish + first-pilot-prep + (conditional) Bullhorn-MCP-build if A+B answered.**

Concretely:

| Original plan | Day-13 revision |
|---|---|
| W3 Days 13-20: Bullhorn MCP server build | W3 Days 13-20: Diagnostic end-to-end (per `goal-option-c-diagnostic-end-to-end.md`) |
| W4 Days 21-27: Diagnostic end-to-end | W4 Days 21-27: Diagnostic polish + first-pilot prep + Bullhorn MCP if A+B answered |
| W5 Day 28+: Janitor build start | W5 Day 28+: **Conditional on Bullhorn Sub-decisions A+B Accepted** |

## Rationale

1. **Diagnostic is the named first agent.** `sequencing-target.md` §3.1 ratified Build Wave 1 = Diagnostic. Doing it earlier doesn't violate the sequence — it accelerates it.
2. **The Week-4 milestone is achievable today.** ULTRAPLAN line 755: *"Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."* Option C produces exactly this; the dependencies (LinkedIn + Companies House + scrape) are independent of Bullhorn.
3. **Week-3 time is otherwise idle.** Bullhorn MCP build cannot proceed without commercial answer. Spending Week 3 on Diagnostic uses that time productively.
4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
5. **Buffer on kill-criterion Trigger 2.** `v1.0-kill-criterion.md` Trigger 2 fires 2026-06-14 if Diagnostic doesn't render cleanly. Today is 2026-05-24 — 21 days of buffer. Building now beats the deadline by 3 weeks.
6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.

## Consequences

### Immediate (Days 13-20)

- ✅ Web scraper + Companies House MCP connector + diagnostic-generator package shipped Day 13 (commits `800a265`, `860f29c`, `5614dcb`, `fd38254`)
- ✅ Real end-to-end pipeline verified Day 13 (Gate A PASS on fake-firm smoke test)
- ⏸ Step 7 (real-firm smoke run against founder's choice) pending: Companies House API key registration + firm name
- ⏸ Iteration on Diagnostic output quality across 10-20 real UK firms

### Week 5 (Day 28+) — Janitor build conditional gating

| Bullhorn A+B state by Day 28 | Janitor action |
|---|---|
| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
| Bullhorn unresponsive past 2026-06-10 | Force Direct-API fallback per `bullhorn-integration-path.md` §1.4; Janitor scaffold begins; Bullhorn auth gated on first pilot raising support ticket |

### Downstream sequencing (Weeks 6+)

- Scribe (W6) depends on Bullhorn write; same gating as Janitor
- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
- Sourcing Scout (W9) touches Bullhorn read; same gating
- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision

**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.

### What does NOT change

- Master brief five rules + four boundaries (no architectural deviation)
- Schema v0.2 + tenancy invariants (verified Day 12; foundation stable)
- Codex ratification loop (continues per existing manifest)
- Q1 LOI gate (Jack's lane; Trigger 1 fires 2026-06-03 if no LOI)
- Founder commercial workstream (Bullhorn + SeedLegals + Q1)

## Implementation receipts

| Step | Status | Commit |
|---|---|---|
| Scaffold web-scraper + companies-house packages | ✅ | `800a265` |
| Web-scraper implementation + 12/12 tests | ✅ | `860f29c` |
| Companies House connector + 13/13 tests | ✅ | `5614dcb` |
| diagnostic-generator package + cycle.sh wiring | ✅ | `fd38254` |
| ADR-005 (this document) | ✅ | (this commit) |
| State files sync | ✅ | (this commit / next) |
| Companies House API key registration | ⏸ Founder | — |
| Smoke run against real UK firm | ⏸ Step 7 | — |
| Codex ratification of bundle | ⏸ W4 | — |

## Master plan citation chain

- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
- ULTRAPLAN §8.1 line 753-755 (Week-4 milestone definition)
- ULTRAPLAN §10 Risk #2 row contingency (defer Bullhorn-touching agents)
- `sequencing-target.md` §3.1 (Build Wave 1 = Diagnostic)
- `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render by 2026-06-14)
- `bullhorn-integration-path.md` §1.4 (Direct-API fallback architecture for slow Bullhorn response)
- `docs/operations/goal-option-c-diagnostic-end-to-end.md` (Day-13 execution prompt)

## Open questions

| Q | Resolution path |
|---|---|
| When does Bullhorn respond? | 2-5 business days from submission (sent 2026-05-24); hard cutoff 2026-06-10 per §1.4 fallback |
| Does the Diagnostic v0 produce reports good enough to send Jack for Q1 pitch? | Iteration loop in W3 polish (Step 7 + follow-ups). Quality gate: founder approval after running against 5-10 real firms. |
| LinkedIn deep data via Proxycurl: now or W4? | Day-13 founder pick: Option A (free unauthenticated path) for v0; Proxycurl evaluated W4 polish |
| Does this break the master plan's "do not build out of order" rule? | No: ordering of agents (Diagnostic first) is preserved; only the substrate-vs-agent ordering within Weeks 3-4 is swapped, which §1.4 fallback architecture explicitly anticipates |

*End of ADR-005.*
