# Codex disagreement — decision-doc shape required on audit + runbook artefacts

**Date:** 2026-05-20 (Day 8, Codex Round 1 incorporation)
**Artefacts disagreed on:**
- `docs/architecture/cortexos-primitive-status.md` (Codex output: `logs/codex-ratification/manual-run/docs_architecture_cortexos_primitive_status_md.output.md`)
- `docs/runbooks/operational-hygiene-protocol.md` (Codex output: `logs/codex-ratification/manual-run/docs_runbooks_operational_hygiene_protocol_md.output.md`)
**Skill applied:** `.codex/ratification/review-architecture-decision.md` §1
**Codex outcome:** REJECTED (issue 2 in both)
**Round trip:** 1

---

## §1 — Codex's numbered issues (verbatim)

### From `cortexos-primitive-status.md` issue 2:

> The artefact lacks explicit Context, Decision, and Consequences sections. It has a summary table at lines 17-29 and primitive sections from line 33 onward, but not the required decision-doc shape. Fix by adding a short Context section, a Decision/Findings section that names the audit conclusions, and Consequences for Day-7 Q2/risk-register updates.

### From `operational-hygiene-protocol.md` issue 1:

> The runbook lacks required Context, Decision, and Consequences sections. Lines 10-29 explain why the document exists, but there is no explicit Decision section naming the binding operational choices and no Consequences section describing downstream enforcement. Fix by adding those sections or reclassifying it under a ratification type that does not require decision-doc shape.

---

## §2 — Claude's response

### Issue: decision-doc shape required on non-decision artefacts

**Counter:** `cortexos-primitive-status.md` is an **audit artefact** (Status: Reference per the Day-8 Codex Round 1 cosmetic incorporation). `operational-hygiene-protocol.md` is an **operational runbook** (Status: In Force per Day-6 close `0020521`). Neither is a decision document.

The skill's enumeration of allowed Status values explicitly includes `Reference` and `In Force` alongside `Proposed | Accepted | Superseded | Deprecated`. By including those values, the skill implicitly accepts that artefacts ratified under `review-architecture-decision.md` may legitimately not be decisions. Enforcing ADR-shape (Context + Decision + Consequences) on audits + runbooks adds ceremony without value:

- An audit's "decision" is "here are the findings"; an audit's "consequences" are "downstream artefacts that consume the findings". Both are implicit in the audit's table-of-findings structure; spelling them out as sections is redundant.
- A runbook's "decision" is the codified operational procedure; a runbook's "consequences" are "this is the procedure you follow". Forcing a Decision/Consequences split breaks the runbook's "what + when + how" structure.

**The right fix is to soften the skill, not to retrofit ADR ceremony onto audit + runbook artefacts.** The skill's §1 requirement should exempt Status=Reference + Status=In Force artefacts from the explicit Decision/Consequences subheadings — Context still required (a reader must be able to tell what the artefact is about cold).

### Proposed skill softening (Founder Decision D5)

Edit `.codex/ratification/review-architecture-decision.md` §1 to read:

```
3. Decision section — names the choice, not the deliberation. **Required for Status=Proposed | Accepted artefacts. Exempt for Status=Reference (audits, manifests, inventories) and Status=In Force (runbooks, operational standing policies) — those artefacts encode their "decisions" in the working content itself (audit findings table; runbook procedure steps); a separate Decision heading would be redundant.**

5. Consequences section — what changes downstream. **Required for Status=Proposed | Accepted artefacts. For Status=Reference + In Force, downstream impact may be inline (e.g., "Day-7 single-sentence test Q2 references this audit") rather than under a dedicated heading.**
```

This change preserves the citation-accuracy + status-honesty checks (load-bearing) while removing the spurious Decision/Consequences enforcement on artefacts that legitimately don't have decisions.

---

## §3 — Resolution

- [x] **Incorporated (Codex correct on Context + Status; counter-argued on Decision/Consequences for Reference + In Force — Founder Decision D5-A accepted 2026-05-22)**
- [ ] Counter-argued
- [ ] Compromise (partial accept)

**Resolution detail (2026-05-22):** Founder accepted D5-A. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` — Reference + In Force status artefacts are now exempt from Decision + Alternatives + Consequences sections (Context + Status update line still required). The two REJECTED artefacts from Round 1 (`cortexos-primitive-status.md`, `operational-hygiene-protocol.md`) are expected to RATIFY in Round 2 without changes. Two new Day-9 artefacts (`architecture-cohesion-review.md` Reference, `tenant-lifecycle.md` In Force) are now ratifiable under the softened skill.

## §4 — Founder decision (RESOLVED 2026-05-22)

**D5-A accepted.** Skill softened. Cluster B re-ratification (Round 2) expected to RATIFY `cortexos-primitive-status.md` + `operational-hygiene-protocol.md` without artefact changes. Day-9 Reference + In Force artefacts (`architecture-cohesion-review.md`, `tenant-lifecycle.md`) ratifiable under softened skill.

Original options preserved for audit:

- **D5-A** (chosen): Accept Claude's reasoning. Soften the skill per §2 above.
- **D5-B**: Accept Codex's reasoning. Add Decision + Consequences sections.
- **D5-C**: Hybrid. Soften for Reference; keep for In Force.

---

## §5 — Cost of delay

Both artefacts remain marked REJECTED in the manifest queue table pending founder D5 resolution. Neither blocks any current work (audit findings + runbook procedures are still binding regardless of Codex verdict). Recommended decision window: this week, before Q1 LOI process accelerates other priorities.

*End of disagreement doc.*
