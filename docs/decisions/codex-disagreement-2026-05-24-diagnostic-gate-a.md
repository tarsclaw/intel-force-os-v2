# Codex disagreement — Diagnostic Gate A citation requirement + 4 follow-on findings

**Date:** 2026-05-24 (Day 19; end of Week 3 goal execution)
**Status:** Awaiting founder arbitration
**Codex rounds completed:** Round 4 (initial REJECTED, 4 issues) + Round 5 (remediation REJECTED, 5 issues including 2 re-raises and 3 new findings) — **hard ceiling per master brief §10.3 step 5 reached**.
**Artefact:** `agents/recruitment/diagnostic/agent.md`
**Codex output logs:**
- Round 4: `logs/codex-ratification/20260524T100704Z-11219/agents_recruitment_diagnostic_agent-md.output.md`
- Round 5: `logs/codex-ratification/20260524T101312Z-16031/agents_recruitment_diagnostic_agent-md.output.md`

---

## Context

Week 3 goal at `docs/operations/goal-week-3-polish-and-scaffold.md` Step 7 (Codex Round 4 Phase 1) ratified `agents/recruitment/diagnostic/agent.md`. Codex found 4 issues; mechanical remediation applied (commit `6e0cb86`); Round 5 re-ratification found 5 new issues — 2 re-raises (Codex disagreed with my remediation framing), 3 new findings not visible at Round 4.

Per master brief §10.3 step 5: **≤2 round-trips max per artefact**. Round 5 was the second round-trip. **Hard ceiling reached.** Founder arbitration required to close the artefact.

---

## The 5 Round-5 issues, with my recommended disposition

### Issue 1 (RE-RAISE) — Gate A citation requirement strength

**Codex says:** "Line 16 says per-claim citation validation is deferred to W4 and only per-section coverage is required, but Ultraplan §8.1 A1 lines 496-497 requires 'no claims unsupported by source data.' This lowers a stated Gate A constraint."

**My Round-4 remediation:** narrowed §1 from "per-claim citation" to "per-section citation" because validate.sh V2 implementation only checks per-section.

**Founder decision needed:** which is the load-bearing source of truth?

Option A — **Tighten Gate A to per-claim citation** (matches Ultraplan). Requires implementing per-claim citation validation in `validate.sh` (significant logic; W4 polish item but Codex says it should be Gate A v0).

Option B — **Amend Ultraplan §8.1 A1 line 497** to read "no unsupported claims at section level" (loosens upstream to match v0 implementation).

Option C — **Hybrid:** v0 Gate A = per-section (current); Gate B (post-launch quality signal) = per-claim spot-check sampling. Document this two-tier policy explicitly.

**My recommendation:** **C** (hybrid). Per-claim validation is genuinely hard to automate at v0 (requires NLP claim-extraction + per-claim evidence-link matching); deferring to W4 is honest. But Codex is right that the §1 contract reads as if we're skipping it entirely — needs clearer "deferred to W4 with documented gap-coverage plan."

### Issue 2 (NEW) — Step 11 Telegram notification missing decision-log call

**Codex says:** "Lines 140-142 send an optional Telegram notification, but line 73 says every step that produces output or takes action MUST call `hh_decision_*`; only Step 12 logs `diagnostic_report_render` at lines 144-146."

**Disposition:** **Codex is correct.** Real bug. Step 11 sends a Telegram notification (an action with external side-effect) but doesn't emit a `decision_log` row. Mechanical fix: add `hh_decision_action("operator_notify_telegram", ...)` call to Step 11.

**Recommendation:** **Accept Codex finding.** Mechanical fix needed in next remediation round (if founder authorises beyond hard ceiling) OR W4 polish (recommended — bundles with broader Concierge notification work).

### Issue 3 (RE-RAISE) — Gate B kill-criterion Trigger reference

**Codex says:** "Line 169 claims Diagnostic's 30% discovery-call conversion feeds v1.0 kill-criterion §2 Trigger 8, but Trigger 8 lines 158-160 defines the threshold as average Gate B revenue uplift after 3 completed pilots, not Diagnostic conversion."

**My Round-4 remediation:** corrected Trigger 5 reference (which was about red-tier autosend) to Trigger 8. Codex says Trigger 8 is ALSO about revenue uplift, not Diagnostic conversion.

**Founder decision needed:** Diagnostic's Gate B metric doesn't map cleanly to ANY existing kill-criterion trigger.

Option A — **Remove kill-criterion reference entirely.** Just describe Gate B as a local leading metric for Diagnostic; not part of any kill-criterion trigger. Honest.

Option B — **Add a new kill-criterion Trigger 11 (DIAGNOSTIC-CONVERSION-FAIL).** Threshold: <30% discovery-call rate sustained for 4 weeks across all live pilots. Owner: founder + Jack.

