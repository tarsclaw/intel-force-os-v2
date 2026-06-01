// Error types for @ifos/autosend-bridge-telegram. Maps to escalation codes per
// agents/_shared/escalation-codes.md §2 + the D1-B decision doc.

export class BridgeError extends Error {
  constructor(
    message: string,
    public readonly approval_id?: string,
    cause?: unknown,
  ) {
    // Use the ES2022 Error(message, options) form to set `cause` — it is
    // read-only on the Error prototype, so assignment after super() fails.
    super(message, cause !== undefined ? { cause } : undefined);
    this.name = "BridgeError";
  }
}

/** Thrown when input shape is wrong (caller bug, not a runtime escalation). */
export class BridgeInputError extends BridgeError {
  constructor(message: string) {
    super(message);
    this.name = "BridgeInputError";
  }
}

/**
 * Thrown when the Telegram transport fails to post the proposal message.
 * The agent layer should surface this as ESC_AGENT_TOOL_FAILURE (NOT
 * ESC_APPROVAL_BRIDGE_TIMEOUT — that one fires only when the message went out
 * and the operator never replied).
 */
export class BridgeTransportError extends BridgeError {
  constructor(message: string, cause?: unknown) {
    super(message, undefined, cause);
    this.name = "BridgeTransportError";
  }
}

/**
 * Thrown by `awaitApprovalDecision` when the deadline passes without an
 * operator reply. The agent layer MUST surface this as
 * ESC_APPROVAL_BRIDGE_TIMEOUT (escalation-codes.md lines 348-353; warn tier;
 * operator + ifos_oncall routing; PT4H default).
 *
 * Distinct from `outcome: "timeout"` — agents that prefer outcome-based control
 * flow get the discriminated union; agents that prefer try/catch get this.
 * Both reach the same place; pick the ergonomic one for the call site.
 */
export class BridgeTimeoutError extends BridgeError {
  constructor(approval_id: string, timeout_seconds: number) {
    super(
      `approval timed out after ${timeout_seconds}s without operator reply`,
      approval_id,
    );
    this.name = "BridgeTimeoutError";
  }
}
