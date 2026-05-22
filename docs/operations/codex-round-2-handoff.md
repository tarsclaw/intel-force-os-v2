# Codex Round 2 — handoff protocol

**Status:** Reference (operations protocol).
**Date:** 2026-05-22 (Day 11 evening).
**Audience:** Founder (Maddox). Self-contained — read this; run the commands; close the queue.
**Companions:**
- `docs/operations/codex-ratification-guide.md` — the practical step-by-step (Round-1 era)
- `docs/operations/codex-ratification-execution-plan.md` — overall execution framework
- `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5 + §1.6 — queue state
- `scripts/run-codex-ratification.sh` — the driver wrapper

---

## §1 — Why Round 2 is different from Round 1

Round 1 ran against the pre-remediation artefact set and rejected 14 of 16. Round 2 runs against the **post-remediation** artefact set + new artefacts that landed in commits `2b287d3` (Codex Round-1 remediation) + `5c3fa66`+`c4348aa`+`e1ff40f` (architecture+tenancy) + `783c496` (D5 skill softening) + `20e78d7`+`95e7d4a` (D1 + D3 preparation).

Three structural changes since Round 1:

1. **13 of 14 Round-1 rejections incorporated** in `2b287d3` — re-ratifying those artefacts should produce mostly RATIFIED verdicts.
2. **Skill softened (D5)** — `review-architecture-decision.md` §1 now exempts Reference + In Force from Decision/Consequences requirements. 2 artefacts that REJECTED on this in Round 1 (`cortexos-primitive-status.md` audit + `operational-hygiene-protocol.md` runbook) should RATIFY in Round 2.
3. **12 NEW artefacts** queued since Round 1 — tenancy-invariants, architecture-cohesion-review, tenant-lifecycle, 2 disagreement docs, founder briefing, D1 spec, D3 prep, 2 migration SQL files, audit script + cron script. None have been Codex-reviewed yet.

**Round-2 queue: 26 artefacts** total (14 re-ratifications + 12 new).

---

## §2 — Pre-flight (no Codex calls; ~5 min)

Run from repo root:

```bash
cd ~/code/CortexOS

# Step 1: codex CLI works
codex --version
# Expected: codex v0.x.y
# If error like "spawn ... ENOENT": see codex-ratification-guide.md §3.1

# Step 2: auth still valid
codex auth status
# Expected: signed in OR API key present

# Step 3: skills present + softening landed (D5)
ls .codex/ratification/
# Expected: SKILL.md + review-architecture-decision.md + review-schema-change.md + review-postgres-migration.md

grep -A 2 "§1-Exemption" .codex/ratification/review-architecture-decision.md | head -5
# Expected: "§1-Exemption — Softening for Reference + In Force (Codex Round 1 D5)"
# If empty: D5 didn't land; investigate before proceeding

# Step 4: wrapper script works
bash scripts/run-codex-ratification.sh --list-clusters
# Expected: lists Clusters A/B/C/D with member files

