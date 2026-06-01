// @ifos/autosend-bridge-telegram — public types
//
// Mirrors the D1-B founder-decision implementation surface
// (docs/decisions/2026-05-31-d1-founder-decision.md §"Implementation surface").

/** Default approval window per ESC_APPROVAL_BRIDGE_TIMEOUT (escalation-codes.md lines 348-353). */
export const DEFAULT_TIMEOUT_SECONDS = 4 * 60 * 60; // PT4H

/** Poll cadence default (operator latency vs. API call cost balance). */
export const DEFAULT_POLL_INTERVAL_SECONDS = 30;

/**
 * Action types currently consuming the bridge.
 * Keep this enumerated rather than `string` so callers get a hard compile-time
 * error if they try to propose an action_type that has not been registered in
 * autosend-policy.yaml at the orange tier.
 *
 * Add new entries here when (and only when) the corresponding action lands in
 * autosend-policy.yaml at orange severity.
 */
export type SupportedActionType =
  | "gmail_outlook_send_to_candidate" // Concierge orange
  | "xero_reminder_send_customer"; // Cash Conductor orange

export interface ProposeApprovalInput {
  /** Audit-log action_type (must be orange per autosend-policy.yaml). */
  action_type: SupportedActionType;
  /** Tenant slug for routing + the audit row. */
  tenant_slug: string;
  /** Telegram chat ID for the tenant's operator (from tenant_adapters.config.operator_telegram_chat_id). */
  operator_telegram_chat_id: string;
  /** Recipient/contextual handle (email, phone, customer name) the operator will use to identify the draft. */
  target: string;
  /** Short preview (≤500 chars; Telegram message-length budget). */
  draft_preview: string;
  /** Full vault path the operator can open for the complete draft body. */
  vault_path: string;
  /** Timeout in seconds. Default `DEFAULT_TIMEOUT_SECONDS` (PT4H). */
  timeout_seconds?: number;
  /** ID of the originating decision_log row (used by ESC_APPROVAL_BRIDGE_TIMEOUT payload). */
  originating_decision_log_id?: string;
}

export interface ProposeApprovalResult {
  /** Unique approval-id, also embedded as `[ID:<id>]` in the Telegram message. */
  approval_id: string;
  /** ISO timestamp the proposal was posted. */
  posted_at_iso: string;
  /** Computed deadline ISO (posted_at + timeout). */
  expires_at_iso: string;
}

export type ApprovalOutcome = "approved" | "rejected" | "timeout";

export interface AwaitApprovalInput {
  approval_id: string;
  /** Optional override of the poll interval (mainly for testing). */
  poll_interval_seconds?: number;
  /** Optional override of the expiry deadline (mainly for testing). */
  expires_at_iso?: string;
}

export interface AwaitApprovalResult {
  outcome: ApprovalOutcome;
  /** Telegram user-id of the operator who decided (undefined on timeout). */
  decided_by?: string;
  /** ISO timestamp the decision was recorded (undefined on timeout). */
  decided_at_iso?: string;
}

/**
 * One operator decision row read from the Telegram polling layer.
 * Production wiring: the @ifos/telegram-surface package writes rows to a
 * postgres approvals table; the bridge polls it.
 * Test wiring: an in-memory store satisfies the interface.
 */
export interface PendingDecision {
  approval_id: string;
  outcome: Exclude<ApprovalOutcome, "timeout">;
  decided_by: string;
  decided_at_iso: string;
}

/** Injectable transport — production = Telegram Bot API; tests = in-memory recorder. */
export interface TelegramTransport {
  /** Posts the approval message; returns the Telegram message ID for traceability. */
  postMessage(input: { chat_id: string; text: string }): Promise<{ message_id: string }>;
}

/** Injectable decision-source — production = postgres approvals table; tests = in-memory map. */
export interface DecisionSource {
  /** Returns the decision for a given approval-id if one has landed; null otherwise. */
  fetchDecision(approval_id: string): Promise<PendingDecision | null>;
}

/** Clock + sleep injection so tests don't have to actually wait PT4H. */
export interface Clock {
  nowMs(): number;
  sleepMs(ms: number): Promise<void>;
}

export interface BridgeDependencies {
  transport: TelegramTransport;
  decisions: DecisionSource;
  clock?: Clock;
  /** Override of the approval-id generator (defaults to crypto.randomUUID). */
  generateApprovalId?: () => string;
}