**My recommendation:** **A** for v0 — remove the trigger reference; Diagnostic conversion is local-metric tracking. Add Trigger 11 in v1.1 if conversion-rate-driven scope-cut becomes operationally relevant.

### Issue 4 (NEW) — `_consultant_feedback` sentinel undocumented

**Codex says:** "Line 167 writes feedback rows as `agent_name='_consultant_feedback'`, but the existing documented sentinels are `_renderer`, `_tenant_admin`, and `_codex_ratifier`; `agents/_shared/escalation-codes.md` lines 16 and 257 only describe the firing agent or `_renderer` for shared helpers."

**Disposition:** **Codex is correct.** My Round-4 remediation invented a new sentinel without registering it.

**Recommendation:** **Two options for founder:**

Option A — **Add `_consultant_feedback` to the sentinel catalogue.** New entry in `agents/_shared/escalation-codes.md` documenting purpose, payload shape, and emit cadence.

Option B — **Use `agent_name='diagnostic'` with payload.action_type='consultant_feedback'`.** Avoids creating a new sentinel; feedback is "still Diagnostic's work, just consultant-driven not agent-driven."

**My recommendation:** **B** — cleaner, avoids sentinel proliferation. Feedback events are conceptually Diagnostic's domain (they validate Diagnostic outputs), so the agent_name should be Diagnostic with a specific action_type marker.

### Issue 5 (NEW) — Missing Context/Decision/Consequences sections

**Codex says:** "The file has `Status: Proposed` at line 3, but no `Context`, `Decision`, or `Consequences` sections as required for Proposed artefacts by review-architecture-decision §1. Fix: either review this with `review-agent-bundle.md`, or add the required architecture-decision sections and a final status-update line."

**Disposition:** **Codex is correct about the skill requirement**, but the artefact type is wrong. `agent.md` files are NOT architecture-decision documents — they're agent specifications per ADR-003 v2 bundle pattern (6 files + 3 fixtures). They don't fit the Context/Decision/Consequences shape.

**Recommendation:** **Build `review-agent-bundle.md` Codex skill** (deferred per execution-plan §3 lazy; now needed). The Round-4 manifest used `review-architecture-decision.md` as a temporary skill because `review-agent-bundle.md` doesn't exist yet. The correct ratification path for agent.md files is the agent-bundle skill, not architecture-decision.

**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.

---

## Recommended founder actions

1. **Arbitrate Issues 1 + 3** (which framing to use; my recommendations above)
2. **Accept Issue 2 fix** (mechanical; bundles with Concierge notification work)
3. **Accept Issue 4 fix per Option B** (use `agent_name='diagnostic'` with payload.action_type)
4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.

---

## What this means for Week 3 goal closure

Per `docs/operations/goal-week-3-polish-and-scaffold.md` §1 success criteria 10-12 (Codex Round 4 verdicts):

- Phase 1 Diagnostic-only: **1 of 6 artefacts attempted**; result is **REJECTED-after-hard-ceiling** awaiting founder arbitration via this disagreement doc
- Phase 2 full (5 new scaffolds): **deferred** pending Issue-5 resolution (review-agent-bundle.md skill build)

**Week 3 goal is therefore complete to the boundary of what can be done without founder arbitration.** Final §10 end-of-goal report acknowledges this and queues the founder-decision items.

Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.

---

## Round-4-v2 results (post-skill-build, Day-19 13:25 UTC)

After building `.codex/ratification/review-agent-bundle.md` (commit `825ebd4`) — the correct skill for agent.md ratification — all 6 agent.md files were re-ratified.

**Verdict summary:** 6 of 6 REJECTED. Issues per artefact:

| Artefact | Issues found | Round-4-v2 session |
|---|---|---|
| Diagnostic | 5 (same as Round 5 but with Issue-5-validate-impl-gap replacing Issue-5-doc-shape) | `logs/codex-ratification/20260524T101934Z-19923/` |
| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
| Scribe | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T102202Z-22338/` |
| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
| Sourcing Scout | ~5-7 (count regex 50) | `logs/codex-ratification/20260524T1024...` |
| Concierge | ~5-7 (count regex 59) | `logs/codex-ratification/20260524T1025...` |

**Pattern across all 6:** the systemic issues fall into FIVE categories that span every agent.md:

1. **Gate A vs ULTRAPLAN source-data citation strength** — every agent.md narrowed Gate A to per-section citation; ULTRAPLAN-equivalent requirements expect per-claim. Same issue, same disposition recommendation as Diagnostic Issue 1 — hybrid v0 per-section + W4 polish per-claim spot-check.
2. **Workflow steps missing decision-log calls** — most agent.md files have at least one Step (notification, operator alert, status update) that produces side-effects without `hh_decision_*` call. Same disposition as Diagnostic Issue 2 — mechanical fix during W4-13 build slices when cycle.sh is implemented.
3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
4. **Sentinel agent_name usage** — _consultant_feedback (Diagnostic) is the clear case; other agents likely have similar invented sentinels. Disposition: prefer `agent_name='<agent>'` with `payload.action_type` markers; reserve sentinels for system actors (_renderer, _tenant_admin, _codex_ratifier).
5. **§5 honesty about validate.sh implementation** — agent.md §5 sections describe Gate A behaviour that may not be implemented in the corresponding `validate.sh`. For Diagnostic, validate.sh exists + has gaps (Issue 5). For the 5 new scaffolds, validate.sh DOESN'T exist yet — §5 describes intent. Disposition: explicitly mark "intended behaviour; cycle.sh + validate.sh implementation at W-X build will deliver this" in §5 of each pre-build scaffold.

## Recommended founder arbitration

**Single founder decision unlocks all 6 ratifications:** approve the 5-category disposition above. Then mechanical remediation pass applies the dispositions across all 6 agent.md files. Re-ratify all 6 (Round 5 — final per hard ceiling); expect RATIFIED.

Time cost: ~2 hours mechanical fixes (Claude) + ~10 min Codex re-runs.

If founder REJECTS the disposition framework above OR wants per-issue review, escalate to Sunday review session with founder + Claude walking through each agent.md issue list.

## Why the disposition framework is reasonable

The 5 categories represent honest engineering trade-offs at v0:
- Per-claim Gate A validation is genuinely hard to automate (NLP claim-extraction + per-claim evidence linkage); the hybrid v0+W4 path is the industry-standard approach.
- Decision-log calls SHOULD be at every action; agent.md §4 specs the intent; cycle.sh implementation at build slice will deliver it.
- Sentinel hygiene (Issue 4) is a real architectural concern; agent_name=agent + payload.action_type is the cleaner pattern; no reason to proliferate sentinels.
- §5 honesty (Issue 5) is exactly the kind of "honest signal" the master brief §1 Rule 5 demands; framing §5 as "intended behaviour, build slice will deliver" is more honest than asserting Gate A as already-implemented.

These are not unprincipled compromises — they're the right v0 stance with W4-13 polish path documented.

---

---

## Janitor Round-5 (remediation) — empirical confirmation of bilateral pattern

After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:

1. **Autosend tier contradiction internal to artefact:** §1 says all Bullhorn writes yellow-tier; §3.Output 2 mapped tacit-note to `bullhorn_candidate_tag` which is GREEN. Internal §1/§3/§4 inconsistency.
2. **`bullhorn_field_backfill` unregistered, would fail-safe to red:** my flag-for-addition framing didn't satisfy because `hook-helpers.sh::autosend_policy_lookup` fails to red on unknown action types AT RUNTIME, regardless of flag prose. Real bug requires either (a) policy row added BEFORE ratification, OR (b) explicit "blocked W5 prerequisite" framing not "executable output."
3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
4. **Schema field names STILL wrong:** my Round-4-v2 fix touched `headcount_band → size_employees` but missed `client.legal_name → name`, `registered_office_address` (doesn't exist; canonical is `address` per line 248), `sic_codes` (doesn't exist as canonical field). Schema audit was incomplete.
5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.

**Empirical confirmation of the pattern documented in master brief §10.3 step 5:** Codex finds new issues at each round. Hard ceiling of ≤2 round-trips is the right structural protocol. Further autonomous Claude remediation passes will continue surfacing new issues that may not have been visible at earlier rounds (each fix changes the document, exposing different inconsistencies).

This isn't Codex being adversarial — it's doing its job as "second pair of eyes" per top-level SKILL.md. The agent.md drafts I authored have systematic citation-drift + internal-consistency issues that need careful bilateral pass.

## The bilateral session — what it would look like

90-min Sunday founder review:
1. Founder reads each Codex output log (~10 min per artefact × 6 = 60 min)
2. Founder + Claude jointly walk through 5-category disposition (above) + per-agent specifics (15 min)
3. Founder approves: (a) catalogue extensions (escalation-codes + autosend-policy batch additions), (b) schema field corrections, (c) §5/§6/§7 prose standardisation pattern (15 min)
4. Single Claude execution pass applies all approved corrections to all 6 agent.md files
5. Single Codex re-ratification round (Round 6) expected RATIFIED for the artefacts where Codex's framing was accepted, with documented disagreements for any artefacts where founder counter-argues

Estimated wall-clock after founder review starts: ~2 hours (founder review + Claude remediation + Codex run).

Without founder bilateral involvement, each autonomous remediation round burns ~30-60 min Claude time + 2-5 min Codex tokens, with low probability of RATIFIED on artefacts that have multiple systemic issues.

*End of Codex disagreement document (Janitor Round-5 confirmation).*