# Step 5: pre-flight log dir exists
mkdir -p logs/codex-ratification/round-2
```

If all 5 pass: ready for Round 2.

---

## §3 — Round-2 queue (3 tiers)

### Tier 1 — Re-ratify Round-1 REJECTED (14 artefacts)

These were REJECTED in Round 1; remediation landed in `2b287d3`. **Expectation: most flip to RATIFIED.**

| # | Path | Round-1 issue(s) | Round-2 expectation |
|---|---|---|---|
| 1 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | "review pending" status drift | RATIFY (line 4 fixed) |
| 2 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | status drift + edit disposition | RATIFY (status + Edits 1+2+3 cite `0e5b2b4`) |
| 3 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | status drift + CLI surface drift | RATIFY (status + ADR-004 erratum + CLI updated) |
| 4 | `docs/decisions/bullhorn-integration-path.md` | status "Mixed" enum violation + Week-1 gate | RATIFY status; Week-1 gate may rebound (disagreement doc filed) |
| 5 | `docs/decisions/sequencing-target.md` | status "Drafting" | RATIFY (status "Accepted") |
| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
| 7 | `docs/architecture/cortexos-primitive-status.md` | missing Status + missing Decision/Consequences | RATIFY (Status added; D5 softening exempts Reference from Decision) |
| 8 | `docs/architecture/second-brain-design.md` | status enum + ESC catalogue cite | RATIFY (status + cross-ref added) |
| 9 | `docs/architecture/agent-bundle-renderer-design.md` | status enum + phase=render + CLI drift | RATIFY (all three fixed) |
| 10 | `docs/architecture/vault-concurrency.md` | migration cite + ESC wiring | RATIFY (cross-refs added) |
| 11 | `docs/decisions/v1.0-kill-criterion.md` | Trigger 1 date + Trigger 2 CLI + Trigger 4 threshold | RATIFY (all three fixed) |
| 12 | `docs/runbooks/operational-hygiene-protocol.md` | missing Decision/Consequences + Path B | RATIFY (D5 softening + Path B tightened) |
| 13 | `docs/verticals/recruitment/vertical-schema.yaml` | voice_classifier_score CHECK + empty access + versioning count | RATIFY (all three fixed) |
| 14 | `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` | source fields + layering + rollback cite + PII | RATIFY first 3; **may REJECT on PII** — D3 unresolved |

**Likely outcomes:** 11-12 of 14 RATIFY. Items #6 (autosend tier contradiction) and #14 (PII retention) are founder-decision-bound (D1/D3); Codex may RATIFY-with-advisory or REJECT pending decisions.

### Tier 2 — Day-9 architecture+tenancy artefacts (4 new)

Brand new; never seen by Codex.

| # | Path | Skill | Expectation |
|---|---|---|---|
| 15 | `docs/architecture/tenancy-invariants.md` | `review-architecture-decision` | RATIFY (Reference status under D5 softening; well-cited) |
| 16 | `docs/architecture/architecture-cohesion-review.md` | `review-architecture-decision` | RATIFY (Reference; surfaces gaps with named paths) |
| 17 | `docs/runbooks/tenant-lifecycle.md` | `review-architecture-decision` | RATIFY (In Force runbook; D5 softening applies) |
| 18 | `scripts/run-tenancy-audit.sh` | `review-architecture-decision` (script-as-artefact) | RATIFY (12 invariants enumerated; mirrors run-live-migration pattern) |

### Tier 3 — Day-11 disagreement + decision + spec + D3 prep (8 new)

| # | Path | Skill | Special handling |
|---|---|---|---|
| 19 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | `review-architecture-decision` | **Recursive ratification per master brief §10.5.** Codex either RATIFIES the disagreement (D5 was correct) OR REJECTS (insists on strict skill). Founder escalation if REJECT. |
| 20 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | `review-architecture-decision` | **Recursive ratification.** Codex evaluates Claude's counter-argument re: Week-1 gate. Founder escalation if REJECT. |
| 21 | `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` | `review-architecture-decision` | RATIFY-with-advisory (briefing doc; D5 softening applies as Reference) |
| 22 | `docs/decisions/autosend-approval-bridge-spec.md` | `review-architecture-decision` | RATIFY (Proposed spec; alternatives weighed; ratifies cortextOS primitive-4 reuse) |
| 23 | `docs/runbooks/pii-purge-operational-pattern.md` | `review-architecture-decision` (Proposed runbook) | RATIFY (Proposed pending D3; comprehensive operational coverage) |
| 24 | `scripts/ifos-pii-purge.sh` | `review-architecture-decision` (script-as-artefact) | RATIFY (small, single-purpose, shellcheck clean) |
| 25 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | `review-postgres-migration` | RATIFY (additive; CHECK constraint; rollback ships) |
| 26 | `docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql` | `review-postgres-migration` | RATIFY (clean rollback) |

---

## §4 — Run Round 2 (the actual execution)

Two paths: wrapper-driven or interactive single-prompt.

### Path A — Wrapper-driven (recommended; saves audit row per artefact)

```bash
cd ~/code/CortexOS

# Tier 1 — re-ratify 14 previously REJECTED
bash scripts/run-codex-ratification.sh --cluster A
bash scripts/run-codex-ratification.sh --cluster B
bash scripts/run-codex-ratification.sh --cluster C

# Tier 2 — Day-9 new artefacts (run individually)
bash scripts/run-codex-ratification.sh architecture-decision docs/architecture/tenancy-invariants.md
bash scripts/run-codex-ratification.sh architecture-decision docs/architecture/architecture-cohesion-review.md
bash scripts/run-codex-ratification.sh architecture-decision docs/runbooks/tenant-lifecycle.md
bash scripts/run-codex-ratification.sh architecture-decision scripts/run-tenancy-audit.sh

