# Founder Decision D1 — autosend orange-tier path

**Status:** Accepted (founder-arbitrated 2026-05-31 via explicit delegation: *"i pretty much trust your decision making for the technical build stuff"*).
**Decision:** **D1-B — Telegram shim** for v1.0; D1-A as v1.1+ upgrade.
**Date:** 2026-05-31
**Author:** Claude Code (arbitrating per delegated authority); founder may override at any time before Concierge W10 build start.
**Supersedes:** the "D1 founder decision" line item in `2026-05-20-codex-round-1-founder-decisions.md` and the open-question rows in:
- `agents/recruitment/concierge/agent.md` §9 Q1
- `agents/recruitment/cash-conductor/agent.md` §8 (D1-pending fallback row)

---

## Context

Per `docs/decisions/autosend-safety-policy.md` §4, orange-tier action_types (customer-facing sends like `xero_reminder_send_customer`, `gmail_outlook_send_to_candidate`, `bullhorn_note_customer_visible`) require **synchronous consultant approval** before the send executes. The agent drafts; the consultant says yes; the transport fires; an audit row records the full chain.

Three paths were on the table for the v1.0 orange-tier approval mechanism:

| Option | Mechanism | v1.0 cost | Strengths | Weaknesses |
|---|---|---|---|---|
| **D1-A** Bridge to cortextOS approval system | Concierge POSTs to an internal cortextOS approval API; operator approves in Brain UI; bridge calls back | ~2 days build (~3 days if approval-API doesn't yet exist) | Architecturally clean; reuses cortextOS primitive #4 (approval gates); UX in Brain UI is consistent with other approval flows | Brain UI v1.0 approval UX not yet built; depends on cortextOS approval-API stability; tightest coupling to upstream |
| **D1-B** Lightweight Telegram shim | Concierge posts to operator's tenant-bound Telegram chat: `[ID:<x>] APPROVE drafted email to <recipient>? /approve <ID> or /reject <ID>`; Concierge polls Telegram or receives webhook; on approve → transport executes | <1 day build | Reuses cortextOS primitive #5 (Telegram surface) already in place; consultants are on Telegram already; lowest engineering cost; clean audit chain (every approve/reject = `decision_log` row); works the same for Cash Conductor + Concierge | Approval UX is a chat reply rather than a rich panel; per-draft attachment preview is just a 200-char text snippet + vault path; consultant must read the vault Markdown if they want to see the full draft body before approving |
| **D1-C** No autosend; manual pickup | Concierge writes the draft to vault; sets `requires_consultant_action=true`; no notification; consultant manually polls vault and copies drafts to outbound | 0 days build (already supported by drafts-to-vault flow) | Zero risk of incorrect autosend; zero new build | UX is brutal; consultants miss drafts; defeats Concierge's "no candidate ghosted" promise; effectively kills Concierge as a v1.0 differentiator |

---

## Decision: D1-B (Telegram shim)

**Why D1-B wins for v1.0:**

1. **Cost-aligned to v1.0 scope.** D1-A's clean architecture is the right *v1.1+* answer once Brain UI matures; for v1.0 ship, D1-B's <1-day build matches the W10-13 Concierge slice budget.
2. **Reuses an already-built primitive.** cortextOS primitive #5 (Telegram surface) is in place; operators already receive escalation notifications there. Adding `/approve <ID>` / `/reject <ID>` commands extends an existing surface rather than introducing a new one.
3. **Audit chain is identical to D1-A.** Both paths emit the same `decision_log` rows (`xero_reminder_send_customer` orange action → operator approve/reject → transport `gmail_outlook_send_to_candidate` action). The Telegram interaction is the trigger, not the audit substrate.
4. **D1-C kills Concierge's value.** Manual vault polling means missed drafts means ghosted candidates means Concierge fails its Gate B (`ghosted-rate <5%`). Non-starter.

**Tradeoff accepted:** the approval UX is text-only on Telegram. Consultants who want to see the full draft body before approving open the vault path in the Telegram message. This is the same friction as reviewing an email draft in any other ticket system; acceptable for v1.0.

**v1.1+ upgrade path (queued, not blocking):** D1-A bridge to cortextOS approval system + Brain UI rich-panel approval surface. The D1-B Telegram path stays available as a fallback (e.g., operator on the move, away from a desk). v1.1+ adds the *option* of D1-A, doesn't replace D1-B.

---

## Implementation surface (delivered by Concierge W10-13 build slice)

1. **`packages/utilities/autosend-bridge-telegram/`** — small TypeScript package:
   - `proposeApproval(action_type, target, draft_preview, vault_path, timeout=PT4H) → approval_id`
   - Posts to operator's tenant Telegram chat with `[ID:<approval_id>]` + draft preview + vault path + `/approve <id>` / `/reject <id>` instructions.
   - Polls or webhooks for the operator's reply.
   - Returns `{outcome: approved | rejected | timeout, decided_by: <telegram_user_id>}`.
   - Timeout default `PT4H` per `escalation-codes.md` `ESC_APPROVAL_BRIDGE_TIMEOUT` lines 348-353.
2. **Concierge `cycle.sh` Step 11** — calls `proposeApproval` for orange-tier drafts; on `approved`, proceeds to Step 12 transport; on `rejected` or `timeout`, fires `ESC_APPROVAL_BRIDGE_TIMEOUT` (timeout) or records rejection in `decision_log` (rejected).
3. **Cash Conductor `cycle.sh` Step 10** — same `proposeApproval` call for `xero_reminder_send_customer` rows; identical handling.
4. **`tools.yaml` capability declarations** — add `autosend_bridge_telegram` capability to both Concierge and Cash Conductor.
5. **Tenant config — W10-13 build-slice author picks the shape.** The autosend-bridge consumer needs a per-tenant operator Telegram chat-id at runtime. The actual v0.3 `validate_tenant_adapters_config_v0_3` allowlist (per `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` lines 432-442) contains 11 keys: `tier_overrides`, `blocked_recipients`, `janitor_dedup_threshold`, `janitor_last_run`, `pii_retention_days`, `approval_routing`, `approval_timeouts`, `sampling_rates`, `cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`. Two viable paths the W10-13 build-slice author chooses between (no v0.3 schema violation either way; no v0.4 supplement strictly required):
   - **Path A (reuse existing allowlist key)** — store the chat-id inside `approval_routing` JSONB (already allowed; matches `autosend-safety-policy.md` `approval_routing.default_recipient` shape). No schema work needed; the value lives in a sub-tree of an already-allowlisted key. Recommended.
   - **Path B (v0.4 supplement)** — add `operator_telegram_chat_id` as a new top-level allowlist key in a v0.4 supplement + migration. Cleaner identifier but more schema/migration work.

   **Current state (interim until W10-13 ships):** the bridge consumer's `context.sh` reads the chat-id via the `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback (see `agents/recruitment/concierge/context.sh` line 121 + Cash Conductor's equivalent). The autosend-bridge package itself takes the chat-id as a function argument per its README §Dependency injection — it never reads `tenant_adapters` directly. Fixtures (`agents/recruitment/concierge/fixtures/*.yaml`) use a `tenant_env_overrides:` block (not a `tenant_config:` block) to make the env-var-not-postgres distinction explicit. **No consumer code attempts to read a not-yet-allowlisted key at runtime; no schema violation occurs.**

   This decision-doc does NOT block on the path choice; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend); storage-location selection (Path A vs Path B) is a W10-13 implementation detail.

