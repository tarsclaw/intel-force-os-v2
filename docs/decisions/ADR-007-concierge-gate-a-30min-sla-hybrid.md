# ADR-007 — Concierge Gate A 30-minute draft SLA hybrid (Gate B leading metric, not per-draft hard-fail)

**Status:** Proposed (2026-05-25, Day 20; W4 bilateral pass on Concierge agent.md surfaced this as Codex R3 Finding 3 — current scaffold reframes ULTRAPLAN A6 line 566 Gate A "every lifecycle event has a draft generated within 30 minutes" as a Gate B leading metric without an authoritative ADR backing the deviation. Awaits Codex `review-architecture-decision` ratification + founder Accept.)
**Author:** Founder (Maddox) + Claude Code
**Amends:** `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566 — Gate A 30-minute draft SLA clause
**Ratifies via:** `.codex/ratification/review-architecture-decision.md` Codex skill
**Driven by:** `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3 — Codex flags Concierge `agent.md` §5 line 278 reframes the 30-min SLA as Gate B without an ADR; §10 Accepted criteria omits any ADR-ratification blocker for this deviation. Analogue of ADR-006 (Diagnostic Gate A hybrid).

---

## Context

ULTRAPLAN §8.1 A6 line 566 (pre-amendment wording):

> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)

The clause implies three Gate A hard-fail conditions: (a) draft generated within 30 minutes of lifecycle event, (b) voice classifier ≥ 0.75, (c) addressee resolution correct.

Concierge `agent.md` (Day-19 R3 scaffold) reframes (a) — the 30-minute draft SLA — from per-draft Gate A hard-fail to a Gate B leading metric (90% of drafts within 30 min, not per-draft hard fail). The other two clauses (voice classifier + addressee resolution) remain Gate A hard-fails. The reframe is documented in:

- `agent.md` §1 output-contract (30-min framing as Gate B target)
- `agent.md` §4 Step 9 (`ESC_CONCIERGE_SLA_MISS` warn, aggregated to Gate B; not per-draft block)
- `agent.md` §5 lines 269-280 (Gate A excludes the 30-min SLA explicitly)
- `agent.md` §6 ESC table (`ESC_CONCIERGE_SLA_MISS` registered as warn, not blocking)

This creates a documented gap between the upstream spec and the v0 scaffold. Codex R3 Finding 3 (Day-19 log `logs/codex-ratification/20260524T174513Z-13185/`):

> The 30-minute SLA is weakened without a ratified status-flip blocker. Line 16 and lines 206-212/276 reframe ULTRAPLAN A6 Gate A line 566 as Gate B, while also saying a future Concierge-Gate-A ADR must ratify the deviation before Accepted. §10 lines 417-421 omit that ADR from Proposed → Accepted criteria.

Per master brief §10.5 + Rule 4 (Quality gates before features), an upstream-spec amendment requires either (a) revert the scaffold to per-draft hard-fail, or (b) author an ADR ratifying the deviation. This ADR is option (b).

## The deviation in detail

### Why per-draft hard-fail is operationally problematic

The Concierge lifecycle-event trigger source is the Bullhorn ATS state-change webhook + a polling-fallback cron (per ULTRAPLAN A6 line 569 verbatim gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks").

Polling-fallback delays are not Concierge's fault — the polling cron runs at a configurable interval (likely 5-15 minutes per tenant) and a state change that happens at minute 1 of a 15-minute cycle has a 14-minute "blind spot" before Concierge ever sees it. A per-draft hard-fail Gate A would treat this as a Concierge failure even though the draft IS generated within 30 minutes of detection (just not within 30 minutes of the actual Bullhorn state change).

Treating this as Gate A hard-fail would cause Concierge to drop legitimate drafts whose timing was set by upstream-detection latency, not by Concierge generation latency. The product harm: a candidate experiences a "ghosted by recruiter" pattern that Concierge was designed to prevent.

### Why the metric is still load-bearing as Gate B

The 30-minute SLA IS the load-bearing UX promise of Concierge. ULTRAPLAN A6's "Tier 1 always-on closing demo" framing rests on it. Treating it as Gate B at the 90% threshold:

- Captures the population-level SLA promise
- Tolerates the occasional polling-fallback-induced delay without blocking legitimate drafts
- Drives a measurable improvement signal: if 30-min-SLA-hit-rate drops below 90% across a tenant, the polling interval is too slow OR Bullhorn webhook coverage is degraded — both actionable signals
- Aggregate failures fire `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) when sustained — same operational lever as ADR-006's per-claim quality metric

This is structurally identical to ADR-006's Tier 1 (per-section, hard-fail at the agent level) vs Tier 2 (per-claim, quality metric over time) split — applied here to time (30-min threshold per draft = Tier 1; 90% within 30-min over rolling window = Tier 2).

## Decision

**Concierge Gate A is the subset of ULTRAPLAN A6 line 566 that is operationally enforceable per-draft:**

- ✅ Voice classifier score ≥ position-specific threshold (≥0.75 / ≥0.78 / ≥0.82) — Gate A hard-fail
- ✅ Correct addressee resolution (no candidates emailed under another's name) — Gate A hard-fail (`ESC_ADDRESSEE_MISMATCH`)
- ✅ No tone-rule block-severity violations — Gate A hard-fail (`ESC_TONE_RULE_VIOLATION`)
- ✅ No PII outside firm boundary — Gate A hard-fail (`ESC_PII_LEAKAGE_RISK`)
- ✅ Anti-duplicate guard passed — Gate A hard-fail
- ✅ All Bullhorn context fields present — Gate A hard-fail (`ESC_AGENT_OUTPUT_SHAPE`)

**The 30-minute draft SLA moves to Gate B leading metric:**

- 90% of drafts generated within 30 minutes of lifecycle-event DETECTION (not lifecycle-event occurrence)
- Per-draft SLA miss fires `ESC_CONCIERGE_SLA_MISS` (warn, aggregated to Gate B)
- Rolling 30-day per-tenant aggregate <90% fires `ESC_GATE_B_MISS` (per `escalation-codes.md` §2.10) — actionable signal
- Concierge ALSO records the upstream-detection-latency separately in the audit payload (`payload.detection_delay_seconds`) so the metric attribution is clean (Concierge generation latency vs upstream polling latency)

**ULTRAPLAN §8.1 A6 line 566 is amended in-band per the master brief §10.3 step 4 pattern** (analogue of the in-band amendment ADR-006 made at line 496):

Pre-amendment:
> - **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)

Post-amendment:
> - **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — the 30-minute draft SLA is a Gate B leading metric at 90%, not Gate A hard-fail, because polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`.)*

