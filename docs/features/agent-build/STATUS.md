# Agent-build STATUS board

_Orchestrator refreshes this at every milestone (method doc §5). Founder reads it for an
at-a-glance view. `git log`/branch diffs are the ground truth._

**Phase:** DONE — **ALL FOUR AGENTS MERGED TO MAIN 2026-06-11 (founder sign-off given in-session; merge commits `cccbfc2`/`f685668`/`706eb3a`/`0da3744`).** Post-merge: full gate PASS on main (8 packages + 18 DB suites); worktrees/branches removed (Codex session logs preserved to `logs/codex-ratification/`); gate hardening + CC twin fixes landed (`ee8948c`/`e133535`/`8de4738`).
**Creds update 2026-06-11: founder reports the outstanding credentials are UNOBTAINABLE — all live smokes remain blocked indefinitely; agents stay fixture-proven. Pilot push proceeds on product completion instead (see brainstorm).**
**Runtime finding 2026-06-11:** `~/.cortextos/ifos-v2/` has NO rendered agents — no agent (incl. Diagnostic/CC) has ever been rendered/activated as a cortextOS daemon; all run via cycle.sh directly. `cortextos-ifos render-agent` (master brief §8.3) does not exist as a CLI command; our `packages/agent-renderer` + `scripts/provision-tenant.sh` are the real path. Activation strategy = open decision for the product-completion plan.

| Agent | Spec | Phase | Status | Branch | Live-smoke capable now? |
|---|---|---|---|---|---|
| Diagnostic | — | — | ✅ LIVE (template #1) | `main` | yes (Companies House + Anthropic) |
| Cash Conductor | — | — | ✅ LIVE (template #2) | `main` | yes (QB/Xero/TrueLayer sandboxes) |
| Sourcing Scout | `spec-003-sourcing-scout.md` | DONE | ✅ **MERGED** `f685668` (was @ `6f12953`) (15 commits): gate PASS · review PASS (all 7 deviations accepted) · Codex trail 4→4→2, every finding incorporated (final 2 post-run; loop closed per ≤2-round ceiling — founder judges trail). Live CV-Library smoke pending creds | `worktree-agent-a45354564e8f66257` | **NO — corrected 2026-06-10:** `CVLIBRARY_*` values are actually EMPTY (template comments fooled the naive SET check). Live smoke founder-gated: fill via `scripts/fill-dev-sandbox-secrets.sh` |
| Janitor | `spec-001-janitor.md` | DONE | ✅ **MERGED** `cccbfc2` (was @ `b505ae9`) (10 commits): gate PASS · review PASS (10 deviations accepted) · bullhorn CLI 52/52 (agreed contract incl. update-entity + extended create-note) · CH live smoke real data · Codex trail 4→4→3, every finding incorporated (final 3 post-run; ceiling) | `worktree-agent-abb2ffb971bb471ba` | partial — Companies House SMOKED live; **Bullhorn BLOCKED** (`write_state:deferred` honest rows) |
| Scribe | `spec-002-scribe.md` | DONE | ✅ **MERGED** `706eb3a` (was @ `f4d98d4`) (12 commits): gate PASS (DB suites verified RUN, not skipped) · review FAIL→fixed→re-review **PASS** (G6 blocker closed w/ tail-PII regression; F6 alternative judged better than prescribed) · Codex trail 4→3→4, every finding incorporated incl. the REAL Contact-call Gate-A bug Codex caught (hard-coded ≥3 vs 2 writable fields); final 4 post-run; ceiling | `worktree-agent-a59f16e915e384257` | no — **Bullhorn BLOCKED** + Granola token/0-meetings |
| Concierge | `spec-004-concierge.md` | DONE | ✅ **MERGED** `0da3744` (was @ `1f501dd`) (15 commits): gate PASS · review **PASS** (bridge wiring verified REAL — Bot API + pg approvals reader, 34/34 vitest; all 6 deviations accepted) · bh-bridge reconciled to Janitor's CLI (4 connector extensions honestly named) · Codex trail 4→3, every finding incorporated (final 3 post-run incl. the send_attempt/send_confirmed transport-truth contract; ceiling) | `worktree-agent-a4d7fb0c8ae47cca6` | no — Bullhorn + email OAuth + **TELEGRAM_BOT_TOKEN EMPTY** (verified); `/approve` handler = @ifos/telegram-surface scope (not this slice) |

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
- ✅ DONE 2026-06-11 (`8de4738`): **build-gate connector loop** extended (+bullhorn/cv-library/reed/autosend-bridge-telegram) AND **DB-suite silent skip** hardened (unreachable DB = FAIL; `--no-db` = PARTIAL exit 2, never PASS).
- ✅ DONE 2026-06-11 (`ee8948c`/`e133535`): **CC step-glob bug** fixed (12 guards word-boundary; weekly-report no longer mis-runs Steps 3+4) + **CC Composio-comment idiom** reworded generic.
- **Founder-gated policy registrations (Janitor adds):** `bullhorn_oauth` + `janitor_cleanup` action_types intentionally unregistered (same pattern as the Scout four).
