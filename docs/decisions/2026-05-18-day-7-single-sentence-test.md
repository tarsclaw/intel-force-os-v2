# Week 0 single-sentence test (Day 7)

**Date:** 2026-05-18 (per master brief §6 Day 7 calendar position; actual execution 2026-05-20)
**Author:** Founder (Maddox), with Claude Code drafting support
**Status:** Accepted (factual recording — not a Proposed decision)
**Source:** Master brief §6 Day 7 lines 492-501 + Ultraplan §12

---

## §1 — The five questions verbatim

From master brief §6 Day 7 lines 494-501 verbatim:

> Single-sentence test (Ultraplan §12). Answer each Y/N:
>
> 1. Do we have at least one design partner who has said "yes I will pilot this in Q3 2026"?
> 2. Does the CortexOS submodule give us primitives 1, 4, and 5 working today?
> 3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
> 4. Have we scoped the Agent Bundle v2 refactor and is the work <5 days?
> 5. Have we drafted the vertical schema v0.1 with the 8 core entities?

Master brief §6 Day 7 line 502 verbatim:

> **Five yeses → Week 1 starts Monday. Anything less → Week 0 extends.**

---

## §2 — Per-question answers with evidence

### Q1 — Design partner pilot Q3 2026 LOI?

**Answer: NO.**

