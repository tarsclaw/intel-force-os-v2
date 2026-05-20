# Codex ratification — execution plan

**Status:** Reference (operations runbook).
**Author:** Founder (Maddox) + Claude Code, 2026-05-20 (Day 8 PM).
**Source artefacts:** master brief §10 (the loop) + `docs/decisions/2026-05-18-codex-ratification-manifest.md` (the queue) + this plan (the how).
**Replaces:** the Day-7 manifest's §4 "Schedule" stub — this plan IS the schedule.

---

## §1 — Why this loop matters (re-statement from master brief §10.1)

For a build of this scope, single-model reasoning is genuinely risky. Codex (`gpt-5-codex`) and Claude catch different classes of mistakes:

- **Claude tends to over-elaborate on architecture; Codex is more conservative.** I produce ratifiable artefacts; Codex reads them with fresh eyes.
- **Codex catches type/build issues more reliably; Claude catches semantic/specification issues.** The Day-8 5-phase slice has both: TypeScript types (Codex strong) + design-doc consistency (Claude strong).
- **Disagreements between the two are the most valuable signal.** Where Claude and Codex disagree on an artefact, the spec is ambiguous and needs a founder decision. The disagreement itself goes into `docs/decisions/codex-disagreement-<date>.md` — write it down; do not dissolve it.

**Goal of this loop, not just this run:** every ratified artefact has been reviewed by both models. The founder takes the diff between them as the highest-quality decision-input available.

---

## §2 — Precondition 0: fix the broken Codex CLI install

**Verified 2026-05-20:** `which codex` → `/opt/homebrew/bin/codex` exists, but invocation fails:

```
Error: spawn /opt/homebrew/lib/node_modules/@openai/codex/node_modules/@openai/codex-darwin-arm64/vendor/aarch64-apple-darwin/codex/codex ENOENT
```

The npm `postinstall` script that downloads the native binary did not complete. The `vendor/aarch64-apple-darwin/` directory contains only `path/rg` (ripgrep) — no `codex` binary.

**Fix procedure** (founder action, one-shot):

```bash
# 1. Reinstall — forces postinstall to run again
npm install -g @openai/codex --force

# 2. Verify the native binary exists
ls /opt/homebrew/lib/node_modules/@openai/codex/node_modules/@openai/codex-darwin-arm64/vendor/aarch64-apple-darwin/codex/codex

# 3. Verify codex executes
codex --version

# 4. Verify auth (Codex requires either OpenAI API key or ChatGPT login)
codex --help | head -20
```

Fallback if `--force` reinstall fails:

```bash
npm uninstall -g @openai/codex
npm cache clean --force
npm install -g @openai/codex
```

Worst case (postinstall consistently blocked): download the codex tarball manually from `https://github.com/openai/codex/releases`, extract the `codex` binary into the vendor path above. **Document the workaround in `.agents/learnings/00-cortextos-quirks.md` if used.**

**Cost:** ~5-10 min in the typical case; up to 30 min if postinstall is blocked by a corporate proxy or similar.

---

## §3 — Precondition 1: build the 7 `.codex/ratification/*.md` skills

Master brief §10.2 lists 7 skill files. None exist yet (Day-7 manifest §3 gap). Build them before first ratification run.

| File | What it ratifies | Estimated lines | Priority |
|---|---|---|---|
| `SKILL.md` | Top-level "what does ratify mean" + five rules + four boundaries | ~150 | **First** |
| `review-architecture-decision.md` | ADRs in `docs/decisions/` | ~200 | First (covers ADR-001/002/003/004 + decision artefacts) |
| `review-schema-change.md` | `vertical-schema.yaml` edits | ~150 | First (covers v0.1 + v0.2 supplement) |
| `review-postgres-migration.md` | New tables, RLS policy changes | ~200 | First (covers v0.1-to-v0.2.sql + Day-4 schema) |
| `review-agent-bundle.md` | The 6-file + 3-fixture pattern | ~250 | Pre-Diagnostic-W3 (not yet needed) |
| `review-mcp-connector.md` | New MCP connector checklist | ~200 | Pre-Janitor-W5 (not yet needed) |
| `review-harness-bump.md` | Pinned cortextos SHA bumps | ~150 | Lazy (no bumps planned) |

