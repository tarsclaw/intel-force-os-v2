# Codex Round 1 — 5 founder decisions surfaced

**Date:** 2026-05-20 (Day 8 evening)
**Status:** Proposed
**Context:** Codex ratification first run rejected 14 of 16 artefacts. 13 of 14 rejections were incorporated (Bucket 1 cosmetic + Bucket 2 drift + Bucket 3 structural fixes — same commit as this briefing). The remaining 5 items surfaced by Codex are genuine founder-domain product judgments, not Claude's call. This briefing surfaces them in one place for resolution.

Each decision: source + Codex's framing + named options + Claude's recommendation + cost-of-delay.

---

## D1 — Auto-send v1.0 tier enforcement (orange-tier behavior)

**Source artefacts:**
- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2

**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."

**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:

- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**

**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.

**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).

**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).

**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.

**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.

**D1 Concrete recommendation:** Schedule for Week 9 (default). Founder explicitly approves D1-B; bridge spec ratifies through Codex Round 2; bridge implementation slice authored Week 9.

---

## D2 — External advisor identification

**Source artefacts:**
- `docs/decisions/v1.0-kill-criterion.md` §3.4 ("Week 1-2 must-fill")
- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3

**Codex's framing:** "The legal placeholder is load-bearing for pilot readiness but unresolved. Lines 498-500 warn not to use the liability language as-is, and lines 578-584 leave jurisdiction, liability cap, dispute forum, insurance, and PII liability open. Fix by marking pilot LOI signing blocked until counsel-reviewed language replaces §10."

**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.

**Options:**
- **D2-A: Engage UK SaaS lawyer this week** (recommended advisors: a) Bowers Anderson, b) recommended-by-Jack contact, c) any-firm-that-handles-recruiter-SaaS). Expected cost: £500-2000 for LOI template + jurisdiction clauses + PII liability clauses. **Recommended.**
- **D2-B: Defer to first pilot LOI signing window** — risky; if Q1 LOI lands before D2-A advisor is engaged, founder is choosing between (a) signing without legal cover, or (b) delaying LOI signing.
- **D2-C: Use boilerplate UK SaaS LOI template** (off-the-shelf) without lawyer engagement. Cheap but high risk for kill-criterion §3.4 explicit external-advisor requirement.

**Claude's recommendation:** D2-A. Engage this week. Cost is minor relative to pilot LOI risk; advisor naming is also a Risk #3 mitigation. Block any LOI signing until D2-A completes.

**Cost of delay:** Trigger 1 fires 2026-06-03 if no LOI. If LOI lands but advisor isn't engaged, founder has to choose between violating kill-criterion §3.4 or delaying LOI past Trigger 1. Engage now to avoid the forced choice.

---

## D3 — v0.2 recent_edit PII retention