- **Pipeline state:** zero design partners in pipeline as of 2026-05-18 Day 5; founder did not initiate the Sunday/Monday outreach paths queued in `bullhorn-integration-path.md` §1.3 (Bullhorn partnerships, Bullhorn dev support, design partner #1) because no named target existed for design-partner #1 path; warm-path strategy supersedes cold outreach.
- **Risk register state:** Risk #3 in `docs/RISK-REGISTER.md` escalated from Medium → High on Day 5 with the explicit text "zero design partners in pipeline as of 2026-05-18 Day 5; original 'conversation 1' assumption invalidated; no founder-side outreach pipeline exists."
- **Kill criterion linkage:** Trigger 1 in `docs/decisions/v1.0-kill-criterion.md` §2 (DESIGN-PARTNER-BY-WEEK-2) fires end-of-day **2026-06-03** if no signed LOI by then. That is the binding tripwire — currently **14 calendar days** out from today (2026-05-20).
- **Master brief §6 Day 7 question 1 cannot be answered yes** until at least one UK recruitment-agency design partner has expressed pilot intent for Q3 2026 with a signed LOI or equivalent written commitment. None exists.

### Q2 — CortexOS primitives 1, 4, and 5 working today?

**Answer: YES with documented caveat.**

- **Primitive 1 (Persistent PTY via PM2):** functional per Day-1 audit `docs/architecture/cortexos-primitive-status.md` — "shipped but flaky" per master brief §12 Risk #1. Day-1 audit found the substrate is operational for development workloads. Quirks 2-3 + 2026-04-22 restart-storm evidence document occasional instability under load, not broken.
- **Primitive 4 (Approval gates):** confirmed "shipped and tested" per `cortexos-primitive-status.md`. Active code citations: `src/bus/approval.ts:222-226` (activity-channel + per-agent-bot belt-and-braces pattern post-50h-stall incident), `src/daemon/fast-checker.ts:454-552` (callback handling with `ALLOWED_USER` enforcement at line 468 and 552, `appr_allow_<id>` / `appr_deny_<id>` callback routing for primitive 4 approval-gate UX).
- **Primitive 5 (Telegram + iOS approval surface):** confirmed shipped per `cortexos-primitive-status.md` audit. Two-poller mechanism (`agent-manager.ts:478-575`, `maybeStartActivityChannelPoller()`) integrates with primitive 4 approval gates. Per master brief §12 Risk #1 framing: "Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5."
- **Caveat:** primitive 1 (PTY/PM2) carries Risk #1 "shipped but flaky" status. Risk #1 was downgraded on Day 1 because primitives 3 and 4 were confirmed shipped-and-tested; primitive 1 retained the flaky-under-load designation. Operationally sound for the 6 v1.0 agents per Day-1 audit; v1.1+ scale (13+ agents) may require revisit.
- **Risk #1 in `docs/RISK-REGISTER.md`** carries the trip wire (>1 incident/week) and the contingency (degraded-mode fallback + manual file-bus handoff per `cortexos-primitive-status.md` Primitive 4 evidence).

**YES because operationally sufficient for the v1.0 6-agent build window** that Week 1+ will exercise. Caveat documented above.

### Q3 — ATS build decision + auth path cleared?

**Answer: NO.**

- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
- **Auth path cleared: NO.** Sub-decisions A (marketplace vs direct API) and B (OAuth flow specifics — authorization-code grant against IFOS-owned dev tenant) remain Status: Proposed in `bullhorn-integration-path.md`. The technical path is documented but the commercial gates have not passed:
  - **Bullhorn partnerships outreach** (`partnerships@bullhorn.com`): not sent. Confirms marketplace-vs-direct cost delta at 3-tenant scale + production-tenant partnership requirement.
  - **Bullhorn developer support outreach** (developer.bullhorn.com): not sent. Confirms auth-code flow specifics, sandbox / dev tenant model, per-entity OAuth scope granularity, refresh-token rotation atomicity.
  - **Design partner #1 conversation 2** (ATS confirmation): not had. The design partner gap from Q1 means we cannot confirm pilot #1 actually uses Bullhorn vs a different ATS.
- **Risk #2 in `docs/RISK-REGISTER.md`** carries Bullhorn auth path status: High while Sub-decisions A and B are Proposed. Reduction trigger to Medium requires the commercial conversations to land.
- **"Cleared the auth path" interpretation:** strict — "cleared" means the technical and commercial gates have both passed. Technical path documented (auth-code-against-IFOS-dev-tenant; `client_credentials` foreclosed per master brief §6 Day 2 atomic-correction Edit 6 verified at `0e5b2b4`). Commercial gates not passed. Q3 = NO.

### Q4 — Agent Bundle v2 refactor scoped + <5 days?

**Answer: YES.**

- **Scoped:** `docs/decisions/ADR-003-agent-bundle-renderer.md` Accepted Day 1 evening with full design spec at `docs/architecture/agent-bundle-renderer-design.md`. 12-row file-by-file translation contract ratified per ADR-003 Decision 3.
- **Sequencing:** `docs/decisions/sequencing-target.md` §4.1 ratifies the 6-agent build order; renderer is Week 1-2 prerequisite for the Diagnostic W3-4 first render per ADR-003 §5.2.
- **Effort estimate <5 days:** ADR-003 §5.2 names 8 prerequisite items for renderer scaffolding. Initial implementation effort estimated at <5 person-days for the renderer's core translation path. Full Week 1-2 (~5-10 days) covers prerequisites + tests + first-tenant render validation.
- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
- **Risk #5 (renderer-not-built)** in `docs/RISK-REGISTER.md` reduced from Blocking → High on Day 1 evening when ADR-003 + design doc Accepted. Three-stage ladder to Medium (W4 first Diagnostic render) → Low (W13 all 5 v1.0 bundles rendered).

### Q5 — Vertical schema v0.1 with 8 core entities?

**Answer: YES.**

- **Artefact:** `docs/verticals/recruitment/vertical-schema.yaml` Status: Proposed, shipped Day 6 commit `fec8872`.
- **8 entities per master brief §6 Day 6 line 490:** `candidate`, `contractor`, `client`, `contact`, `brief` (with `role` alias), `placement`, `opportunity`, `timesheet`.
- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
- **Layering verified:** YAML specifies entity_type + link_type + data JSONB shape over Day-4 generic primitives (`entities`, `entity_links`, `decision_log` tables) — entity-type slugs land in `entities.entity_type` column; link-type slugs land in `entity_links.link_type` column.

---

## §3 — Tally

**3 of 5 YES** (Q2, Q4, Q5) — strict interpretation per Day 7 founder decisions.

| # | Question | Answer | Confidence |
|---|---|---|---|
| 1 | Design partner pilot Q3 2026 LOI? | **NO** | High — zero pipeline; Risk #3 High; Trigger 1 fires 2026-06-03 |
| 2 | Primitives 1, 4, 5 working today? | **YES with caveat** | High for primitives 4+5; primitive 1 documented flaky-under-load |
| 3 | ATS decided + auth cleared? | **NO** | Build decided YES (Bullhorn); auth path NOT cleared (Sub-decisions A+B Proposed, no commercial outreach) |
| 4 | Agent Bundle v2 refactor scoped + <5 days? | **YES** | High — ADR-003 + sequencing-target + design doc all Accepted |
| 5 | Vertical schema v0.1 with 8 entities? | **YES** | High — shipped Day 6 fec8872 |

---

## §4 — Week 0 closure determination

**Week 0 EXTENDS per master brief §6 line 502.**

- **Threshold:** 5 of 5 yes. Achieved: 3 of 5.
- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
- **Week 0 status:** Extending. Closes when (a) Q1 turns YES (design partner LOI) AND (b) Q3 turns YES or is accepted-with-risk via founder decision.

---

## §5 — Extension protocol

### Work that CONTINUES during extension

1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
2. **`.codex/ratification/*.md` skills** — master brief §10.2 Day-1 task deferred during Days 0-6; surfaced as gap during Day-7 grounding. Build during extension period. 7 skill files (SKILL.md + 6 review-{type}.md per master brief §10.2). Estimated 2-3 person-days.
3. **Master brief atomic-correction commit** — **landed today** at `0e5b2b4`. No further action.
4. **Design-partner outreach** — the SINGLE Q1 unblocker. Founder-side work; warm-path strategy when targets named, cold-path templates draftable now if founder identifies prospect list. **This is the highest-leverage extension work.**
5. **Bullhorn commercial conversations** — `partnerships@bullhorn.com`, Bullhorn dev support, design-partner #1 ATS confirmation. Flips Sub-decisions A+B Proposed → Accepted, reduces Risk #2 from High to Medium, resolves Q3 partially.
6. **Renderer implementation per ADR-003** — ALLOWED in code repo but agent-build slices (Diagnostic et al.) DO NOT start until Q1 turns YES. Renderer can scaffold independently.

### Work that IS BLOCKED during extension

1. **Diagnostic W3-4 agent build** — blocked; requires Q1=YES.
2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
3. **Any work requiring pilot-client data** — no pilot, no data.
4. **First Codex ratification run execution** — manifest produced today (see Deliverable 3); actual `codex review` against ratification skills waits for (a) skills built AND (b) Week 0 close achievable.

---

## §6 — Unblocker path

**Question 1 (design partner LOI) is the single structural unblocker.**

- When Q1 turns YES, single-sentence test re-runs.
- If re-run produces 4 of 5 YES (Q3 still NO because Bullhorn commercial conversations haven't completed), founder may accept Q3 as risk-noted and declare Week 0 closed with Week 1 starting under that accepted risk. This is a founder-discretion call, not automatic from the master brief test.
- If re-run produces 5 of 5 YES (Q3 also turns YES because design partner #1 confirms Bullhorn and commercial gates align), Week 0 closes cleanly.

**Q3 unblocker independent of Q1:**

Bullhorn commercial conversations (`partnerships@bullhorn.com`, Bullhorn dev support) flip Sub-decisions A+B Proposed → Accepted regardless of Q1 status. These conversations don't unblock Week 1 alone but they reduce Risk #2 from High to Medium and tighten the auth-path readiness.

**Other Q1-conditional unblockers:**

- Q1 + Q3 = YES → Week 0 cleanly closes; Week 1 starts; Diagnostic W3-4 build begins.
- Q1 = YES, Q3 = NO (accepted) → Week 0 closes by founder discretion; Week 1 starts with Risk #2 elevated; Diagnostic W3-4 begins under accepted risk; Janitor W5 contingent on Q3 clearing by then.

**Calendar:**

- Today: 2026-05-20.
- Trigger 1 (kill criterion DESIGN-PARTNER-BY-WEEK-2 PAUSE): fires end-of-day **2026-06-03** if no signed LOI.
- Remaining window for Q1 to turn YES: 14 calendar days.

---

## §7 — Honest founder reflection

[Founder reflection to be written manually — not a Claude Code output. Section reserved for Maddox to write directly: why Q1 is NO, what the plan is, whether the plan is realistic, what changes in week-of-extension execution vs. what was assumed in Days 0-6.]

---

## Status

**Accepted (factual recording).** Recorded in `.agents/current-priorities.md` Day 7 Shipped section. Risk #3 in `docs/RISK-REGISTER.md` updated to reflect Week 0 extension active + Q1 unblocker path. Codex Day-7 ratification manifest produced as Deliverable 3 (sibling artefact in this commit).

*End of single-sentence test.*