**Build the first four in this run** (~5-6 hours). They cover 100% of the current 34-item queue. Defer the bottom three to their natural trigger week.

### Skill shape (per master brief §10.2 last paragraph)

Each skill takes a diff or file set, checks against the five rules + the relevant spec doc, returns either:

- `RATIFIED` (with optional minor notes) — artefact merges as-is
- `REJECTED` (with concrete issues, numbered) — Claude Code addresses or counter-argues in disagreement doc

**Template structure for each skill file:**

```markdown
# Codex ratification skill — review-{type}

## What this skill checks
[1-2 paragraphs: scope of artefacts this skill applies to]

## Five-rule pass (master brief §1)
- [ ] Output before architecture
- [ ] Schema before code
- [ ] Reuse before build
- [ ] Quality gates before features
- [ ] Honest signal before optimistic projection

## Four-boundary pass (master brief §3)
- [ ] Submodule boundary (read-only on packages/harness/cortextos/)
- [ ] Adapter boundary (no Composio/AgentMail names in agent.md/tools.yaml/fixtures)
- [ ] Vault/Postgres split (markdown in vault; structured state in Postgres)
- [ ] Brain-replacement boundary (only the four bus/kb-*.sh shadow points)

## Spec-specific checks
[Type-specific checklist — e.g., for ADRs: are alternatives weighed; is status field present; is reduce-or-augment named explicitly]

## Output contract
RATIFIED | REJECTED:<numbered list of concrete issues>
```

---

## §4 — Queue map: 34 items in execution order

Per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1 + the Day-8 additions in `.agents/current-priorities.md`. 34 items total, clustered by skill-type for efficient batching (run each skill against its batch before context-switching).

### Cluster A — Architecture decisions (8 items, `review-architecture-decision.md`)

| # | Artefact | Path | Skill |
|---|---|---|---|
| 1 | ADR-001 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | A |
| 2 | ADR-002 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | A |
| 3 | ADR-003 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | A |
| 4 | ADR-004 (new) | `docs/decisions/ADR-004-renderer-implementation-deviations.md` | A |
| 5 | bullhorn-integration-path | `docs/decisions/bullhorn-integration-path.md` | A (Sub-decisions A+B Proposed; C Accepted) |
| 6 | sequencing-target | `docs/decisions/sequencing-target.md` | A |
| 7 | brain-ui-scope | `docs/decisions/brain-ui-scope.md` | A |
| 8 | autosend-safety-policy | `docs/decisions/autosend-safety-policy.md` | A |

### Cluster B — Reference designs + standards (6 items, `review-architecture-decision.md` adapted)

| # | Artefact | Path | Skill |
|---|---|---|---|
| 9 | cortexos-primitive-status (audit) | `docs/architecture/cortexos-primitive-status.md` | A |
| 10 | second-brain-design | `docs/architecture/second-brain-design.md` | A |
| 11 | agent-bundle-renderer-design | `docs/architecture/agent-bundle-renderer-design.md` | A |
| 12 | vault-concurrency | `docs/architecture/vault-concurrency.md` | A |
| 13 | v1.0-kill-criterion | `docs/decisions/v1.0-kill-criterion.md` | A |
| 14 | operational-hygiene-protocol | `docs/runbooks/operational-hygiene-protocol.md` | A |

### Cluster C — Schema artefacts (2 items, `review-schema-change.md`)

| # | Artefact | Path | Skill |
|---|---|---|---|
| 15 | vertical-schema v0.1 | `docs/verticals/recruitment/vertical-schema.yaml` | C |
| 16 | vertical-schema v0.2 supplement | `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` | C |

### Cluster D — Postgres migration artefacts (3 items, `review-postgres-migration.md`)