# Tier 3 — Day-11 new artefacts
bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md
bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md
bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
bash scripts/run-codex-ratification.sh architecture-decision docs/decisions/autosend-approval-bridge-spec.md
bash scripts/run-codex-ratification.sh architecture-decision docs/runbooks/pii-purge-operational-pattern.md
bash scripts/run-codex-ratification.sh architecture-decision scripts/ifos-pii-purge.sh
bash scripts/run-codex-ratification.sh postgres-migration docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
bash scripts/run-codex-ratification.sh postgres-migration docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
```

**Expected time:** 4-5h total (clusters A+B+C ~3h; 12 individual ratifications ~10-15 min each ≈ 2h).

**Per-artefact output:** `logs/codex-ratification/<session-id>/<slug>.output.md` + audit row to `decision_log` (live mode) OR `logs/codex-ratification.jsonl` (fallback).

### Path B — Interactive single-prompt (alternative; cheaper Codex billing)

Launch `codex` interactively inside the repo. Paste the Round-2 prompt from §5 below.

---

## §5 — The Round-2 prompt (for Path B interactive mode)

```
You are running Codex ratification Round 2 for the Intel Force OS (IFOS)
codebase. Working directory: IFOS repo root. This run reviews 26 artefacts
across 3 tiers.

CONTEXT:
- Round 1 ran 16 artefacts; 2 RATIFIED (ADR-004 + brain-ui-scope); 14 REJECTED
- 13 of 14 Round-1 rejections were incorporated in commit 2b287d3 (2026-05-20 evening)
- 1 rejection was counter-argued in 2 disagreement docs (Round-2 evaluates them)
- 12 NEW artefacts shipped since Round 1: tenancy invariants, architecture cohesion
  review, tenant lifecycle, founder decision briefing, 2 disagreement docs, autosend
  approval bridge spec, PII purge operational pattern + script + migration SQL pair
- Skill softening D5 landed in commit 783c496 — Reference + In Force status artefacts
  are now exempt from Decision/Consequences sections (Context + Status line still
  required); see .codex/ratification/review-architecture-decision.md §1-Exemption
- Tenancy invariants and architecture cohesion review were authored as the
  audit + verification artefacts before Diagnostic agent build begins

STEP 1: LOAD THE TOP-LEVEL SKILL

Read .codex/ratification/SKILL.md in full. Apply the five rules + four boundaries
per its specification. Output contract: every verdict must start with literal
RATIFIED or REJECTED token.

STEP 2: REVIEW 26 ARTEFACTS

Use the type-specific skill named in the table below per artefact. Read the
artefact + apply both skills + decide.

For RATIFIED:
  Write your verdict + optional advisory notes (0-5 lines) to
  logs/codex-ratification/round-2-manual/<slug>.output.md

For REJECTED:
  Write your verdict + numbered list of issues to the same path. Each issue
  must cite specific lines + propose a concrete fix.

For Round-1-redux items (Tier 1): explicitly note whether the Round-1 issue
was incorporated. If the artefact is RATIFIED on Round 2 BUT the Round-1
issue is still present, REJECT — incorporation must be verifiable.

For disagreement docs (Tier 3 items 19 + 20): you are evaluating recursive
ratification per master brief §10.5. Decide whether Claude's counter-argument
holds OR whether the Round-1 Codex rejection was correct. If the disagreement
doc proposes a skill change (D5), evaluate the proposed change itself, not
just the disagreement framing.

TIER 1 — RE-RATIFY 14 ROUND-1 REJECTED (skill: review-architecture-decision):
  docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md
  docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
  docs/decisions/ADR-003-agent-bundle-renderer.md
  docs/decisions/bullhorn-integration-path.md
  docs/decisions/sequencing-target.md
  docs/decisions/autosend-safety-policy.md
  docs/architecture/cortexos-primitive-status.md
  docs/architecture/second-brain-design.md
  docs/architecture/agent-bundle-renderer-design.md
  docs/architecture/vault-concurrency.md
  docs/decisions/v1.0-kill-criterion.md
  docs/runbooks/operational-hygiene-protocol.md
  docs/verticals/recruitment/vertical-schema.yaml  (skill: review-schema-change)
  docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml  (skill: review-schema-change)

