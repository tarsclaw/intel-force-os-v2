# Learning 02 — ECC patterns extracted (3 adaptations; NO package install)

**Established:** 2026-06-01 (W4 Day-26) per `goal-w4-day-26-2026-06-01.md` Phase 1 Step 5.
**Source:** [affaan-m/ECC README](https://github.com/affaan-m/ECC) + general agent-harness pattern knowledge. The external guides (x.com threads on Token Optimization + Memory Persistence) were not directly readable; this learning extracts **principles** from the README's stated capabilities + adapts them IFOS-native — analogue of the Karpathy CLAUDE.md addition (2026-05-26 `CLAUDE.md` "Coding-agent discipline" section).

**Scope explicitly OUT:**
- No `ecc-universal` or `ecc-agentshield` npm install.
- No copy of ECC's 63 agents / 249 skills / 79 legacy command shims (would break IFOS's master-brief governance + Codex ratification).
- No replacement of CLAUDE.md's 5 rules / 4 boundaries / Karpathy section (those are IFOS-canonical).

**Scope IN:**
- 3 IFOS-native patterns inspired by ECC's "Token Optimization + Memory Persistence + Continuous Learning" principles, codified here so future sessions apply them by reflex.

---

## Pattern 1 — Lean live state + append-only history (already landed today)

**ECC principle:** "Memory persistence via hooks that save/load context across sessions automatically" + "system prompt slimming."

**IFOS adaptation (commit `29959bb`, 2026-06-01):** `.agents/current-priorities.md` refactored from 1161-line accretion → 67-line lean header; historical Day-N sections extracted verbatim to `docs/operations/decision-log.md` (newest-first, append-only). Session-startup re-read cost drops ~80%.

**Reflex rule:** Whenever `.agents/current-priorities.md` exceeds 120 lines, extract older "Day N — Shipped" sections into `docs/operations/decision-log.md`. Lean header always holds today's tactical state + active blockers + action board + clocks + W4 backlog + references. Nothing more.

## Pattern 2 — Read-on-demand for heavy plan docs

**ECC principle:** "Token Optimization | Model selection, system prompt slimming, background processes" — load only what's needed for the current task.

**IFOS friction:** the master brief (998 lines) + ULTRAPLAN (909 lines) get re-read every session per the CLAUDE.md ritual ("§1, §3, §6, §8, §10 in full"). That's expensive context — ~150 lines of CLAUDE.md + ~300 lines of master-brief + ~250 lines of ULTRAPLAN = ~700 lines of stable governance loaded before any work begins. Most sessions touch only one master-brief section.

**IFOS adaptation (reflex rule, no file change today):**
- On session start, always read CLAUDE.md + `.agents/current-priorities.md` (now lean) — that's the minimum.
- Read master-brief / ULTRAPLAN sections **on-demand** based on the task class:
  - Working on an agent.md? Read master-brief §8.2 + ULTRAPLAN §8.1 for that specific agent block.
  - Working on an ADR? Read master-brief §10.5 + the precedent ADRs (006, 007).
  - Working on a schema/migration? Read v0.3 supplement + tenancy-invariants §3.
  - Working on a connector? Read companies-house/xero pattern + `review-mcp-connector.md`.
- Don't pre-load the full master-brief §1/§3/§6/§8/§10 sweep "just in case." Reach when work touches.

**Why not codify in CLAUDE.md?** The existing CLAUDE.md ritual says read those sections "in full" — it's a load-bearing instruction the founder authored, and overriding it without explicit founder sign-off would relitigate. Instead, this learning notes the on-demand discipline as a Claude-side reflex; if the founder later wants to formalize it in CLAUDE.md, that's a separate edit.

## Pattern 3 — Session-end continuous-learning check

**ECC principle:** "Continuous Learning — auto-extract patterns from sessions into reusable skills."

**IFOS adaptation (reflex rule, no file change today):** at the end of every meaningful session, ask one question before closing: *"Did anything novel surface today that should become a `.agents/learnings/` entry?"* If yes, write it (≤200 lines, named `NN-<slug>.md`). The 4 existing learnings (00 quirks, 01 codex roundtrip, 02 ECC patterns (this), gstack-pin) all came from real friction; the pattern works when applied.

**Candidate triggers for a new learning entry:**
- A bug fix that surprised me (smoke path-bug → 4-candidate fallback was almost one; it became commit `d7d52c5` instead — but in retrospect the fallback pattern is reusable enough to deserve a learning entry on "wrong-dir-on-direct-source-tree-execution" — queued).
- A Codex finding I'd not have caught (every cluster-E round produced these; some are documented in `decision-log.md` but the META-pattern of "the agent-bundle reviewer keeps catching citation drift after my own edits" became learning 01).
- A founder decision that wasn't obvious in advance (e.g., D1-B Telegram shim — documented as `docs/decisions/2026-05-31-d1-founder-decision.md`, not a learning entry, because it's a project decision not a process rule).
- A failure mode that wasn't named in the goal's §6 (would become a `failure mode N+1` for future goals).

**Reflex rule:** at session end (per CLAUDE.md ritual addendum 2026-06-01), include in the handoff statement: "Learning candidates: <X | none>." Default to "none" if nothing novel; if there's a candidate, write it before tree-clean.

---

## Patterns explicitly NOT adopted from ECC (negative-scope, for clarity)

| ECC feature | Why not for IFOS |
|---|---|
| 63 agents library | Wrong domain — IFOS agents are vertical-anchored to master-brief §8.2 build waves; importing generic agents would noise the catalogue + relitigate ratified contracts |
| 249 skills library | gstack already provides ~80+ skills; adding 249 more = decision fatigue + naming collisions |
| `ecc-universal` package install | Would import opinionated runtime that conflicts with our `hh_decision_*` hooks + `_shared/hook-helpers.sh` (master-brief §8.1 Change 2) |
| `ecc-agentshield` package | Evaluate at first-pilot-tenant phase (post-LOI); not before |
| Multi-language adapters (Go/Java/Perl/etc.) | Pure TypeScript + bash stack; irrelevant |
| Dashboard GUI | Headless build; no UI need |
| Operator product surfaces (brand-voice, social-graph-ranker, customer-billing-ops, etc.) | Wrong product space — IFOS is recruitment-ops, not generic SaaS ops |
| Wholesale rules-framework adoption | Would conflict with 5 rules + 4 boundaries + Karpathy discipline (Codex-ratified governance) |

---

## Related

- `CLAUDE.md` "Coding-agent discipline (Karpathy guidelines)" (2026-05-26 commit `2978bdd`) — precedent for selective pattern adoption vs full package install
- `docs/operations/decision-log.md` 2026-06-01 entry — narrates this learning's authoring context
- `.agents/learnings/00-cortextos-quirks.md` — the original learnings-as-institutional-knowledge pattern
- `.agents/learnings/01-codex-roundtrip-discipline.md` — sibling learning landed earlier today