| # | Artefact | Path | Skill |
|---|---|---|---|
| 17 | Day-4 provisioning runbook | `docs/runbooks/day-4-provisioning.md` | D |
| 18 | v0.1-to-v0.2 migration | `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` | D |
| 19 | v0.2-to-v0.1 rollback | `docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql` | D |

### Cluster E — Runtime code + helpers (6 items — review against ADR shape, mostly via `review-architecture-decision.md` + skill-specific checklist)

| # | Artefact | Path | Skill |
|---|---|---|---|
| 20 | claude-md-preamble.md template | `packages/agent-renderer/templates/claude-md-preamble.md` | A |
| 21 | 8 common-*.json schemas | `packages/agents-runtime/_shared/common-*.json` | A (single batch review) |
| 22 | ESC catalogue | `agents/_shared/escalation-codes.md` | A |
| 23 | agent-renderer scaffold | `packages/agent-renderer/` (PR-scoped diff) | A |
| 24 | hook-helpers.sh + tests | `agents/_shared/hook-helpers.sh` + `tests/test-hook-helpers.sh` | A |
| 25 | autosend-policy.yaml | `agents/_shared/autosend-policy.yaml` | A |
| 26 | voice-loader.sh + tests | `agents/_shared/voice-loader.sh` + `tests/test-voice-loader.sh` | A |
| 27 | agents/_shared/README.md | `agents/_shared/README.md` | A |

### Cluster F — Recent commits (2 items — Codex reviews the diff, not the full file)

| # | Artefact | Path | Skill |
|---|---|---|---|
| 28 | Atomic-correction commit | `0e5b2b4` (11 master-brief edits) | A |
| 29 | Day-4 execution commit | `98c79b2` (Hetzner VPS provisioning) | D |

### Cluster G — Day-7 close artefacts (3 items)

| # | Artefact | Path | Skill |
|---|---|---|---|
| 30 | Single-sentence test | `docs/decisions/2026-05-18-day-7-single-sentence-test.md` | A |
| 31 | Codex ratification manifest (recursive) | `docs/decisions/2026-05-18-codex-ratification-manifest.md` | A |
| 32 | This execution plan (recursive) | `docs/operations/codex-ratification-execution-plan.md` | A |

### Cluster H — gstack pin (1 item)

| # | Artefact | Path | Skill |
|---|---|---|---|
| 33 | gstack install pin | `.agents/learnings/gstack-pin.md` | A (advisory only — dev tool, not product) |

### Cluster I — Wrapper script (1 item, new)

| # | Artefact | Path | Skill |
|---|---|---|---|
| 34 | Live-migration wrapper | `scripts/run-live-migration.sh` | A |

**Total: 34 items.** Five items (Sub-decisions A+B in bullhorn-integration-path, brain-ui-scope as Proposed, items pending founder pre-resolution per Day-7 manifest §6) are reviewed as-is — Codex may flag the Proposed status as a non-blocking observation.

---

## §5 — Per-artefact cost model + total time estimate

Per master brief §10.6 — mean cost is 20-30 min per artefact including the round-trip. Cluster batching reduces context-switching cost.

| Cluster | Items | Est. mean (incl. round-trip) | Total |
|---|---|---|---|
| A — Architecture decisions | 8 | 25 min | **3h20m** |
| B — Reference designs | 6 | 25 min | **2h30m** |
| C — Schema | 2 | 30 min | **1h00m** |
| D — Postgres migrations | 3 | 30 min | **1h30m** |
| E — Runtime code | 8 | 20 min | **2h40m** |
| F — Recent commits | 2 | 15 min (diff-only) | **0h30m** |
| G — Day-7 close | 3 | 15 min | **0h45m** |
| H — gstack pin | 1 | 10 min (advisory) | **0h10m** |
| I — Wrapper | 1 | 15 min | **0h15m** |

