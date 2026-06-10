# Concierge — directory README

**Status:** BUILT (W10-13 build slice; agent.md status flip remains founder-gated).

## What's in this directory

| File | Status |
|---|---|
| `agent.md` | CONTRACT (Proposed-with-disagreement-on-file; status flip founder-gated) |
| `cycle.sh` | BUILT — 15-step lifecycle workflow (spec-004 §4; every marker + ESC route) |
| `validate.sh` | BUILT — Gate A, all 6 checks (spec-004 §5; 30-min SLA is Gate B per ADR-007) |
| `context.sh` | BUILT — tenant_adapters reads (v0.4 keys) + honest token states |
| `cleanup.sh` | BUILT — live >24h cache purge (concierge_cleanup registration still queued) |
| `tools.yaml` | BUILT — capabilities + registration status + honest-scope header |
| `bin/bh-bridge.sh` | Bullhorn shim — single reconciliation point vs the Janitor-branch connector |
| `bin/render-concierge-draft.sh` | Deterministic templated render + optional LLM polish |
| `templates/common-comms-templates.yaml` | Shared comms library (12 events; bundled canonical copy) |
| `fixtures/` | 3 fixtures (primary / rejection-voice-drift / bridge-timeout canary) |

Test suites (auto-discovered by `scripts/build-gate.sh`):
`scripts/run-concierge-gate-a-test.sh`, `scripts/run-concierge-antidup-test.sh`,
`scripts/run-concierge-routing-test.sh`.

## What this is

The customer-comms agent — no candidate ghosted. Highest-stakes v1.0 agent.
12 lifecycle events; drafts are yellow-tier `concierge_email_draft`; the
customer-facing send is orange-tier `gmail_outlook_send_to_candidate`, gated
through the D1-B Telegram approval bridge (`@ifos/autosend-bridge-telegram` —
production wiring landed in this slice; it also closes Cash Conductor's
drafts-only→orange-send path).

## Honest-scope (what is NOT live)

- **Bullhorn**: creds EMPTY; connector CLI on the unmerged Janitor branch →
  all Bullhorn calls run fixture-mode via `bin/bh-bridge.sh` against the
  seeded `entities` cache. Live is founder-gated.
- **Email transport**: MS Graph / Gmail OAuth absent → Step 12 live send
  gated; fixtures prove the chain via `IFOS_FORCE_SEND_RESULT=sent`.
- **Telegram**: `TELEGRAM_BOT_TOKEN` EMPTY in the sandbox → live Bot API
  unexercised (fetch-mock-tested); the `/approve`–`/reject` command handler is
  `@ifos/telegram-surface` scope and NOT built (decisions recorded via the
  bridge's `record-decision.js` CLI until it lands).
- **Voice**: NO classifier exists in v1.0; drafts are `unscored/no_classifier`
  and Gate A G1 warn-and-passes them. Position thresholds (0.75/0.78/0.82)
  hard-enforce only on real numeric scores. Never faked.

## Ratification

Codex re-ratification post-build via `review-agent-bundle.md` (queued).

*End of Concierge README.*
