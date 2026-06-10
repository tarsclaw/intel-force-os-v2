# `@ifos/autosend-bridge-telegram`

Telegram approval-bridge for orange-tier autosend gating. Backs the **D1-B founder decision** (`docs/decisions/2026-05-31-d1-founder-decision.md`) — consumed by **Concierge `cycle.sh` Step 11** + **Cash Conductor `cycle.sh` Step 10**.

**Status:** Production wiring LANDED (W10-13 Concierge build slice) — `createTelegramTransport` (real Telegram Bot API `sendMessage`) + `createPostgresDecisionSource` (postgres approvals reader over `decision_log`) + the `dist/bin/{propose,await,record-decision}.js` CLI entrypoints the agent shells consume. **Honest-scope caveats:** (1) the Telegram **/approve — /reject command handler** that turns operator replies into decision rows is `@ifos/telegram-surface` scope and NOT yet built — until it exists, decisions are recorded via `dist/bin/record-decision.js` (the single writer; the future handler calls the same CLI). (2) `TELEGRAM_BOT_TOKEN` is EMPTY in the dev sandbox as of 2026-06-10 — the live transport is built + fetch-mock-tested but has not been exercised against the real Bot API.

---

## Why this package exists

The autosend safety policy (`agents/_shared/autosend-policy.yaml`) classifies every outbound action into one of four tiers — green / yellow / orange / red. **Orange** actions (e.g. `gmail_outlook_send_to_candidate`, `xero_reminder_send_customer`) require **human approval before transport**. The agent proposes; the operator approves or rejects via Telegram; the agent then either sends or discards.

The D1 founder decision evaluated three options:

| Option | Cost | Outcome |
|---|---|---|
| D1-A — cortextOS approval system + Brain UI rich-panel | weeks of build | Right v1.1+ answer; too expensive for v1.0 |
| **D1-B — Telegram `/approve`/`/reject` commands** (chosen) | <1 day | Reuses cortextOS primitive #5 (Telegram surface); ships in W10–13 |
| D1-C — manual vault polling | none | Concierge fails Gate B (ghosted-rate <5%); non-starter |

Audit chain is identical to D1-A: same `decision_log` rows fire (orange action → operator approve/reject → transport action). The Telegram interaction is the **trigger**, not the audit substrate. v1.1+ can add D1-A as an option without replacing D1-B.

---

## Public API

```ts
import {
  proposeApproval,
  awaitApprovalDecision,
  awaitApprovalDecisionOrThrow,
} from "@ifos/autosend-bridge-telegram";
```

### `proposeApproval(input, deps): Promise<ProposeApprovalResult>`

Posts an orange-tier autosend proposal to the operator's tenant Telegram chat.

- Renders an approval message that contains `[ID:<approval_id>]` (the load-bearing token the Telegram bot parser uses to match `/approve <id>` and `/reject <id>` replies), the action type, the target, a ≤500-char draft preview, the vault path for the full draft, the expiry timestamp, and the operator commands.
- Returns `{approval_id, posted_at_iso, expires_at_iso}`.
- The agent layer is expected to record `approval_id` + `expires_at_iso` on the originating `decision_log` row before calling `awaitApprovalDecision`.

### `awaitApprovalDecision(input, deps): Promise<AwaitApprovalResult>`

Polls the injected `DecisionSource` until the operator decides or the absolute deadline passes.

- Returns `{outcome: "approved" | "rejected" | "timeout", decided_by?, decided_at_iso?}`.
- **Authoritative deadline** is `expires_at_iso` (NOT "N polls × interval") — a paused / slow event loop can't accidentally extend the window past `PT4H`.
- Default poll cadence: `DEFAULT_POLL_INTERVAL_SECONDS = 30s`. Override via `poll_interval_seconds`.
- The final sleep is capped to the remaining window so we wake at the deadline exactly.

### `awaitApprovalDecisionOrThrow(input, deps, timeout_seconds?)`

Convenience wrapper for try/catch-style call sites: throws `BridgeTimeoutError` on expiry rather than returning `outcome: "timeout"`. The Concierge / Cash Conductor `cycle.sh` wrappers use this form so the script's `set -e` propagates the timeout naturally.

---

## Dependency injection

Everything stateful is **injected**:

```ts
interface BridgeDependencies {
  transport: TelegramTransport;   // production: @ifos/telegram-surface Bot API client
  decisions: DecisionSource;      // production: postgres `approvals` table reader
  clock?: Clock;                  // production: real Date.now + setTimeout
  generateApprovalId?: () => string;  // production: crypto.randomUUID
}
```

This is what lets the test suite run the **full PT4H timeout flow in <50ms** — the fake clock advances inside `sleepMs`, the in-memory decision source satisfies the same interface as the production postgres reader, and the test transport records posts without hitting the Telegram API.

The production constructions (landed in the W10-13 Concierge build slice; both in this package):