**Total floor estimate: ~12h30m of focused ratification work.** Realistically, with disagreement handling on ~10% of artefacts (3-4 items at 30-60 min each), allow **15-18 hours total** across the queue.

**Recommended cadence:**
- One cluster per session
- Cluster A first (architecture is upstream of everything)
- Cluster D before Cluster I (migration ratification gates the wrapper that runs it)
- Cluster E last for the runtime code that depends on A+C+D being settled

**Founder can spread across 3-5 days.** Codex review is not parallelisable to multiple sessions — context lives in the Codex CLI's transient state, not in shared storage.

---

## §6 — Execution commands (verbatim)

### 6.1 — Per-artefact invocation

```bash
codex review \
  --skill .codex/ratification/review-{type}.md \
  --target <path-or-diff> \
  > ratification-output.md
```

Where:
- `{type}` ∈ {architecture-decision, schema-change, postgres-migration, agent-bundle, mcp-connector, harness-bump} per §3 table
- `<path-or-diff>` is either a file path (full-artefact review) or `<git-ref-A>..<git-ref-B>` (diff-only review)

### 6.2 — Cluster batch invocation (multiple artefacts, same skill)

```bash
for artefact in "${cluster_a_artefacts[@]}"; do
  echo "=== ${artefact} ===" >> cluster-a-output.md
  codex review \
    --skill .codex/ratification/review-architecture-decision.md \
    --target "${artefact}" \
    >> cluster-a-output.md
  echo "" >> cluster-a-output.md
done
```

### 6.3 — Capture results to `decision_log` (audit trail)

Each Codex review run writes a row to `decision_log` per master brief §8.1 Change 2 audit policy. The row schema:

```sql
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload)
VALUES (
  'ifos-meta',                            -- meta-tenant for system events
  '_codex_ratifier',                      -- sentinel agent name
  'output',                               -- phase
  'RATIFIED' or 'REJECTED',               -- outcome
  jsonb_build_object(
    'artefact_path', $1,
    'skill_used', $2,
    'codex_response_text', $3,
    'issue_count', $4,                    -- 0 if RATIFIED; N if REJECTED
    'round_trip', $5,                     -- 1 or 2 per §10.3
    'session_id', $6                       -- ties multiple artefacts in one Codex session
  )
);
```

A small helper script `scripts/ratification-record.sh` can wrap this. Defer to founder preference — manual `psql` invocation is fine if the queue is < 50 items.

### 6.4 — Disagreement artefact

When Codex REJECTS and Claude Code either incorporates feedback OR counter-argues, write to:

```
docs/decisions/codex-disagreement-<YYYY-MM-DD>-<short-slug>.md
```

Template:

```markdown
# Codex disagreement — <artefact name>

**Date:** <ISO date>
**Artefact:** <path>
**Skill:** <skill file>
**Codex outcome:** REJECTED
**Codex's numbered issues:** <verbatim from Codex output>
**Claude's response:** <numbered, paragraph per issue>

## Resolution

[ ] Incorporated (Codex correct; Claude updates artefact + commits + re-runs review)
[ ] Counter-argued (Claude believes Codex is wrong; founder decision required)
[ ] Compromise (partial accept; both Claude + Codex update the artefact)

## Founder decision (if escalated)

<written by founder; specifies which option wins + why>
```

---

## §7 — Round-trip protocol (≤2 round-trips per artefact)

Per master brief §10.3 step 5:

1. **First round:** Codex reviews artefact → returns RATIFIED or REJECTED.
2. **If REJECTED:** Claude Code reads issues + either:
   - **Incorporates** — updates artefact + commits + re-runs review. **Second round must RATIFY for merge.**
   - **Counter-argues** — writes disagreement doc per §6.4. Re-runs review pointing Codex at the disagreement doc as additional context.
3. **If second round still REJECTED:** escalate to founder. Founder picks: incorporate Codex's view, override Codex, or revise the spec the artefact is based on.

**Hard ceiling: 2 round-trips per artefact.** Don't enter a third round-trip loop — the disagreement is structural and needs founder decision-input.