## Consequences

**Positive:**

1. Concierge drafts are not dropped when upstream polling-fallback latency exceeds 30 minutes
2. The product UX promise of "post-state-change comms within 30 minutes" is captured at the population level
3. The metric attribution is clean — operators can distinguish Concierge generation latency from Bullhorn webhook/polling latency
4. Structural parity with ADR-006: per-event Gate A vs aggregate Gate B as the canonical Tier-1/Tier-2 split for time-based SLAs (replicable pattern for future agents)

**Negative:**

1. A per-tenant 30-minute SLA promise is harder to enforce contractually — pilot agreements must reflect that the SLA is at the population level not per-event
2. Tenants with high webhook coverage will see better than 90%; tenants with webhook-coverage gaps see worse — the metric reads as Concierge quality but is partly an upstream condition. Operator must look at `payload.detection_delay_seconds` distribution to disambiguate.
3. The Concierge agent.md §10 Accepted criteria must include ratification of this ADR as a blocker (closing Codex R3 Finding 3 properly)

**Neutral:**

4. No code or schema changes required at scaffold stage — `agent.md` already reflects the Gate B framing. Update is to ULTRAPLAN line 566 (in-band amendment) + Concierge §10 (add ADR blocker) + this ADR (new artefact).

## Implementation

### In-band ULTRAPLAN amendment (per master brief §10.3 step 4)

Edit `docs/specs/ULTRAPLAN.md` §8.1 A6 line 566:

```diff
- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
+ **Gate A:** voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name) *(see `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` — 30-minute draft SLA is Gate B leading metric at 90%)*
```

Commit message: `amend(ULTRAPLAN A6 line 566): Gate A scope reduced; 30-min SLA → Gate B per ADR-007`

### Concierge §10 amendment

Add to Accepted blockers (after R3 commit `f79c018` baseline):

> - **ADR-007 (Concierge Gate A 30-min SLA hybrid) RATIFIED** — closes R3 Finding 3 structural deviation; ratifies the agent.md §5 Gate A scope vs ULTRAPLAN A6 line 566 pre-amendment language.

### Audit payload extension (deferred)

`decision_log.payload.detection_delay_seconds` field for Concierge action rows is not in v0.3 schema; queued for v0.4 supplement OR W10-13 build-slice schema addition (whichever ships first). Concierge `cycle.sh` v0.0 records the field; absent the constraint, it's free-form JSONB.

## Open questions

| # | Question | Resolution path |
|---|---|---|
| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
| ADR-007-Q2 | Should `ESC_CONCIERGE_SLA_MISS` be a separate code, or should it reuse `ESC_GATE_B_MISS` with payload.metric='concierge_30min_sla'? | Recommend separate code for clean Telegram routing; `_GATE_B_MISS` is generic aggregate. Catalogue addition queued at W10-13 build start. |
| ADR-007-Q3 | What's the polling-fallback interval default? | Per-tenant; recommend 5 min as v1.0 default; 1 min for tenants with stable webhook coverage. Documented in tools.yaml at W10-13 build. |

## References

- ADR-006 — Diagnostic Gate A hybrid (structural template for Tier 1 vs Tier 2 split)
- ULTRAPLAN §8.1 A6 line 566 (pre-amendment authority)
- `agents/recruitment/concierge/agent.md` §1, §4 Step 9, §5, §6 (Gate B framing already implemented)
- `agents/_shared/escalation-codes.md` `ESC_CONCIERGE_SLA_MISS` (registered) + `ESC_GATE_B_MISS` (registered)
- `docs/operations/w4-bilateral-pass-6-agent-md.md` Concierge Finding 3
- Master brief §1 Rule 4 (Quality gates before features) + §10.5 (ADRs are ratifiable artefacts)
