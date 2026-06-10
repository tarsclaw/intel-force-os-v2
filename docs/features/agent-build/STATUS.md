# Agent-build STATUS board

_Orchestrator refreshes this at every milestone (method doc §5). Founder reads it for an
at-a-glance view. `git log`/branch diffs are the ground truth._

**Phase:** 2 (FAN-OUT) + 3 (review loop on Scout). Substrate frozen 2026-06-10. Prove-one validated the machine end-to-end: implement worker → gate-green branch (orchestrator-verified) → review sub-agent PASS (all 7 deviations accepted) → Codex round 1 REJECTED on agent.md doc-accuracy only (4 issues, no code findings) → fix worker dispatched; Codex round 2 pending. Janitor + Scribe workers fanned out in parallel worktrees.

| Agent | Spec | Phase | Status | Branch | Live-smoke capable now? |
|---|---|---|---|---|---|
| Diagnostic | — | — | ✅ LIVE (template #1) | `main` | yes (Companies House + Anthropic) |
| Cash Conductor | — | — | ✅ LIVE (template #2) | `main` | yes (QB/Xero/TrueLayer sandboxes) |
| Sourcing Scout | `spec-003-sourcing-scout.md` | 3 (review loop) | 🟡 review PASS; Codex R1 fixed (4/4, `66b46cf`); Codex R2 REJECTED w/ 4 NEW doc findings (voice-gate wording, unregistered action_type declarations, §10 lifecycle, Composio-comment idiom) → final fix pass in flight; one last ratification run, then disagreement-doc/escalate per ≤2-round ceiling | `worktree-agent-a45354564e8f66257` | **NO — corrected 2026-06-10:** `CVLIBRARY_*` values are actually EMPTY (template comments fooled the naive SET check). Live smoke founder-gated: fill via `scripts/fill-dev-sandbox-secrets.sh` |
| Janitor | `spec-001-janitor.md` | 2 | 🔨 implementing — worktree sub-agent in flight (owns `packages/mcp-connectors/bullhorn` CLI bridge this cycle) | TBC on report | partial — Companies House yes; **Bullhorn BLOCKED** |
| Scribe | `spec-002-scribe.md` | 2 | 🔨 implementing — worktree sub-agent in flight (Bullhorn via local `bin/bh-bridge.sh` shim; no `packages/` edits) | TBC on report | no — **Bullhorn BLOCKED** + Granola token/0-meetings |
| Concierge | `spec-004-concierge.md` | 4 (last) | ⚪ not started | — | no — Bullhorn + autosend-bridge wiring + email OAuth |

## Gate readiness (method doc §4)
- ✅ Worktree isolation — available (`Agent` tool `isolation: "worktree"`).
- ✅ Pre-commit hook — `.githooks/pre-commit` active (`core.hooksPath=.githooks`); blocks broken-shell commits.
- ✅ Merge gate — `scripts/build-gate.sh` (green on current tree).
- ⏸ Review tier — review sub-agent prompt + `run-codex-ratification.sh` per branch (orchestrator runs at review).
- ✅ Human merge gate — founder.

## Cross-cutting truths (read before fan-out)
1. **Bullhorn dev creds are unobtainable** (long-standing blocker). Janitor/Scribe/Concierge cores
   hit Bullhorn → they BUILD to gate-green + fixture-proven, but **live-Bullhorn-smoke is a
   founder-gated post-creds step.** Acceptance bar for those = fixture-proven + gate-green.
2. **Sourcing Scout is the only fully live-smokeable remaining agent now** (CV-Library creds SET,
   read-only on Bullhorn → degraded-mode skips it). Best live prove-one demo.
3. **Concierge's autosend-bridge production wiring (its W10-13 deliverable) also unblocks Cash
   Conductor's drafts-only→orange-send path** — build it once, two agents go live.
4. Empty `voice_corpus` → record `unscored/no_corpus`, never a faked score (CC precedent).

## Founder actions that unblock LIVE (build proceeds without them)
- **CV-Library creds (CORRECTED 2026-06-10: actually EMPTY — `KEY= # comment` template lines fooled the naive SET check). Fill via `bash scripts/fill-dev-sandbox-secrets.sh` → unblocks the Sourcing Scout live smoke.**
- Bullhorn dev sandbox creds (unblocks Janitor/Scribe/Concierge + Sourcing Scout source #1).
- Reed API creds (unblocks Sourcing Scout source #2).
- Granola IFOS-side OAuth token on disk + ≥1 recorded meeting (unblocks Scribe live transcript).
- MS Graph / Gmail OAuth per tenant (unblocks Concierge live send).
- Apply v0.5 migration to prod VPS (unblocks Cash Conductor prod reconciliation writes).

## Follow-ups surfaced by the Scout review loop (orchestrator-tracked)
- **Codex R2 precedent conflict:** the `# No Composio/AgentMail references` negative-assertion comment idiom (present in the RATIFIED cash-conductor tools.yaml) is now read by Codex as an adapter-boundary violation. Scout's copy reworded on its branch; CC's copy left untouched (surgical). Founder decision: align CC's comment in a later slice or file a disagreement doc.
- **Founder-gated policy registrations:** `sourcing_scout_cleanup` + `bullhorn_oauth`/`reed_oauth`/`cvlibrary_oauth` action_types are intentionally NOT registered in `agents/_shared/autosend-policy.yaml` (tier decisions need founder input). tools.yaml reworded to future-registration notes; cleanup.sh stays `hh_decision_output`.
- **build-gate connector loop** hard-codes 4 packages; add `cv-library` + `reed` (+ `bullhorn` once Janitor lands its CLI bridge) in ONE orchestrator-proposed main-side change post-merge (avoids parallel-branch conflicts).