---

## §8 — Disagreement handling — the load-bearing pattern

**The disagreement IS the signal.** Master brief §10.1 explicitly: "Disagreements between [Claude and Codex] are the most valuable signal — that's where the spec is ambiguous and needs founder decision."

**Categories of expected disagreement:**

1. **Spec ambiguity** — both models can defensibly interpret the spec different ways. Disagreement → founder clarifies the spec, then both can re-review. Most common.
2. **Implementation taste** — neither interpretation is "right"; both are valid. Disagreement → founder picks the one they prefer + commits a brief rationale. Cheap.
3. **Type/correctness** — Codex catches a real bug Claude missed. Disagreement → Claude accepts, fixes, re-reviews. Cheap.
4. **Spec drift** — Codex reviews an artefact that's based on a now-stale version of the master brief. Disagreement → update the master brief OR the artefact; re-review. Moderately expensive.

**Worth tracking for retro:** category mix on first run. If category 1 dominates, the master brief needs sharpening. If category 4 dominates, the atomic-correction discipline is failing.

---

## §9 — Schedule + when to start

### Gate: Q1 design partner LOI status

Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.

**Decision point on starting Codex ratification:**

- **Option α** — Start immediately. Rationale: 33 items are already queued; Q1 turning YES will only ADD items (Diagnostic + Janitor + downstream). The 34-item queue is largely about Week 0 design artefacts that won't change post-LOI. Get them ratified now while context is fresh.
- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
- **Option γ** — Start the **invariant cluster** (A + B + C) now; defer code-cluster (E) until Q1 = YES. Architecture + reference designs + schema are spec-driven and don't shift with commercial conversations. Code review is cheap to redo if helpers change. Compromise of α + β.

**Founder bias documented (carry-forward from Day-7 manifest):** Option C (deferred) was chosen at Day-7. With the Day-8 5-phase slice landed, **revise to Option γ** — start clusters A + B + C this week; defer clusters D-I until Q1 + the live VPS migration both complete.

### Cluster sequence (Option γ)

| Phase | Cluster | Trigger |
|---|---|---|
| 1 | Build 4 skill files (SKILL.md + architecture-decision + schema-change + postgres-migration) | After codex CLI reinstall (Precondition 0) |
| 2 | Cluster A (8 ADRs + decisions) | After Phase 1 |
| 3 | Cluster B (6 reference designs) | After Phase 2 |
| 4 | Cluster C (2 schema artefacts) | After Phase 3 |
| 5 | **PAUSE** | Until live VPS migration executes (`bash scripts/run-live-migration.sh`) |
| 6 | Cluster D (3 migration artefacts) | After live migration completes successfully |
| 7 | Cluster E (8 runtime code items) | After Cluster D |
| 8 | Cluster F (2 commit diffs) | After Cluster E |
| 9 | Cluster G + H + I (5 leftover artefacts) | After Cluster F |
| 10 | Build remaining 3 skills (agent-bundle + mcp-connector + harness-bump) | Lazy — at first invocation need |

Phase 1-4 are 1-2 sessions of focused work. Phases 6-9 land after live migration + Q1 LOI. Phase 10 is lazy.

---

## §10 — Post-ratification close protocol

For every ratified cluster:

1. **Update `current-priorities.md`:** mark cluster as ratified + record `RATIFIED` outcome counts vs `REJECTED → re-ratified` vs `REJECTED → counter-argued`.
2. **Update `RISK-REGISTER.md`:** if Codex flagged any new risks not on the register, append them. Codex's risk-spotting catches things Claude under-weighs.
3. **Commit `decision_log` rows** (per §6.3) — these become the audit trail for the ratification run.
4. **If any disagreement artefacts exist:** founder decides + writes resolution. Updates artefact + re-runs review for full closure.
5. **Update `docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue table: status column flips from "queued" to "RATIFIED-<date>" or "REJECTED+resolved-<date>".

After the full 34-item queue completes:

6. **Codex ratifies this execution plan itself** (item #32) — recursive. Plan is updated based on the run-retro feedback.
7. **Master brief §10.6 timeline updated** with actual cost vs estimate. Founder-facing artefact.
8. **`current-priorities.md` Codex queue section deleted** or marked "first run complete" with pointer to the manifest for full audit trail.

---

## §11 — Failure modes + recovery

### 11.1 — Codex CLI crashes mid-review

Symptom: `codex review` exits non-zero with stack trace.

Recovery: capture stderr in `codex-crash-<timestamp>.log`. Re-run the single artefact. If reproducible: report to OpenAI, defer that artefact to manual founder review.

### 11.2 — Codex output is contradictory or nonsensical

Symptom: Codex says RATIFIED but the response text contains numbered issues.

Recovery: treat as REJECTED; proceed to round-trip 2 with the original concrete issues. If round-trip 2 also produces contradictory output, escalate to founder.

### 11.3 — Round-trip 2 still REJECTED + Claude can't counter-argue

Symptom: Claude reads issues + agrees Codex is right but the fix requires founder input (e.g., a Proposed sub-decision flipping to Accepted requires commercial conversations).

Recovery: write disagreement doc with `Resolution = [ ] Escalated to founder`. Add to founder's open-decisions list in `current-priorities.md`. Move to next artefact; return after founder resolves.

### 11.4 — Cost massively exceeds estimate

Symptom: cluster A taking 6+ hours instead of 3h20m mean.

Recovery: PAUSE the queue. Run a retro on cluster A — was it disagreement cost, spec drift, or Codex-CLI slowness? Adjust cluster boundaries OR push remaining clusters to a different session. Don't power through a broken cadence.

---

## §12 — What's explicitly NOT in this plan

- **Pre-ratification editorial sweep** — Codex is the editorial review; Claude doesn't pre-clean artefacts hoping Codex won't catch the issue. Honest artefacts in; honest feedback out.
- **Custom Codex prompting beyond the SKILL.md** — the skill IS the prompt. If a skill needs tightening based on first-run feedback, update the skill + re-ratify the affected artefacts.
- **Multi-model ratification (e.g., adding Gemini)** — v1.0 is Claude + Codex per master brief §10. Multi-model is v2.0+ if signal justifies.
- **Automated CI Codex review on PR** — manual founder-triggered for v1.0. CI integration is a v1.1+ optimisation; the manual loop is enough at this scale.
- **Codex review of `agents/_shared/` runtime code via agent-bundle skill** — the 8-file `_shared/` set is reviewed under `review-architecture-decision.md` because it's not an agent bundle, it's the helper layer. Future agents (Diagnostic W3+) will be reviewed under `review-agent-bundle.md` once that skill exists.

---

## §13 — Outputs of first ratification run

When the first run completes (Clusters A + B + C — the immediate-actionable subset):

1. **16 artefacts marked RATIFIED or RATIFIED-with-minor-notes** in the manifest queue table.
2. **0-3 disagreement docs** at `docs/decisions/codex-disagreement-*.md`.
3. **`decision_log` rows** for every artefact reviewed — audit trail per master brief §10.6.
4. **Risk register may update** — new risks Codex spots that Claude under-weighted.
5. **Master brief edits queued** — if Codex flags spec drift, the next atomic-correction commit picks them up.
6. **This plan updated** — actual cost vs estimate; cadence retro; skill-file iterations.

**Next ratification run** (post-Q1, post-live-migration): clusters D-I, ~6 hours of work.

---

## §14 — Founder decisions surfaced

Three decisions the founder makes during this plan's execution:

1. **Now: choose Option α / β / γ for when to start** (recommendation: γ — start Clusters A+B+C this week).
2. **Now: fix the Codex CLI install** (Precondition 0 above) — gating step.
3. **During run: resolve any disagreements** (per §8 categories 1 + 2) — typically <30 min per disagreement.

No other founder-action items in this plan.

---

*End of execution plan.*
