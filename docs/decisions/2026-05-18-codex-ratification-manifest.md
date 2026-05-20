# Codex ratification manifest (Day 7 first ratification run)

**Date:** 2026-05-18 (per master brief §6 Day 7 calendar; actual execution 2026-05-20)
**Author:** Founder (Maddox) + Claude Code
**Status:** Reference
**Source:** Master brief §10 (the Codex ratification loop) + §10.6 (Day 7 first ratification run)

---

## §1 — Queue

19 items registered for Codex Day-7 ratification per `.agents/current-priorities.md` "Queued for Codex ratification (Day 7)" section. Items 13 (atomic-correction commit) and 15 (placeholder) resolve to other entries in the list — effective ratification queue is **17 substantive artefacts + 1 commit landed today**.

| # | Artefact | Status | Codex review scope |
|---|---|---|---|
| 1 | `docs/architecture/cortexos-primitive-status.md` | Reference (audit) | Verify primitive grades against current SHA; flag any drift in primitive 1 (PTY/PM2) stability claims |
| 2 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | Accepted | Verify Option A reasoning + edits applied (chokidar → FastChecker landed in atomic-correction commit `0e5b2b4`) |
| 3 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | Accepted | Verify Option α reasoning + Edits 1+2+3 all applied (3, 4, 12 in atomic-correction manifest) |
| 4 | `docs/architecture/second-brain-design.md` | Reference (ADR-002 binding) | Cross-check against ADR-002 ratification |
| 5 | `docs/architecture/agent-bundle-renderer-design.md` | Reference (ADR-003 binding) | Cross-check 22 spec gaps + 4 buckets against ADR-003 |
| 6 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | Accepted | Verify 4 decisions + Edits A+B+C applied (5 in atomic-correction; A+B landed Day 1 evening) |
| 7 | `docs/decisions/bullhorn-integration-path.md` | Sub-decision C Accepted; A+B Proposed | Verify Sub-decision C technical analysis; flag A+B as awaiting commercial gates (Q3 unblocker) |
| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
| 9 | `docs/decisions/brain-ui-scope.md` | Proposed (pending v1.1) | Verify v1.0/v1.1/v1.2 phasing aligns with §5.5 post-Edit 4 table |
| 10 | `docs/architecture/vault-concurrency.md` | Reference | Verify 4 concurrency mechanisms + 5 ESC_VAULT_* codes + worked TypeScript examples |
| 11 | `docs/runbooks/day-4-provisioning.md` | Executed | Verify §12 execution log (20 deviations + 8 v1.1 revisions); cross-check schema migration against decision_log.phase enum (live SQL at `c6734d1`) |
| 12 | Day-4 close commit `98c79b2` | Audit log | Verify 22/22 §9 verification checks; confirm RLS isolation gate (5/5 conditions) |
| 13 | **Atomic-correction commit `0e5b2b4` (this commit's predecessor)** | **Landed today** | **Verify all 11 edits applied verbatim against source artefacts; verify two side effects flagged in commit message (Edit 1 col 4; Edit 4 row merge)** |
| 14 | Day-4 Postgres provisioning artefact | Embedded in #12 | Same review as #12 + verify 4 consolidated tightenings (entity_graph split, _secrets.env, decision_log.phase, entities.version) |
| 15 | (placeholder — absorbed by #16-#18) | n/a | n/a |
| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
| 17 | `docs/decisions/v1.0-kill-criterion.md` + Day-5 close commit `c6734d1` | Proposed + audit log | Verify 10 binary triggers; verify §3 founder-solo authority structure; verify live SQL migration (decision_log.phase 5→6) |
| 18 | `docs/verticals/recruitment/vertical-schema.yaml` | Proposed | Verify 8 entities + 89 fields + 10 relationships + agent R/W matrix + 12 open_questions; cross-check Bullhorn mapping against §4.1 |
| 19 | `docs/runbooks/operational-hygiene-protocol.md` | In Force | Verify Path A/D + no-defensive-additions + length calibration + citation accuracy rules; verify §7 audit findings (15 §10.4 fabrications fixed) |

**Plus this manifest itself (#20)** and **Day-7 single-sentence test artefact (#21)** join the queue on commit. Total: **21 items** at Day-7 close.

---

## §2 — Ratification protocol per master brief §10.3

Verbatim from master brief §10.3 (post-Edit 7 path correction):

> 1. **Claude Code** produces the artefact on a feature branch
> 2. **You** run: `codex review --skill .codex/ratification/review-{type}.md --target {path-or-diff}`
> 3. **Codex** returns RATIFIED or REJECTED with concrete issues
> 4. **Claude Code** reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)
> 5. After ≤ 2 round-trips, merge. Still disagreeing? Escalate to founder to decide.

For Day-7 first ratification run, steps 1-2 require `.codex/ratification/*.md` skills to exist. They don't yet (see §3).

---

## §3 — Gap: `.codex/ratification/` skills not yet built

Master brief §10.2 (Day 0-1 task) specifies 7 skill files under `.codex/ratification/`:

| File | Purpose |
|---|---|
| `SKILL.md` | Top-level "what does ratify mean" — checks against the five rules + the four boundaries |
| `review-agent-bundle.md` | Specific checklist for the 6 files + 3 fixtures of a new agent |
| `review-mcp-connector.md` | Specific checklist for a new MCP connector |
| `review-schema-change.md` | Specific checklist for `vertical-schema.yaml` edits |
| `review-postgres-migration.md` | Specific checklist for new tables, RLS policy changes |
| `review-architecture-decision.md` | Specific checklist for ADRs in `docs/decisions/` |
| `review-harness-bump.md` | Specific checklist when bumping the pinned cortextos SHA |

**Current state:** `.codex/ratification/` directory does not exist. Day 0-1 task was never executed during Days 0-6 (focus was on master brief §6 Day 0-6 critical path; `.codex/ratification/` slipped per master brief §10.6 framing "Claude does this; we don't ratify the ratification skills until Day 7" but skills themselves needed to be built first).

**Codex CLI itself is installed** at `/opt/homebrew/bin/codex`. The gap is the IFOS-specific ratification skills, not the Codex tool.

---

## §4 — Schedule

Per Day-7 founder decision (Option C in grounding): defer ratification execution. Produce the manifest today (this artefact). Schedule the actual ratification work as follows:

| Phase | Trigger | Estimated work |
|---|---|---|
| **Build `.codex/ratification/*.md` skills** | Week 0 extension period (concurrent with Q1 design-partner work) | 2-3 person-days. 7 skill files per master brief §10.2; each follows the "RATIFIED / REJECTED with numbered issues" output contract. |
| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
| **Disagreement artefacts** | If Codex REJECTS or disagrees with any artefact | `docs/decisions/codex-disagreement-<date>.md` per master brief §10.3 step 4. Founder decides on escalations. |

---

## §5 — Atomic-correction commit status

**LANDED TODAY at `0e5b2b4`** — `docs: master brief reconciliation — 11 edits batch-applied`.

11 file changes applied to:

- `docs/build-brief/00-MASTER-BRIEF.md` (10 edits)
- `docs/specs/ULTRAPLAN.md` (1 edit)

Edits per the manifest in `.agents/current-priorities.md`:

| # | Edit | Source artefact | Verified |
|---|---|---|---|
| 1 | §2.4 row 3 chokidar → FastChecker (+ col 4 wiki-* reframe) | ADR-001 line 38 | ✓ verbatim |
| 2 | Ultraplan §3.2 watcher → FastChecker + 3-5s reframe | ADR-001 §Consequences line 59 | ✓ verbatim |
| 3 | §3.4 shadow → parallel (full rewrite) | ADR-002 Edit 1 line 81 | ✓ verbatim |
| 4 | §5.5 v1.0 minimum row + v1.0+/v1.1 row merge | ADR-002 Edit 2 line 91 | ✓ verbatim (with side effect documented) |
| 5 | §8 renderer footnote (before §8.1) | ADR-003 Edit C | ✓ verbatim |
| 6 | §6 Day 2 line 466 OAuth wording | Bullhorn §6.6 | ✓ verbatim |
| 7 | §6 Day 3 line 471 path drift | Sequencing §6.8 | ✓ verbatim |
| 8 | §6 Day 3 line 472 three-drift rewrite | Brain-UI §4.5 | ✓ verbatim |
| 9 | §6 Day 4 line 477 Hetzner UK → FSN1/NBG1 | Day-4 runbook §0.1 | ✓ (slight expansion: Schrems II + no-UK-DC verification note) |
| 10 | §6 Day 5 lines 484-485 path drift (both files) | Day-5 path-drift edit | ✓ literal |
| **~~11~~** | **DROPPED** | (was decision_log.phase enum already executed at `c6734d1`) | n/a |
| 12 | §6 Day 4 line 478 table list (entity_graph split) | ADR-002 Edit 3 | ✓ verbatim |

**Master brief is fully reconciled** as of `0e5b2b4`. No further atomic-correction edits queued.

---

## §6 — Items requiring founder attention before ratification

Five items in the queue have open status / decisions that Codex may flag at ratification time. Surfaced here so founder can pre-resolve before triggering ratification.

| # | Item | Open status | Founder pre-resolution |
|---|---|---|---|
| 7 | `bullhorn-integration-path.md` Sub-decisions A+B | Proposed pending commercial conversations | Either (a) run the Bullhorn outreach + design-partner #1 conversation during extension and flip to Accepted, OR (b) accept ratification of Sub-decision C only, with A+B explicitly marked "deferred to first pilot's actual ATS confirmation" |
| 9 | `brain-ui-scope.md` | Proposed pending v1.1 phase | Likely Codex ratifies as-is post-Edit 8 atomic correction (master brief §6 Day 3 line 472 + §5.5 now consistent). No founder action needed. |
| 13 | Atomic-correction commit `0e5b2b4` — Edit 1 col 4 + Edit 4 row merge side effects | Flagged in commit message | Codex may RATIFY or REJECT the side-effect expansions. If REJECTED: revert the col 4 expansion (Edit 1) and/or restore 3-row §5.5 table (Edit 4). Founder decision on the disagreement artefact. |
| 16 | `autosend-safety-policy.md` §10 pilot-agreement liability | Placeholder — legal review required before first pilot LOI | Pre-LOI legal review (commercial / regulatory). Codex can ratify the placeholder shape but cannot substitute for legal counsel. |
| 17 | `v1.0-kill-criterion.md` §3.4 external advisor | TBD — Week 1-2 must-fill | Founder identifies + engages external advisor before first pilot LOI signs. Codex flags the TBD but cannot resolve. |

**The remaining 14 of 19 items** are expected to ratify cleanly without founder pre-resolution.

---

## §7 — Day-7 closure

This manifest does NOT close the ratification work. It records:

1. **What's queued** (19 items + this manifest = 20 + single-sentence test = 21 items at Day-7 close).
2. **What's blocking** (`.codex/ratification/*.md` skills not built; Q1 design-partner gap → Week 0 extending).
3. **What landed today** (atomic-correction commit `0e5b2b4`; master brief fully reconciled).
4. **What needs founder attention before triggering ratification** (the 5 items in §6).

Single-sentence test artefact (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`) is the sibling Day-7 close artefact in this commit. Week 0 extends per its §4 closure determination.

---

## Status

**Reference.** This manifest is itself queued for Codex ratification (item #20) — once `.codex/ratification/*.md` skills exist + Week 0 closes are achievable.

*End of Codex ratification manifest.*
