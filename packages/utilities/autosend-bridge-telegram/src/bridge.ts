// Core bridge implementation. Stateless wrt the package — all state lives in
// the injected `TelegramTransport` + `DecisionSource` so callers can swap a
// production wiring (Telegram Bot API + postgres approvals table) for the
// in-memory test wiring without changing the bridge.

import { randomUUID } from "node:crypto";

import {
  BridgeInputError,
  BridgeTimeoutError,
  BridgeTransportError,
} from "./errors.js";
import { renderApprovalMessage } from "./message-format.js";
import {
  DEFAULT_POLL_INTERVAL_SECONDS,
  DEFAULT_TIMEOUT_SECONDS,
} from "./types.js";
import type {
  AwaitApprovalInput,
  AwaitApprovalResult,
  BridgeDependencies,
  Clock,
  ProposeApprovalInput,
  ProposeApprovalResult,
  SupportedActionType,
} from "./types.js";

const SUPPORTED_ACTIONS: ReadonlySet<SupportedActionType> = new Set([
  "gmail_outlook_send_to_candidate",
  "xero_reminder_send_customer",
]);

const realClock: Clock = {
  nowMs: () => Date.now(),
  sleepMs: (ms) => new Promise((r) => setTimeout(r, ms)),
};

function validateProposeInput(input: ProposeApprovalInput): void {
  if (!SUPPORTED_ACTIONS.has(input.action_type)) {
    throw new BridgeInputError(
      `action_type "${input.action_type}" not registered for the approval bridge ` +
        `(supported: ${[...SUPPORTED_ACTIONS].join(", ")}). ` +
        `Register in autosend-policy.yaml at orange tier first, then add to SupportedActionType.`,
    );
  }
  if (!input.tenant_slug) throw new BridgeInputError("tenant_slug is required");
  if (!input.operator_telegram_chat_id) {
    throw new BridgeInputError("operator_telegram_chat_id is required");
  }
  if (!input.target) throw new BridgeInputError("target is required");
  if (!input.draft_preview) throw new BridgeInputError("draft_preview is required");
  if (!input.vault_path) throw new BridgeInputError("vault_path is required");
  if (
    input.timeout_seconds !== undefined &&
    (!Number.isFinite(input.timeout_seconds) || input.timeout_seconds <= 0)
  ) {
    throw new BridgeInputError("timeout_seconds, if provided, must be positive finite");
  }
}

/**
 * Posts an orange-tier autosend proposal to the operator's Telegram chat and
 * returns the approval-id + deadline. Caller is expected to record the result
 * (approval-id, expires_at) on the originating `decision_log` row and then
 * call `awaitApprovalDecision(approval_id)` (typically in the same tick).
 */
export async function proposeApproval(
  input: ProposeApprovalInput,
  deps: BridgeDependencies,
): Promise<ProposeApprovalResult> {
  validateProposeInput(input);

  const clock = deps.clock ?? realClock;
  const generate = deps.generateApprovalId ?? (() => randomUUID());

  const approval_id = generate();
  const timeoutSecs = input.timeout_seconds ?? DEFAULT_TIMEOUT_SECONDS;
  const posted_at_iso = new Date(clock.nowMs()).toISOString();
  const expires_at_iso = new Date(clock.nowMs() + timeoutSecs * 1000).toISOString();

  const text = renderApprovalMessage(input, approval_id, expires_at_iso);

  try {
    await deps.transport.postMessage({
      chat_id: input.operator_telegram_chat_id,
      text,
    });
  } catch (cause) {
    throw new BridgeTransportError(
      `Telegram postMessage failed for approval ${approval_id}; ` +
        `agent layer should surface ESC_AGENT_TOOL_FAILURE, not ESC_APPROVAL_BRIDGE_TIMEOUT`,
      cause,
    );
  }

  return { approval_id, posted_at_iso, expires_at_iso };
}

/**
 * Polls the `DecisionSource` until the operator decides or the deadline
 * passes. Default behaviour returns `{outcome: "timeout"}` on expiry (matches
 * the discriminated-union surface in the D1-B doc); if `throwOnTimeout` is set
 * via wrapper, swap for `BridgeTimeoutError`.
 *
 * Defence-in-depth: we always treat the absolute deadline (`expires_at_iso`)
 * as authoritative — not "N polls × interval" — so a paused/slow event loop
 * doesn't accidentally extend the window past PT4H.
 */
export async function awaitApprovalDecision(
  input: AwaitApprovalInput,
  deps: BridgeDependencies,
): Promise<AwaitApprovalResult> {
  if (!input.approval_id) throw new BridgeInputError("approval_id is required");

  const clock = deps.clock ?? realClock;
  const pollMs = (input.poll_interval_seconds ?? DEFAULT_POLL_INTERVAL_SECONDS) * 1000;

  // Compute deadline. If caller supplied expires_at_iso (the contract — they
  // got it from proposeApproval), trust it; otherwise fall back to the default
  // window measured from now (lets callers use the polling layer for an
  // already-posted approval, e.g. on agent restart).
  const deadlineMs = input.expires_at_iso
    ? Date.parse(input.expires_at_iso)
    : clock.nowMs() + DEFAULT_TIMEOUT_SECONDS * 1000;

  if (!Number.isFinite(deadlineMs)) {
    throw new BridgeInputError(`expires_at_iso is not a valid ISO timestamp: ${input.expires_at_iso}`);
  }

  for (;;) {
    const decision = await deps.decisions.fetchDecision(input.approval_id);
    if (decision) {
      return {
        outcome: decision.outcome,
        decided_by: decision.decided_by,
        decided_at_iso: decision.decided_at_iso,
      };
    }

    if (clock.nowMs() >= deadlineMs) {
      return { outcome: "timeout" };
    }

    // Sleep until the next poll OR the deadline, whichever comes first.
    const remainingMs = deadlineMs - clock.nowMs();
    await clock.sleepMs(Math.min(pollMs, Math.max(remainingMs, 0)));
  }
}

/**
 * Convenience wrapper that throws BridgeTimeoutError on expiry instead of
 * returning `outcome: "timeout"`. Useful for callers that prefer try/catch
 * control flow (the Concierge/Cash Conductor cycle.sh wrappers prefer this).
 */
export async function awaitApprovalDecisionOrThrow(
  input: AwaitApprovalInput,
  deps: BridgeDependencies,
  timeout_seconds = DEFAULT_TIMEOUT_SECONDS,
): Promise<Exclude<AwaitApprovalResult, { outcome: "timeout" }>> {
  const result = await awaitApprovalDecision(input, deps);
  if (result.outcome === "timeout") {
    throw new BridgeTimeoutError(input.approval_id, timeout_seconds);
  }
  return result as Exclude<AwaitApprovalResult, { outcome: "timeout" }>;
}