TIER 2 — DAY-9 NEW ARTEFACTS (skill: review-architecture-decision):
  docs/architecture/tenancy-invariants.md
  docs/architecture/architecture-cohesion-review.md
  docs/runbooks/tenant-lifecycle.md
  scripts/run-tenancy-audit.sh

TIER 3 — DAY-11 NEW ARTEFACTS:
  docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md  (review-architecture-decision; recursive)
  docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md  (review-architecture-decision; recursive)
  docs/decisions/2026-05-20-codex-round-1-founder-decisions.md  (review-architecture-decision)
  docs/decisions/autosend-approval-bridge-spec.md  (review-architecture-decision)
  docs/runbooks/pii-purge-operational-pattern.md  (review-architecture-decision)
  scripts/ifos-pii-purge.sh  (review-architecture-decision)
  docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql  (review-postgres-migration)
  docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql  (review-postgres-migration)

STEP 3: PRINT FINAL SUMMARY

Markdown table:
| Tier | Artefact | Round-1 verdict | Round-2 verdict | Issue count | Output file |

Totals:
  RATIFIED Round 2: <N>
  REJECTED Round 2: <N>
  Recursive disagreement RATIFIED: <0-2>
  Recursive disagreement REJECTED: <0-2>

STEP 4: SURFACE TOP REMAINING ISSUES

If any artefacts REJECTED in Round 2, identify the top 3 by severity (founder
attention required). For disagreement docs REJECTED: explicitly say whether
the rejection means Codex disagrees with Claude's counter-argument, OR
disagrees with the proposed skill change.

Begin now. Work through every artefact. Do not stop until all 26 are complete
and the summary is printed.
```

---

## §6 — Processing Round-2 results (per outcome class)

### Class 1: Round-1 REJECTED → Round-2 RATIFIED

This is the expected case for most Tier 1 items. Mark as ratified in the manifest queue table:

```sql
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
VALUES (
  'ifos-meta', '_codex_ratifier', 'output', 'RATIFIED-round-2',
  jsonb_build_object(
    'artefact_path', '<path>',
    'round_1_verdict', 'REJECTED',
    'round_2_verdict', 'RATIFIED',
    'incorporation_commit', '2b287d3',
    'session_id', '<round-2-session-id>'
  ),
  now()
);
```

Wrapper script does this automatically when in live mode.

### Class 2: Round-1 REJECTED → Round-2 REJECTED (regression / unresolved)

If Codex rejects a Tier 1 item again, two sub-cases:

**Sub-case 2a: Same issue as Round 1** — incorporation didn't actually fix the root cause. Escalate to founder; reopen as a fresh issue. Likely candidates: autosend-safety-policy (D1 + D3 unresolved); v0.2 supplement (D3 unresolved).

**Sub-case 2b: New issue surfaced** — incorporation introduced a different problem OR exposed a previously-masked issue. Write new disagreement doc OR direct fix. Re-run.

Hard ceiling: 2 round-trips (master brief §10.3 step 5). After Round 2, no Round 3 — escalate to founder for explicit decision.

### Class 3: New artefact → Round-2 RATIFIED

Expected for Tier 2 + most of Tier 3. Manifest queue marks as ratified. No further action.

### Class 4: New artefact → Round-2 REJECTED

Tier 2/3 artefact rejected on first encounter. Read Codex output carefully:
- If issue is concrete + fixable: edit + re-ratify in Round 3
- If issue is a founder decision: surface in next briefing doc update
- If issue is in Codex's interpretation: write disagreement doc

### Class 5: Recursive disagreement doc — Codex RATIFIES

Best case: Codex agrees with Claude's counter-argument. Founder Decision stands as Claude proposed. For D5 disagreement doc → Codex confirms skill softening was correct. Close.

### Class 6: Recursive disagreement doc — Codex REJECTS

Codex insists Round-1 rejection was correct OR insists the proposed skill change is wrong. **Founder escalation required.** Founder picks:
- Accept Codex (revert skill softening; retrofit ceremony onto audit/runbook artefacts)
- Accept Claude (skill softening stands; mark disagreement doc as "founder-overrode-Codex" and document)
- Compromise

---

## §7 — Post-Round-2 manifest closure

When Round 2 completes:

### Step 7.1 — Update manifest queue

`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5 + §1.6 — add per-artefact Round-2 verdict + disposition. Mirrors §1.5 Round-1 pattern.