- `transport` from `createTelegramTransport({bot_token})` — real Bot API `sendMessage` over global fetch (node ≥20); injectable `fetch` for tests; the bot token is never logged or echoed in error messages
- `decisions` from `createPostgresDecisionSource({db_url, tenant_slug})` — RLS-scoped reader over `decision_log` rows with `agent_name='autosend-bridge'` (NO new `approvals` table — schema-before-code: decisions live in the same append-only audit substrate; see `src/decisions-postgres.ts` header). Zero npm deps: it shells `psql` via `execFile` with psql `-v` variables (no SQL interpolation of caller input); injectable `runPsql` keeps tests offline
- `clock` and `generateApprovalId` omitted (defaults are correct in production)

### CLI entrypoints (the shell-layer contract)

Built to `dist/bin/` by tsup; consumed by Concierge `cycle.sh` Step 11 + Cash Conductor `cycle.sh` Step 10:

```bash
node dist/bin/propose.js  --action gmail_outlook_send_to_candidate --tenant <slug> \
  --operator-chat <chat-id> --target <email> --preview <text> \
  --vault-path <path> [--timeout-seconds 14400]      # → {approval_id, posted_at_iso, expires_at_iso}
node dist/bin/await.js    --approval-id <id> --tenant <slug> [--expires-at <ISO>]
                                                      # → {outcome: approved|rejected|timeout, ...}; exit 0 for all three
node dist/bin/record-decision.js --approval-id <id> --tenant <slug> \
  --outcome approved|rejected --decided-by <tg-user>  # → {ok, recorded}; first-valid-reply-wins
```

Env: `TELEGRAM_BOT_TOKEN` (propose, production), `IFOS_DB_URL` (await + record-decision). Fixture mode: `IFOS_BRIDGE_FAKE=approve|reject|timeout` short-circuits network/DB deterministically (output carries `"fake": true`).

---

## Escalation mapping

| Failure | Surface | Escalation code |
|---|---|---|
| Telegram `postMessage` fails | `BridgeTransportError` | `ESC_AGENT_TOOL_FAILURE` |
| Operator never replies before `expires_at` | `outcome: "timeout"` or `BridgeTimeoutError` | `ESC_APPROVAL_BRIDGE_TIMEOUT` (warn; operator + ifos_oncall; PT4H default) |
| Operator replies with `/reject` | `outcome: "rejected"` | Recorded in `decision_log`; no escalation fired |

`ESC_APPROVAL_BRIDGE_TIMEOUT` lives at `agents/_shared/escalation-codes.md` lines 348-353. Recovery: action converts to manual reconciliation; operator handles offline.

---

## State-change race

If the underlying state changes between proposal and approval — e.g. a Cash Conductor chase is proposed at 15:00, the customer pays at 15:30, the operator approves at 15:45 — the **agent layer** (not this package) must detect that the action no longer applies and emit `ESC_AUTOSEND_RACE` with `race_class: state_change_cancellation` instead of executing the transport. This package is intentionally state-agnostic.

---

## Adding a new orange action

1. Register the action_type in `agents/_shared/autosend-policy.yaml` at orange severity (with the required approval-window, escalation routing, etc).
2. Add the action_type string to `SupportedActionType` in `src/types.ts`.
3. Re-run `pnpm test` — the validation tests will pass automatically; the type system enforces orange-tier-only at compile time.
4. Wire the call from the agent's `cycle.sh` (mirroring Concierge Step 11 or Cash Conductor Step 10).

If you skip step 2 the call fails fast with `BridgeInputError` at runtime — by design. The list is enumerated rather than `string` so a typo doesn't quietly post an unauthorised approval.

---

## Tests

```bash
pnpm --filter @ifos/autosend-bridge-telegram test
```

Coverage targets:

- `proposeApproval`: posting + payload shape + input validation + transport failure
- `awaitApprovalDecision`: approved + rejected + timeout + polling cadence + deadline capping
- `awaitApprovalDecisionOrThrow`: throw on timeout + unwrap on decision
- `renderApprovalMessage` / `truncatePreview` / `ID_TOKEN_RE`: format invariants

All tests use the fake clock — no real wall-clock waits.

---

## Out of scope (v1.0)

- **Webhook mode** — production polls; webhook support deferred to v1.1+ if poll cost matters.
- **Rich Telegram cards / buttons** — plain-text `/approve <id>` / `/reject <id>` is the v1.0 surface. Buttons add a permission / parsing layer that doesn't earn its weight at v1.0 scale.
- **Multi-operator quorum** — first valid reply wins. Multi-operator quorum is a v1.1+ feature gated on Concierge usage patterns.

---

## References

- D1-B decision: `docs/decisions/2026-05-31-d1-founder-decision.md`
- Autosend policy: `agents/_shared/autosend-policy.yaml`
- Escalation catalogue: `agents/_shared/escalation-codes.md` §2.6 (`ESC_APPROVAL_BRIDGE_TIMEOUT`) + §2.7 (`ESC_AUTOSEND_RACE`)
- Concierge agent.md: §4 Step 11 (consumer)
- Cash Conductor agent.md: §4 Step 10 (consumer)
