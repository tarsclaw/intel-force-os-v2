# Codex disagreement — bullhorn-integration-path Week-1 implementation gate

**Date:** 2026-05-20 (Day 8, Codex Round 1 incorporation)
**Artefact disagreed on:** `docs/decisions/bullhorn-integration-path.md`
**Codex output:** `logs/codex-ratification/manual-run/docs_decisions_bullhorn_integration_path_md.output.md` issue 2
**Skill applied:** `.codex/ratification/review-architecture-decision.md`
**Codex outcome:** REJECTED
**Round trip:** 1

---

## §1 — Codex's numbered issue (verbatim)

> The document claims Week-1 implementation can proceed before the auth path is cleared. Lines 57-72 list commercial blockers for Sub-decisions A/B, but line 95 says those can remain Proposed without blocking Week-1 implementation. That weakens the Day-7 auth-path quality gate. Fix by making Bullhorn connector scaffolding explicitly conditional on A/B resolution or by narrowing Week-1 work to non-auth code only.

---

## §2 — Claude's response

**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.

The Week-1 prereq code IS the slice that already shipped:

- `packages/agent-renderer/` (Phase 2, commit `3c16d35`)
- `agents/_shared/hook-helpers.sh` + `autosend-policy.yaml` (Phase 3, commit `e6e9df1`)
- `vertical-schema.v0.2-supplement.yaml` (Phase 4, commit `45b59e0`)
- `agents/_shared/voice-loader.sh` (Phase 5, commit `fe56e93`)

**None of these reference Bullhorn at all.** They are tenant-agnostic + adapter-agnostic substrate. Sub-decisions A+B remaining Proposed (commercial questions about marketplace partnership + dev tenant access) does not block these.

Specifically: per `sequencing-target.md` §2.1 line 96, Diagnostic (the first agent build, W3-4) is explicitly "no Bullhorn; Tier 2 (request-driven, no persistent PTY)." Per ULTRAPLAN §8.1 A1, Diagnostic's MCP tools are "Companies House, LinkedIn (read-only), web scraper for careers pages" — no Bullhorn. **Diagnostic W3-4 build does not touch the Bullhorn auth path at all.**

The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.

So the correct statement of the gate hierarchy:

| Gate | Trigger | Status |
|---|---|---|
| Week-0 close (Day-7 single-sentence test) | Q3 = YES required | NO (Week 0 extending) |
| Week-1 prereq code | None — substrate is ATS-agnostic | DONE (Phases 1-5 landed Day 8) |
| Diagnostic build (W3-4) | None — Diagnostic doesn't touch Bullhorn | Awaits Q1 LOI |
| Janitor build (W5) | A+B Accepted (commercial conversations complete) | Pending |

Codex over-applied the Q3 gate from "Week-0 close" + "named agent-build slices" down to "Week-1 implementation generally" — a category error. Week-1 prereq code is upstream of all agent builds; it doesn't need Bullhorn auth resolved.

### Where Codex IS right

The bullhorn-integration-path.md line 95 wording is arguably ambiguous — "Week-1 implementation can proceed" without qualifying "Week-1 prereq code only, not agent-build slices" is loose. The fix is wording sharpening, not gate-tightening.

---

## §3 — Resolution

- [ ] Incorporated (Codex correct; rewrite bullhorn-integration-path §95 to make all Week-1 implementation conditional on A+B Accepted)
- [x] **Counter-argued + sharpen wording (Claude's reading on substance prevails; tighten line 95 wording for clarity)**
- [ ] Compromise

## §4 — Proposed line 95 sharpening (landed in Round-2 remediation)

Current line 95 (paraphrased): "Sub-decisions A+B remaining Proposed does not block Week-1 implementation."

Proposed:

```
**Status: Sub-decisions A+B can remain Proposed without blocking Week-1
PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of
which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5)
build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate.
```

**Round-2 remediation update (2026-05-22):** this source-document sharpening landed in this commit alongside the new `bullhorn-integration-path.md` Gate hierarchy subsection.

---

## §5 — Founder decision

Founder picks one of:

- **Sharpen wording (Claude's read)** — recommended. Line 95 gets the proposed text above. Re-run Codex Round 2; expected to RATIFY with the clarified gate hierarchy. **Recommended.**
- **Tighten the gate (Codex's read)** — make all Week-1 implementation conditional on A+B Accepted. Forces all 5 Week-1 prereq commits to be re-classified as W5-prereq. Operationally complex + arguably wrong (renderer doesn't need Bullhorn auth to render).
- **Split the difference** — line 95 wording sharpens AND a new explicit "Week-1 prereq vs W5 agent-build gate hierarchy" subsection is added to bullhorn-integration-path.md §1.

Cost of delay: minor; Week-1 prereq code is already shipped, so the gate disagreement is retrospective rationalisation rather than blocking future work.

**Resolution update (2026-05-22):** [x] Incorporated via "Counter-argued + sharpen wording." The source decision now encodes the prereq-code-only gate and the W5 Janitor auth gate explicitly.

*End of disagreement doc.*