---

## Codex ratification

This decision doc ratifies via `.codex/ratification/review-architecture-decision.md` skill. Currently in flight under **cluster G** (`bash scripts/run-codex-ratification.sh --cluster G`); session-by-session ratification status is tracked in the closing Status-update line.

## Consequences

- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10-13 lands the autosend-bridge production wiring."
- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: ADR-007 Accepted + Codex RATIFIED (DONE 2026-05-31 + Round 3), pilot LOI (PENDING), Bullhorn A+B (PENDING), founder approves §9 Q2-Q6 (PENDING).
- **Schema impact: minimal-to-none.** Updated 2026-06-02 per Codex G-R3 closure: the v0.3 supplement allowlist (per `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` lines 432-442) already includes `approval_routing` — the W10-13 build slice can store the chat-id as a sub-key inside that JSONB without any v0.4 supplement work (Path A in implementation surface item 5). If the build-slice author prefers a top-level `operator_telegram_chat_id` key for cleanliness, a v0.4 supplement remains an option (Path B). Either way: the current consumer scaffolding (Concierge `context.sh` + 3 fixtures) reads via `IFOS_FORCE_*` env-var fallback and does NOT attempt any `tenant_adapters` read — no schema violation today.
- **No additional API keys/signups for the founder vault.** Day-4 provisioning (`docs/runbooks/day-4-provisioning.md` §6.5) creates the `_secrets.env` SKELETON only (touched empty at mode 0600); the Telegram bot token is populated by founder bootstrap (covered separately by tenant onboarding playbook — NOT Day-4), and the per-tenant operator chat-id is populated by tenant onboarding (W10-13 build slice; see implementation surface item 5 above). Once both are in place, no recurring credentials work — the bot token doesn't rotate per send; the chat-id is per-tenant-stable.
- **Schema-before-code discipline — respected.** The five rules (master brief §1) state schema-before-code. Today's state: bridge package scaffold + consumer wiring landed in env-var-fallback mode; no consumer attempts to read `tenant_adapters.config.operator_telegram_chat_id` (which isn't yet allowlisted as a top-level key) at runtime. Concierge `context.sh` lines 88-90 (post-2026-06-02 update) use `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback exclusively; fixtures use `tenant_env_overrides:` blocks (renamed from `tenant_config:` post-2026-06-02) to make the env-var-not-postgres distinction explicit. The schema-before-code rule holds: no schema-violating read occurs at runtime today; when the W10-13 build-slice author chooses Path A (reuse `approval_routing`) or Path B (add v0.4 key), the appropriate schema state will be in place BEFORE the consumer code is wired to read it.

---

*End of D1 decision doc.*

---

**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **all consumers operate in env-var-fallback mode today** (per `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` in `context.sh`); no `tenant_adapters` reads attempted at runtime; fixtures use `tenant_env_overrides:` blocks to match. W10-13 build slice picks Path A (reuse `approval_routing` allowlist key) or Path B (v0.4 supplement adding `operator_telegram_chat_id` top-level key); both paths satisfy schema-before-code. Codex ratification currently in flight under cluster G (R3 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc).
