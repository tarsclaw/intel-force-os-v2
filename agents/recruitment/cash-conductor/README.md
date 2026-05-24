# Cash Conductor — directory README

**Status:** Proposed (Day-18 pre-W7-8-build scaffold).

## What's in this directory

| File | Status |
|---|---|
| `agent.md` | Proposed |
| `README.md` | Proposed |

## Strategic value

**Most-independent v1.0 agent.** Zero Bullhorn dependency. Operates against accounting system + Open Banking only. Per ADR-005 §5.1: pull-forward candidate if Bullhorn paths delayed past 2026-06-10.

## What's NOT in this directory (yet)

Full bundle at W7-8 build (~2 weeks per ULTRAPLAN A4 line 541):

- `tools.yaml` — Xero / QuickBooks / Sage / Open Banking (TrueLayer or Plaid UK) MCP connectors
- `context.sh` — multi-provider auth refresh + voice corpus + 90-day token monitor
- `validate.sh` — Gate A (invoice + amount + contact triple check + paid-in-24h block per ULTRAPLAN A4 line 539)
- `cycle.sh` — 14-step workflow (most complex of v1.0 agents)
- `cleanup.sh` — token rotation + transaction cache rolling-90d-window cleanup
- `fixtures/01-primary-exact-match.yaml` — golden: Stage-1 exact-amount reconciliation
- `fixtures/02-edge-case-fuzzy-match.yaml` — Stage-3 fuzzy match; consultant review queued
- `fixtures/99-chase-paid-canary.yaml` — adversarial: chase proposed for invoice paid 12h ago — Gate A must reject (per ULTRAPLAN A4 line 539 verbatim)

## Hire #1 anchor

Per master brief §8.2 line 604: "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". Recommend Hire #1 owns:
- Open Banking MCP connector + ESC_OPEN_BANKING_TOKEN_AGING UX
- TrueLayer vs Plaid UK provider integration depth

## Ratification

Codex Round 4 Phase 2 (Day 20) via `review-architecture-decision.md`.

*End of Cash Conductor README.*