**Source artefacts:**
- `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` §6 Q13 (UK GDPR retention question)
- Codex output `logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4

**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."

**Real issue:** `recent_edit.original_text` + `edited_text` are CAPPED at 8192 chars but otherwise stored verbatim. The agent's draft AND the consultant's edited version. Both can contain PII (candidate names, salaries, contact info). Indefinite retention for LoRA SFT training. UK GDPR Art. 5(1)(e) "data minimisation" arguably requires bounded retention.

**Options:**
- **D3-A: Indefinite retention (v0.2 current default)** — maximises LoRA SFT corpus. Highest GDPR risk.
- **D3-B: 90-day text purge + indefinite metadata** — purge `original_text` + `edited_text` after 90 days; keep `edit_distance` + `resolution` + `tone_rules_triggered` (already aggregates) forever. **Loses some SFT corpus signal** but retains the "what rules fired" signal indefinitely.
- **D3-C: Pilot-controlled retention** — each tenant's TOS specifies retention (default 90d, optional indefinite). Operationally complex but GDPR-compliant per-tenant.
- **D3-D: Tied to D2** — defer until external advisor (D2-A) weighs in. Advisor likely recommends D3-B with redaction rules.

**Claude's recommendation:** D3-D first (defer until D2 advisor engaged), then likely D3-B. Block first pilot LOI until D3 resolves (paired with D2).

**Cost of delay:** Same as D2 — Trigger 1 fires 2026-06-03. If LOI lands before D3 resolves, founder ships v1.0 with D3-A indefinite retention, which is the worst legal posture. Bundle D2 + D3 resolution.

---

## D4 — Path B emergency credential policy

**Source artefacts:**
- `docs/runbooks/operational-hygiene-protocol.md` §2.2 (Path B — FORBIDDEN absent explicit waiver)
- Codex output `logs/codex-ratification/manual-run/docs_runbooks_operational_hygiene_protocol_md.output.md` issue 2

**Codex's framing:** "The document says Path B is forbidden but preserves a waiver that can still put credentials in chat. Fix by replacing Path B with a non-chat emergency alternative, or mark the waiver as no longer available."

**Bucket 3 already tightened Path B language** (`fix(codex-round-1)` commit). Current state: Path B remains available as emergency escape hatch, with rotation-in-same-session-MANDATORY discipline + verification protocol. Future use counts as Risk #1 strike.

This decision is whether to go further:

- **D4-A: Keep current Path B with the Bucket 3 tightening** — emergency escape hatch with hard rotation discipline. **Recommended.** Day-4 LUKS-passphrase incident shows this can be done safely.
- **D4-B: Remove Path B entirely** — replace with non-chat alternatives only (1Password CLI auto-fetch; SSH agent forwarding; manual founder execution outside chat). More disciplined but harder for genuine emergencies (e.g., LUKS unlock at boot when there's no other terminal).
- **D4-C: Hybrid — Path B remains for LUKS-only emergencies** — narrow allowed scope to a specific named emergency type (LUKS unlock when no interactive shell). All other credential paths use Path A or Path D.

**Claude's recommendation:** D4-A (current state after Bucket 3 tightening). Day-4 evidence: Path B used once, rotated correctly, no real damage. D4-B is principle-pure but operationally costly. Re-evaluate at pilot-scale.

**Cost of delay:** Low; current Bucket 3 tightening is already in place. Decision can wait for next Path B incident.

---

## D5 — Decision-doc shape skill softening for Reference + In Force artefacts

**Source artefact:** `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` §4

**Real issue:** Codex Round 1 REJECTED `cortexos-primitive-status.md` (audit) and `operational-hygiene-protocol.md` (runbook) for lacking Decision + Consequences sections. The skill `.codex/ratification/review-architecture-decision.md` §1 requires these sections for all artefacts under this skill. But the skill ALSO allows Status=Reference and Status=In Force, which are legitimately non-decision artefacts. Contradiction in the skill itself.

**Options:**
- **D5-A: Soften the skill** — exempt Status=Reference + Status=In Force from the Decision/Consequences requirement. Re-run Round 2; both artefacts expected to RATIFY without further changes. **Recommended.**
- **D5-B: Don't soften** — add Decision/Consequences sections to both artefacts (retrofitted ceremony). ~50 lines per artefact.
- **D5-C: Hybrid** — soften for Reference only; keep enforcement for In Force (argue runbooks DO encode binding policy).

**Claude's recommendation:** D5-A. The skill should reflect what the artefact types actually are; audits + runbooks legitimately don't have decisions.

**Cost of delay:** Both artefacts remain marked REJECTED in manifest queue until D5 resolves. Neither blocks any current work (audit findings + runbook procedures are still binding regardless of Codex verdict).

If D5-A or D5-C: skill update is a separate small commit. Re-ratification runs from same `bash scripts/run-codex-ratification.sh --cluster B` command.

### ✅ D5 — RESOLVED 2026-05-22

Founder accepted **D5-A**. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` plus new §1-Exemption clause. Reference + In Force status artefacts now exempt from Decision + Alternatives + Consequences requirements (Context + Status line still required for ALL).

Round 2 expectations after this resolution:
- `cortexos-primitive-status.md` (was REJECTED §1 issue 2) → expected RATIFY
- `operational-hygiene-protocol.md` (was REJECTED §1 issue 1) → expected RATIFY
- `architecture-cohesion-review.md` (Day-9; not yet ratified) → ratifiable under softened skill
- `tenant-lifecycle.md` (Day-9; not yet ratified) → ratifiable under softened skill

D5 unblocks Round 2 closure for 4 artefacts.

---

## §10 — Resolution timeline recommendation

| Decision | Timing | Blocks what |
|---|---|---|
| **D5** (skill softening) | This week | Round 2 ratification of 2 artefacts |
| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
| **D4** (Path B policy) | Anytime | Nothing — current state is adequate |
| **D2** (external advisor) | This week — pre-LOI blocker | First pilot LOI signing |
| **D3** (PII retention) | Bundle with D2 | First pilot LOI signing |

**Recommended order:** D5 (quickest, unblocks Round 2) → D1 (Concierge planning) → D2 + D3 (legal bundle) → D4 (no-rush).

Total founder time: ~2-3 hours across the week if D2 + D3 are bundled to one advisor conversation.

---

## §11 — How to record resolutions

For each decision, founder writes resolution to this file under §"Resolution" subsection of the corresponding D# entry:

```markdown
## D1 — Resolution (2026-05-XX)

Founder picks D1-C: ship orange-as-red default + manual override.

Rationale: <2-3 sentences>

Implementation work: <commit reference or "in autosend §9 update commit">
```

OR open a follow-on ADR if the decision warrants more substantive recording (e.g., ADR-005 for D1; ADR-006 for D2 + D3 bundle).

---

*End of founder decisions briefing.*
