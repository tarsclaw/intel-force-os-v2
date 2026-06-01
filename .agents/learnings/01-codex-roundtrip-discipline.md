# Learning 01 — Codex round-trip discipline (hard ≤2 ceiling)

**Established:** 2026-06-01 (W4 Day-26) after the 2026-05-31 cluster-E migration sequence ran R1 → R2 → R3 and required founder arbitration to stop.
**Authority:** Master brief §10.3 step 5 ("≤2 round-trips per artefact; if still REJECTED after Round 2, escalate via founder-decision doc").

## The rule (canonical)

**For any artefact submitted to a Codex ratification cluster: maximum two round-trips.** Round 1 surfaces findings; Round 2 (after author closes the findings) confirms RATIFIED or returns residuals. If Round 2 still REJECTs, **STOP**. Write a `docs/decisions/codex-disagreement-YYYY-MM-DD-<topic>.md` per the Day-11 pattern; route to founder arbitration; never run Round 3.

## Why this rule exists

The ceiling protects against three failure modes the migration sequence demonstrated:

1. **Diminishing returns.** R1 caught 4 findings on the migration; R2 caught 2; R3 caught 1. The cost-per-finding climbs as findings shrink — each round costs the same Codex budget but yields less. After 2 rounds, returns flatten and the founder's arbitration is faster than another mechanical loop.
2. **Author cognitive drift.** Every Codex round forces the author (me) to fix something and re-submit. By Round 3 the author's mental model of the artefact diverges from the final state — I caught myself introducing fresh citation drift in R2 ADR-007 (`line 320` should have been `line 326`) AND R2 v0.3 supplement (missing the 3rd Sourcing Scout R+W site at lines 421-428). Both were drift introduced BY my R1 fixes, surfaced by Codex R2. A third round risks compounding this.
3. **Rule-credibility erosion.** A rule that's bent "just this once" stops being a rule. The migration's R3 was justified case-by-case ("findings are trivial"; "we're converging not looping"). Each justification is plausible in isolation; together they erode the discipline that makes Codex review valuable.

## What happens when you'd want a third round

If R2 returns REJECTs that are mechanical citation/idempotency/wording drift and Codex has spelled out the exact fix: it's tempting to "just close them and re-run." DON'T. Two clean paths:

**Path A: Apply the fixes + STOP (no R3).** Mark the artefact as "Codex R2 findings closed at commit `<SHA>`; re-ratification deferred per §10.3 ceiling to next natural touch." Document the gap honestly in `current-priorities.md`. This is what 2026-05-31 did for the migration rollback path (commit `0f4ce8d` applied the fix; re-ratification deferred to "next natural touch is live VPS apply OR v0.4 work begins").

**Path B: Write a disagreement doc.** If R2's findings are substantive (not mechanical) — Codex challenges a master-plan-cited decision, or surfaces a design tension the author didn't see — write `docs/decisions/codex-disagreement-YYYY-MM-DD-<topic>.md` per the Day-11 pattern. Founder arbitrates; the disagreement doc becomes the audit-trail record of why we didn't iterate further.

Both paths preserve the discipline. Neither runs R3.

## What broke the rule on 2026-05-31 (the migration)

The cluster-E migration crossed the ceiling. Founder explicitly authorized R3 ("findings spelled out, fix is trivial, let's close"). Honest read with hindsight:

- R3 caught 1 real finding (rollback `to_regclass` guards) that R2 hadn't seen — so the rule's "diminishing returns" argument was technically broken (R3 was productive).
- BUT: each round trip costs Codex usage budget. The founder hit limits during cluster-E. We were lucky usage came back.
- The right call at R2 would have been: close R2 findings, defer the rollback re-ratification to the next natural touch, accept 8/9 RATIFIED + 1 fix-applied as the substantive close. We did that AT R3, not at R2 — which means we paid the R3 Codex cost we should have skipped.

## How to enforce going forward

When authoring or applying a Codex ratification cluster:

1. **Before R1**: invest extra effort in the artefact. Use the type-skill (e.g., `review-mcp-connector.md`) as a self-checklist before submission. Most R1 findings are catchable this way.
2. **After R1**: close findings precisely (re-grep cited line numbers AFTER edit; the R2 ADR-007 drift was avoidable). Verify the fixes don't introduce new drift before submitting R2.
3. **After R2**: if RATIFIED, done. If REJECTED with mechanical findings: apply per Path A — close + stop + defer re-ratification, never R3. If REJECTED with substantive disagreement: Path B — disagreement doc.
4. **Founder over-rides**: only allowed via an explicit written waiver in the founder-action queue, citing why this artefact is the exception. Don't waive the rule case-by-case in chat without documenting why; that's how rules erode.

## Related

- Master brief §10.3 step 5 (canonical rule statement)
- `docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md` (Day-11 pattern; the canonical disagreement-doc example)
- `docs/operations/decision-log.md` "W4 Day-25 (2026-05-31) — Codex Round 1 closed" + "W4 Day-25 R2" sections (the migration sequence narrated in full)
- `.codex/ratification/SKILL.md` §6 (bias toward REJECT — Codex's own discipline)