### Step 7.2 — Close ratified items

For each Round-2 RATIFIED item: mark status field "RATIFIED-Round-2-2026-05-22" (or appropriate date) in the queue table. Item is now closed; no further ratification needed unless artefact changes.

### Step 7.3 — Surface remaining REJECTED items

Any Round-2 REJECTED items get their own row in the manifest queue updated to "REJECTED→ROUND-3-pending OR founder-escalated". Per §10.3 master brief: no Round 3 until founder decides.

### Step 7.4 — Update current-priorities.md + RISK-REGISTER.md

Day-XX Shipped section with Round-2 totals + remaining open items. RISK-REGISTER log entry.

### Step 7.5 — Commit + push

Single commit: `ops(codex-round-2): manifest closure + per-artefact verdicts + remaining open items`

---

## §8 — What "DONE" looks like

After Round 2 closes:

- **26 artefacts ratified or ratification-pending-founder** — every architectural decision + design + schema + runbook + spec + script + migration has been Codex-reviewed
- **0-2 disagreement docs resolved** — Codex either agreed (RATIFIED) or rebounded (founder-escalation)
- **Manifest queue reflects final state** — every queued item has a verdict
- **`decision_log`** has audit rows for every Round-2 review
- **No open ratification work** except for any founder-escalations from Class 6
- **Foundation is fully double-reviewed** — Diagnostic agent build can begin with maximum confidence

---

## §9 — Stopping rules (when to halt the run)

Stop Round 2 immediately if:

1. **Codex CLI crashes 3+ times** in a row on the same artefact (likely API issue; pause + retry tomorrow)
2. **Codex returns identical verdicts for unrelated artefacts** (possible context bleed; restart CLI)
3. **An RLS-related issue surfaces** that suggests tenancy invariants might be violated (escalate immediately; don't continue ratifying until tenancy audit re-passes)
4. **Disk fills** in `logs/codex-ratification/` (cleanup older sessions; restart)
5. **OPENAI_API_KEY rate-limited** or auth expired (re-auth; restart)

Otherwise: complete the run. Even if 5-10 items REJECT in Round 2, that's still data — better to surface all of them in one pass than to stop after the first.

---

## §10 — Cost estimate

Per master brief §10.6 + execution plan §5:

| Tier | Items | Mean time | Subtotal |
|---|---|---|---|
| 1 (re-ratify) | 14 | ~15 min (cached Round-1 context shortens these) | ~3h 30m |
| 2 (new) | 4 | ~20 min | ~1h 20m |
| 3 (new + recursive) | 8 | ~15 min (smaller artefacts) | ~2h |

**Total floor: ~6h 50m.** Realistic with 10-15% rejection-handling overhead: **~8h.** Spread across 2 sessions if needed.

OpenAI billing: GPT-5-codex tokens ~$3-5 per artefact at typical artefact size. Total: $80-130.

---

## §11 — After Round 2 closes

Founder action items remaining (per priority order):

1. **Engage SeedLegals** (~48h waiting; ~£500) — D2 + D3 resolution
2. **Run live VPS migration** (`bash scripts/run-live-migration.sh`) — ~30 min
3. **Run tenancy audit** (`bash scripts/run-tenancy-audit.sh`) — ~10 min
4. **Apply v0.2-to-v0.3-pii-purge.sql migration** + deploy cron (~1h after SeedLegals confirms retention)
5. **D1 timing decision** (Week 9 default vs insert-now) — ~5 min decision
6. **Diagnostic agent build slice begins** — first ratified-foundation v1.0 agent

If Round 2 surfaces founder-escalated items: resolve those before #6.

---

## §12 — Status

**Reference.** Self-contained operations protocol. Founder executes; this document is the source of truth for Round-2 mechanics.

Manifest queue position: this protocol document itself joins the queue as a Round-3 candidate (recursive ratification per master brief §10.5).

*End of Codex Round 2 handoff protocol.*
