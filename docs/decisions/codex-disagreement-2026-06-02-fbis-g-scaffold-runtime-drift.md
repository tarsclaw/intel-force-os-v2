# Codex disagreement — Cluster Fbis + G hard-stop after 4 rounds (partial ratification)

**Status:** Counter-argument accepted (founder-authorized 2026-06-02 via AskUserQuestion); cluster Fbis + G CLOSED at partial-ratification per the pre-agreed escalation rule.
**Date:** 2026-06-02.
**Author:** Claude Code (autonomous; founder approved hard-stop with explicit AskUserQuestion).
**Codex sessions:** Fbis R1 `20260602T113548Z-53909` → R2 `20260602T121515Z-75910` → R3 `20260602T123841Z-89338` → R4 `20260602T131006Z-7889`. G R1-R4 same dates.

## What we ratified, what we didn't

| Artefact | Cluster | Final state |
|---|---|---|
| `agents/recruitment/cash-conductor/agent.md` (bundle layer) | Fbis | **Proposed-with-disagreement-on-file** (this doc) |
| `agents/recruitment/concierge/agent.md` (bundle layer) | Fbis | **Proposed-with-disagreement-on-file** (this doc) |
| `docs/decisions/2026-05-31-d1-founder-decision.md` | G | **Proposed-with-disagreement-on-file** (this doc) |

Both Cash Conductor + Concierge agent.md were ratified at the **contract layer** in W3 cluster E (8/9 + 1 fix-applied per the cluster E session log). What R1-R4 of Fbis attempted to ratify was the **bundle layer** (now that sibling files cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures exist alongside the contract). That ratification did not converge in 4 rounds.

## Why 4 rounds didn't converge

Across 4 rounds:

| Round | Issues | Of which "my fault" (piecemeal-fix-introduced) |
|---|---|---|
| R1 | 11 | ~3 (line citation drift from prior unrelated edits) |
| R2 | 10 | 4 (sloppy touch-only-flagged-lines fixes from R1) |
| R3 | 10 | ~5 (claims I wrote in agent.md that contradicted code I'd also written in different sessions) |
| R4 | 8 | 6 (piecemeal fixes continued — missed Cash Conductor fixtures, missed Concierge §9 Q1, invented context.sh line citations, didn't extend grep-anchor pattern from agent.md to tools.yaml, didn't cross-update Concierge agent.md when D1-B Path-A reframing landed) |

**Pattern: my fix-discipline can't keep long cross-referenced documents internally consistent across multiple rounds of hand-edits.** Codex was doing real work — finding genuine drift between agent.md claims and the actual cycle.sh / context.sh / fixtures / tools.yaml / autosend-policy state. Every "exhaustive search-and-update" pass I committed to introduced new drift somewhere I didn't touch.

R4's remaining 8 issues span the same surface area as R3's 10 — line citation drift in tools.yaml that didn't get the grep-anchor treatment; tier mislabel for `concierge_approval_routed`; target-string format inconsistency between agent.md sections; stale §9 Q1 status; v0.4-required-vs-Path-A cross-doc mismatch; wrong context.sh line citation in D1-B; CC fixtures not renamed to `tenant_env_overrides:`. All real; none capricious.

## Why we are stopping anyway

Three reasons:

### 1. My "this should converge" predictions have been wrong every single time.

R2 prediction: "2/3 ratify cleanly" — actual: 0/3 with 10 issues. R3 prediction implicit ("fix and re-run") — actual: 0/3 with 10 issues. R4 prediction: "should converge — structural drift fixed" — actual: 0/3 with 8 issues. The convergence-prediction is unreliable signal; the base rate says R5 surfaces another 5-7 things.

### 2. The pre-agreed hard-stop rule (founder-authorized 2026-06-02 AskUserQuestion + cluster F precedent at commit `497fa0c`) fires here.

The rule: if a Codex round returns REJECTED with NEW issues after we've already done one consistency pass, accept partial-ratification + document the disagreement + move on. Today is that day for Fbis + G.

### 3. The natural fix is the build slice itself, not more hand-edits.

The artefacts will be touched comprehensively when:
- **W7-8 Cash Conductor build slice** replaces every `TODO(W7-8)` marker across cycle.sh + validate.sh + context.sh + cleanup.sh + fixtures with live impl. At that point the agent.md spec and the code are written/touched in the same workflow; the drift surface disappears naturally.
- **W10-13 Concierge build slice** does the same for Concierge + lands the autosend-bridge production wiring + makes the W10-13 schema-path decision (Path A `approval_routing` reuse vs Path B v0.4 supplement per D1-B doc §Implementation surface item 5).

Each build slice is the right time to re-run cluster Fbis + G ratification — at that point the artefacts are mutually consistent because they were written together.

## What the disagreement is (per Codex issue class)

### Counter-argument 1: scaffold-vs-runtime-drift is a deferred-to-build-slice concern

Codex correctly identifies that agent.md text describes behavior the SKELETON cycle.sh / validate.sh / context.sh doesn't yet implement. The agent.md Reading-discipline note (added in CC commit `8cc0491` + Concierge commit `d46474c`) explicitly frames this as CONTRACT-vs-SKELETON-runtime. **We accept the agent.md/code divergence as a known property of pre-build-slice scaffolding.** Build-slice authors writing both agent.md updates + code in same workflow eliminate the drift surface.

### Counter-argument 2: line-citation drift across cross-document references is a recurring tax we accept

Every time autosend-policy.yaml gets a new entry, every existing agent.md/tools.yaml citation that referenced a line number further down the file is now wrong. The grep-anchor pattern (`grep \`^  xero_reminder_send_customer:\`` instead of "line 263") solves this — applied in CC agent.md at R2, extended to Concierge agent.md at R3, but not yet to tools.yaml files or D1-B citations. **The pattern is correct; the propagation is incomplete; W7-8 + W10-13 build slices apply it everywhere when they touch the files anyway.** Until then, the line citations are best-effort and accepted as drift-prone.

### Counter-argument 3: cross-document mutual-consistency (e.g. agent.md v0.4-required vs D1-B Path-A-allowed) is a coordination problem hand-edits don't solve

When D1-B got reframed from "v0.4 required" to "Path A or Path B" in commit `dea1257`, the Concierge agent.md still says "v0.4 required". Updating ONE doc requires updating EVERY doc that references the same concept. With 5+ agent.md files + 6+ decision-docs + a master brief + ULTRAPLAN, the cross-reference web is too large for piecemeal hand-edits to keep consistent. **Build-slice workflows that touch the related docs as a unit will reconcile this; until then, cross-doc claims about each other are best-effort.**

## What we ARE keeping fixed (real bugs caught across 4 rounds)

Despite the partial-ratification outcome, Codex caught real things that ARE fixed in tree:

| Round | Real bug caught | Fix commit |
|---|---|---|
| Fbis R1 | `bullhorn_activity_log_write` action_type missing from autosend-policy | `e32344e` |
| Fbis R1 | Concierge §4 Step 15 hh_decision_action signature wrong (3 args vs 4) | `e32344e` |
| Fbis R2 | Concierge §1 voice threshold omitted middle position-2 (≥0.78) | `6976a26` |
| Fbis R3 | Concierge anti-duplicate guard queried non-existent payload.event_type | `d46474c` |
| Fbis R3 | Concierge context.sh + fixtures violated schema-before-code (tenant_adapters reads of unallowlisted keys) | `d46474c` |
| G R1 | D1-B falsely claimed Day-4 _secrets.env provisioning includes Telegram bot token | `448571b` |
| G R3 | D1-B falsely claimed FUNCTION-ARG MODE only when context.sh actually read tenant_adapters | `dea1257` |

**Codex's value is real.** It caught 7 substantive things across 4 rounds. The reason we hard-stop isn't "Codex is wrong" — it's that the marginal value of round 5 is low and my track record at predicting convergence is bad.

## What would change the call (re-trigger conditions)

Re-run cluster Fbis + G ratification when:
- **W7-8 Cash Conductor build slice ships** — agent.md + cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + fixtures all touched in the same workflow with live impl. Cluster Fbis Cash Conductor entry should pass.
- **W10-13 Concierge build slice ships** — same as above for Concierge + autosend-bridge production wiring + Path-A or Path-B schema decision. Cluster Fbis Concierge entry + cluster G D1-B should both pass.
- **A new fact contradicting these disagreements emerges** — e.g. Codex skill `review-agent-bundle.md` gets hardened to be less interpretive on what counts as "drift" vs "scaffold-acceptable divergence"; or the master brief explicitly defines a `Proposed-with-bundle-drift` state separate from `Proposed`.

Until any of those happen, the 3 artefacts stay at **Proposed-with-disagreement-on-file** and the disagreement is THIS doc.

## Risk + future prevention

**Risk: low.** No production code depends on these agent.md files being ratified-as-bundle. The contract-layer ratification (W3 cluster E) is the load-bearing one for v1.0 readiness; bundle-layer ratification gates only the bundle's own quality framing, not deployment.

**Future prevention — recommendation deferred to founder for prioritization:**
- Consider hardening `review-agent-bundle.md` skill to explicitly accept "agent.md describes target W-X build-slice behavior; SKELETON files exist with TODO(W-X) markers" as a non-rejection state. The skill currently treats agent.md ↔ code drift as a structural issue when in reality scaffolding inherently has this property.
- Consider a radical-shrink approach: trim each agent.md to ~50 lines (output contract + 5-line workflow summary + ESC catalogue subset only), push implementation detail into actual cycle.sh/context.sh as comments where they live next to the code they describe. Removes ~90% of the drift surface.
- Consider adding a `.agents/learnings/` entry for "Codex agent-bundle ratification converges poorly with hand-edits across long cross-coupled docs; defer to build-slice workflows where code + spec are touched together."

## Cluster F + Fbis + G grand total

- Cluster F: 1/3 ratified (`@ifos/xero`); 2 disagreement-on-file (QB concurrent throttle + OB v1.1+ Plaid internal stub)
- Cluster Fbis: 0/2 ratified; 2 disagreement-on-file (this doc covers both CC + Concierge)
- Cluster G: 0/1 ratified; 1 disagreement-on-file (this doc covers D1-B)

**Total: 1 ratified, 5 proposed-with-disagreement, across 13 Codex rounds.** Build progress is unblocked — the W7-8 + W10-13 + ongoing build slices proceed against the current SKELETON + spec state. The 5 disagreement docs are the audit trail.

— end of disagreement —
