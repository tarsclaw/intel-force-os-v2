# Agent-build STATUS board

_Orchestrator refreshes this at every milestone (method doc §5). Founder reads it for an
at-a-glance view. `git log`/branch diffs are the ground truth._

**Phase:** 2 (FAN-OUT) + 3 (review loop on Scout). Substrate frozen 2026-06-10. Prove-one validated the machine end-to-end: implement worker → gate-green branch (orchestrator-verified) → review sub-agent PASS (all 7 deviations accepted) → Codex round 1 REJECTED on agent.md doc-accuracy only (4 issues, no code findings) → fix worker dispatched; Codex round 2 pending. Janitor + Scribe workers fanned out in parallel worktrees.

| Agent | Spec | Phase | Status | Branch | Live-smoke capable now? |
|---|---|---|---|---|---|
| Diagnostic | — | — | ✅ LIVE (template #1) | `main` | yes (Companies House + Anthropic) |
| Cash Conductor | — | — | ✅ LIVE (template #2) | `main` | yes (QB/Xero/TrueLayer sandboxes) |
| Sourcing Scout | `spec-003-sourcing-scout.md` | 5 (MERGE GATE) | ✅ **PROPOSED FOR FOUNDER MERGE** @ `6f12953` (15 commits): gate PASS · review PASS (all 7 deviations accepted) · Codex trail 4→4→2, every finding incorporated (final 2 post-run; loop closed per ≤2-round ceiling — founder judges trail). Live CV-Library smoke pending creds | `worktree-agent-a45354564e8f66257` | **NO — corrected 2026-06-10:** `CVLIBRARY_*` values are actually EMPTY (template comments fooled the naive SET check). Live smoke founder-gated: fill via `scripts/fill-dev-sandbox-secrets.sh` |
| Janitor | `spec-001-janitor.md` | 5 (MERGE GATE) | ✅ **PROPOSED FOR FOUNDER MERGE** @ `b505ae9` (10 commits): gate PASS · review PASS (10 deviations accepted) · bullhorn CLI 52/52 (agreed contract incl. update-entity + extended create-note) · CH live smoke real data · Codex trail 4→4→3, every finding incorporated (final 3 post-run; ceiling) | `worktree-agent-abb2ffb971bb471ba` | partial — Companies House SMOKED live; **Bullhorn BLOCKED** (`write_state:deferred` honest rows) |
| Scribe | `spec-002-scribe.md` | 3 (re-review) | 🟡 fix pass landed (`91bc167`): G6 full-body scan + tail-PII regression test (F1 CLOSED pending re-review), agent.md Granola rewrite, shim → agreed contract; targeted re-review in flight; Codex R2 REJECTED:3 (Contact 2-writable-fields vs ≥3 claim; Gate B webhook anchor; ESC catalogue lag → amended on main `425d5ab`); final fix pass next | `worktree-agent-a59f16e915e384257` | no — **Bullhorn BLOCKED** + Granola token/0-meetings |
| Concierge | `spec-004-concierge.md` | 3 (iterating) | 🟡 review **PASS** (`04-reviews/review-concierge.md`; bridge wiring verified REAL; all 6 deviations accepted; 2 MAJORs on fix track: bh-bridge live-branch reconciliation + agent.md honesty pass); Codex R1 REJECTED:4 (stale-contract class) → combined fix pass in flight; final Codex run next | `worktree-agent-a4d7fb0c8ae47cca6` | no — Bullhorn + email OAuth + **TELEGRAM_BOT_TOKEN EMPTY** (verified); `/approve` handler = @ifos/telegram-surface scope (not this slice) |

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
- **build-gate connector loop** hard-codes 4 packages; add `cv-library` + `reed` + `bullhorn` + `autosend-bridge-telegram` in ONE orchestrator-proposed main-side change post-merge (avoids parallel-branch conflicts).
- **build-gate DB-suite silent skip** (Codex meta-finding, Scribe session `20260610T154432Z-44557`): when `IFOS_DB_URL` is unreachable the DB fixture suites SKIP rather than fail — the gate can look green in DB-less environments. Harden post-merge: hard-fail (or loud `SKIPPED — NOT EVIDENCE` banner + nonzero exit) when the DB is unreachable.
- **CC cycle.sh latent step-glob bug** (Janitor worker finding): a `*2*`-style step glob matches "12" — Janitor's copy fixed on its branch; CC's copy untouched (surgical rule). Patch CC in a later slice.
- **Founder-gated policy registrations (Janitor adds):** `bullhorn_oauth` + `janitor_cleanup` action_types intentionally unregistered (same pattern as the Scout four).
