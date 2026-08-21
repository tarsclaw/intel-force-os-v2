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

**Plus this manifest itself (#20)** and **Day-7 single-sentence test artefact (#21)** join the queue on commit. Original Day-7 close total: **21 items**. Current manifest state after Round 3 remediation: **43+ queued/registered items; 24 RATIFIED in the 26-item Round-2/Round-3 slice, 2 artefacts founder-escalated pending D1/D2/D3, and the rest deferred/not yet in the Round-2 slice.**

---

## §1.6 — Day-9 architecture+tenancy verification additions (2026-05-20 evening)

Architecture+tenancy slice (commits `5c3fa66` + `c4348aa`) adds 4 new artefacts to the queue. These ratify against `review-architecture-decision.md` skill (with Founder Decision D5 softening for the lifecycle runbook):

| # | Artefact | Path | Ratifies via | Round-1 verdict |
|---|---|---|---|---|
| 35 | tenancy-invariants.md | `docs/architecture/tenancy-invariants.md` | review-architecture-decision | Queued for Round 2 |
| 36 | architecture-cohesion-review.md | `docs/architecture/architecture-cohesion-review.md` | review-architecture-decision (Reference; D5 softening applies) | Queued for Round 2 |
| 37 | tenant-lifecycle.md | `docs/runbooks/tenant-lifecycle.md` | review-architecture-decision (In Force; D5 softening applies) | Queued for Round 2 |
| 38 | run-tenancy-audit.sh | `scripts/run-tenancy-audit.sh` | review-architecture-decision (Reference) | Queued for Round 2 |

**Cross-cutting reference:** these 4 artefacts ratify the layered defence model documented across Day-4 §7 (RLS isolation gate) + ADR-002 (parallel brain) + ADR-003 (renderer) + ADR-004 (deviations). They are downstream of, not redundant with, the existing 21+ queue items.

**Queue total: 43 items** at Day-9 evening close. Round 2 subsequently reviewed 26 of these artefacts and closed with **17 RATIFIED / 9 REJECTED**.

## §1.7 — Codex Round 2 verdicts (2026-05-22)

Autonomous Round 2 ratification reviewed 26 artefacts across the re-ratification, Day-9, and Day-11 queues. Remediation commits referenced by the protocol: `2b287d3` (Round-1 incorporation), `5c3fa66` + `c4348aa` (architecture+tenancy), `783c496` (D5 skill softening), and `20e78d7` + `95e7d4a` (D1/D3 prep). Result: **17 RATIFIED / 9 REJECTED**. Full report: `logs/codex-ratification/round-2-autonomous/SUMMARY.md`.

| # | Artefact | Round-2 verdict | Round-2 disposition |
|---|---|---|---|
| 1 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | RATIFIED | Incorporated remediation verified clean. |
| 2 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | RATIFIED | Incorporated remediation verified clean. |
| 3 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | RATIFIED | Incorporated remediation verified clean. |
| 4 | `docs/decisions/bullhorn-integration-path.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
| 5 | `docs/decisions/sequencing-target.md` | RATIFIED | Incorporated remediation verified clean. |
| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
| 7 | `docs/architecture/cortexos-primitive-status.md` | RATIFIED | Incorporated remediation verified clean; D5 softening applied. |
| 8 | `docs/architecture/second-brain-design.md` | RATIFIED | Incorporated remediation verified clean. |
| 9 | `docs/architecture/agent-bundle-renderer-design.md` | RATIFIED | Incorporated remediation verified clean. |
| 10 | `docs/architecture/vault-concurrency.md` | RATIFIED | Incorporated remediation verified clean. |
| 11 | `docs/decisions/v1.0-kill-criterion.md` | RATIFIED | Incorporated remediation verified clean. |
| 12 | `docs/runbooks/operational-hygiene-protocol.md` | RATIFIED | Incorporated remediation verified clean; D5 softening applied. |
| 13 | `docs/verticals/recruitment/vertical-schema.yaml` | RATIFIED | Incorporated remediation verified clean. |
| 14 | `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
| 15 | `docs/architecture/tenancy-invariants.md` | RATIFIED | First ratification on Round 2; RATIFIED. |
| 16 | `docs/architecture/architecture-cohesion-review.md` | RATIFIED | First ratification on Round 2; RATIFIED. |
| 17 | `docs/runbooks/tenant-lifecycle.md` | RATIFIED | First ratification on Round 2; RATIFIED. |
| 18 | `scripts/run-tenancy-audit.sh` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | RATIFIED | First ratification on Round 2; recursive disagreement RATIFIED. |
| 20 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | REJECTED | First ratification on Round 2; recursive disagreement REJECTED. Open: see SUMMARY.md §3-§4. |
| 21 | `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` | RATIFIED | First ratification on Round 2; RATIFIED with D1/D2/D3 advisory. |
| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
| 23 | `docs/runbooks/pii-purge-operational-pattern.md` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
| 24 | `scripts/ifos-pii-purge.sh` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
| 25 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | REJECTED | First ratification on Round 2; REJECTED. Open: see SUMMARY.md §4. |
| 26 | `docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql` | RATIFIED | First ratification on Round 2; RATIFIED; paired forward migration remains rejected. |

## §1.8 — Codex Round 3 remediation verdicts (2026-05-22)

Round 3 remediated the Round-2 rejection set. Mechanical fixes were incorporated in this remediation commit; founder-domain items were annotated and escalated without Codex making D1/D2/D3 decisions. Result for the corrected subset: **10 RATIFIED / 0 REJECTED of 10**. Full report: `logs/codex-ratification/round-3-remediation/SUMMARY.md`.

| # | Artefact | Round-3 verdict | Round-3 disposition |
|---|---|---|---|
| 1 | `docs/decisions/bullhorn-integration-path.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
| 3 | `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` | FOUNDER-ESCALATED | Founder-escalated pending D3; `consrc` companion-migration issue fixed separately. |
| 4 | `scripts/run-tenancy-audit.sh` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
| 5 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
| 6 | `docs/decisions/autosend-approval-bridge-spec.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
| 7 | `docs/runbooks/pii-purge-operational-pattern.md` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
| 8 | `scripts/ifos-pii-purge.sh` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
| 9 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
| 10 | `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` | RATIFIED | Mechanical remediation incorporated in this commit; Round-3 RATIFIED. |
| 11 | `docs/architecture/tenancy-invariants.md` | RATIFIED | Auxiliary update incorporated in this commit; Round-3 RATIFIED. |
| 12 | `agents/_shared/hook-helpers.sh` + `agents/_shared/voice-loader.sh` + `scripts/run-codex-ratification.sh` | RATIFIED | Cross-cutting Risk #11 remediation incorporated in this commit; Round-3 RATIFIED. |

---

## §1.10 — Codex Round 4 queue (Week 3 Diagnostic + 5 agent.md scaffolds)

Round 4 scheduled across Week 3 (Days 14-20) per `docs/operations/goal-week-3-polish-and-scaffold.md` Steps 7 (Diagnostic-only, Day 15) + 13 (full run, Day 20). Per master brief §10.3 step 5: ≤2 round-trips per artefact (Round 4 + Round 5 remediation max).

Two phases:

**Phase 1 (Day 15) — Diagnostic-only mid-week ratification.** Reason: substrate must be verified before 5 new scaffolds reference it. 6 items, all `review-architecture-decision.md` skill except the package-as-a-whole.

| # | Artefact | Status | Codex skill | Reason for re-ratify |
|---|---|---|---|---|
| 1 | `agents/recruitment/diagnostic/agent.md` | Proposed → Accepted (post-W3 polish) | `review-architecture-decision.md` | Was Round-3 RATIFIED at scaffold form; re-ratify after Day-13 + Step-3 fixes (firm-slug, suffix-strip) + Step-4 LLM §12 wiring |
| 2 | `agents/recruitment/diagnostic/tools.yaml` | Proposed | `review-architecture-decision.md` | First ratification (Day-12 scaffold) |
| 3 | `agents/recruitment/diagnostic/cycle.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 generator wiring (commit `fd38254`) |
| 4 | `agents/recruitment/diagnostic/validate.sh` | Proposed | `review-architecture-decision.md` | Post-Day-13 V2 awk-pass fix (commit `97a57a2`) |
| 5 | `packages/diagnostic-generator/` (package as a whole) | Proposed | `review-architecture-decision.md` | Day-13 ship; first ratification |
| 6 | `docs/decisions/ADR-005-week-3-diagnostic-acceleration.md` | Accepted | `review-architecture-decision.md` | Day-13 sequencing decision; first ratification |

**Phase 2 (Day 20) — Full Round 4: 5 new agent.md scaffolds.** Each authored Days 16-19 per goal-week-3 Steps 8-12. All `review-architecture-decision.md` skill.

| # | Artefact | Status | Codex skill | Master plan citation |
|---|---|---|---|---|
| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |

**Total Round 4 items: 11** (6 Phase 1 + 5 Phase 2). Queue grown 43 → 54 with the Day-9 + Day-11 additions counted.

**Day-19 update:** Initial Round-4 Phase-1 attempt used `review-architecture-decision.md` skill (the only available skill at the time). That returned REJECTED with a load-bearing finding (Issue 5 in `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md`) — agent.md files require a different skill structure. **`review-agent-bundle.md` skill built in commit `825ebd4`.** Re-ratification of all 6 agent.md items with the new skill.

**Round-4-v2 verdicts (post-skill-build, Day-19 13:25 UTC):**

| # | Artefact | Verdict | Issues | Session log |
|---|---|---|---|---|
| 1 | `agents/recruitment/diagnostic/agent.md` | **REJECTED** | 5 real findings (Gate A strength + Step 11 decision-log + Trigger 8 mismap + sentinel + validate.sh gap) | `20260524T101934Z-19923` |
| 2 | `agents/recruitment/janitor/agent.md` | **REJECTED** | ~5-7 real findings (count regex 56 inflated by nested lists) | `20260524T102050Z-21293` |
| 3 | `agents/recruitment/scribe/agent.md` | **REJECTED** | ~5-7 real findings (count regex 59) | `20260524T102202Z-22338` |
| 4 | `agents/recruitment/cash-conductor/agent.md` | **REJECTED** | ~5-7 real findings (count regex 58) | session log in tree |
| 5 | `agents/recruitment/sourcing-scout/agent.md` | **REJECTED** | ~5-7 real findings (count regex 50) | session log in tree |
| 6 | `agents/recruitment/concierge/agent.md` | **REJECTED** | ~5-7 real findings (count regex 59) | session log in tree |

**Total: 0 RATIFIED / 6 REJECTED of 6** — all agent.md files require founder arbitration on the systemic 5-category disposition framework documented in the codex-disagreement doc Round-4-v2 update section.

**Hard ceiling reached** per master brief §10.3 step 5. Single founder decision (approve the 5-category disposition) unlocks all 6 ratifications via a single Round-5 mechanical-remediation pass.

Remaining Phase-1 items (tools.yaml + cycle.sh + validate.sh + package + ADR-005) NOT yet attempted because they would have inherited the same skill-mismatch issue. ADR-005 should ratify cleanly under `review-architecture-decision.md` (it IS a decision doc); .sh + .yaml files may need their own skills built (defer).

**Round-4 disagreement protocol** (per master brief §10 + Day-8 pattern):
- Codex challenges a master-plan-cited decision → write `docs/decisions/codex-disagreement-YYYY-MM-DD-<topic>.md` per Day-8 pattern; founder arbitrates at next Sunday review
- Codex flags a citation drift → mechanical fix; re-submit; counts as Round 5 remediation
- Codex requires a founder decision (D-class) → annotate; defer to founder; do NOT auto-remediate

---

## §1.5 — Codex Round 1 verdicts (2026-05-20)

First ratification run completed Day 8. Cluster A+B+C reviewed (16 artefacts). Per-artefact verdict + Round-1 disposition:

| # | Artefact | Round-1 verdict | Round-1 disposition |
|---|---|---|---|
| 1 | cortexos-primitive-status.md | REJECTED (2 issues) | Issue 1 (missing Status field) **incorporated** at commit `2b287d3`. Issue 2 (missing Decision/Consequences) **counter-argued** in `codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`; resolution pending Founder Decision D5. |
| 2 | ADR-001 | REJECTED (2 issues) | Issue 1 (Decision-subheading format) advisory only; Issue 2 (status drift "review pending") **incorporated** at `2b287d3`. |
| 3 | ADR-002 | REJECTED (2 issues) | Issue 1 (status drift) + Issue 2 (master-brief-edit disposition) both **incorporated** at `2b287d3` — disposition now cites commit `0e5b2b4`. |
| 4 | second-brain-design.md | REJECTED (2 issues) | Issue 1 (status enum) + Issue 2 (ESC catalogue cite) both **incorporated** at `2b287d3`. |
| 5 | agent-bundle-renderer-design.md | REJECTED (3 issues) | Issue 1 (status enum) + Issue 2 (phase='render' drift) + Issue 3 (CLI name drift) all **incorporated** at `2b287d3`. |
| 6 | ADR-003 | REJECTED (2 issues) | Issue 1 (status drift) + Issue 2 (CLI surface drift) both **incorporated** at `2b287d3` with inline ADR-004 erratum reference. |
| 7 | bullhorn-integration-path.md | REJECTED (3 issues) | Issue 1 (status enum) + Issue 3 (rate-limit speculation note) **incorporated** at `2b287d3`. Issue 2 (Week-1 gate) **counter-argued** in `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`; line 95 wording sharpened. |
| 8 | sequencing-target.md | REJECTED (2 issues) | Issue 1 (status drift) **incorporated** at `2b287d3`. Issue 2 (phase enum cite) implicitly addressed via ADR-004 Decision 7 cross-reference. |
| 9 | brain-ui-scope.md | **RATIFIED** | Advisory only (v1.1 revisit estimate may need refresh if launch calendar moves). |
| 10 | vault-concurrency.md | REJECTED (2 issues) | Issue 1 (migration cite for `entities.version`) advisory; Issue 2 (ESC wiring) **incorporated** at `2b287d3` with cross-references to commits `a279226` + `e6e9df1`. |
| 11 | day-4-provisioning.md | not in Round 1 (Cluster D) | Cluster D ratification deferred per execution plan §9 Option γ. |
| 12 | Day-4 close commit `98c79b2` | not in Round 1 | Same — Cluster D. |
| 13 | Atomic-correction commit `0e5b2b4` | not in Round 1 | Same — Cluster F. |
| 14 | Day-4 Postgres artefact | not in Round 1 | Same. |
| 15 | placeholder | — | — |
| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
| 17 | v1.0-kill-criterion.md | REJECTED (3 issues) | All three (Trigger 1 date / Trigger 2 CLI / Trigger 4 threshold) **incorporated** at `2b287d3`. |
| 18 | vertical-schema.yaml v0.1 | REJECTED (3 issues) | Issue 1 (voice_classifier_score CHECK) **incorporated** with v0.2 trigger reference. Issue 2 (empty access arrays) **incorporated**. Issue 3 (versioning count) **incorporated**. Plus pre-existing YAML parse errors fixed. |
| 19 | operational-hygiene-protocol.md | REJECTED (2 issues) | Issue 1 (missing Decision/Consequences) **counter-argued** in disagreement doc; resolution pending Founder Decision D5. Issue 2 (Path B contradiction) **incorporated** at `2b287d3` — Path B language tightened. |
| 20 | This manifest | not in Round 1 | Recursive ratification deferred per execution plan §10 step 6. |
| 21 | Day-7 single-sentence test | not in Round 1 | Cluster G. |

**Plus Round-1 ADR-004** (item not in original 21-queue but added Day 8): **RATIFIED**.

**Round-1 totals:** 16 reviewed | **2 RATIFIED** (ADR-004 + brain-ui-scope) | **14 REJECTED** | **13 of 14 incorporated** at commit `2b287d3` | **2 disagreement docs filed** | **5 founder decisions surfaced** (D1-D5).

**Round-2 expected:** re-run Cluster A+B+C after `2b287d3` lands. Expected 14 → 0-2 REJECTED (0-2 being the disagreement-resolution artefacts pending founder D5 verdict).

**New artefacts added to queue post-Round-1** (will be ratified in Round 2 or later):
- `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`
- `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`
- `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`

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
