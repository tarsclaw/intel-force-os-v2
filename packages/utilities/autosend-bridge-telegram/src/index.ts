// @ifos/autosend-bridge-telegram — public API
//
// Per D1-B founder decision (docs/decisions/2026-05-31-d1-founder-decision.md):
// orange-tier autosend gating via Telegram operator approval.

export {
  proposeApproval,
  awaitApprovalDecision,
  awaitApprovalDecisionOrThrow,
} from "./bridge.js";

export {
  BridgeError,
  BridgeInputError,
  BridgeTransportError,
  BridgeTimeoutError,
} from "./errors.js";

export {
  renderApprovalMessage,
  truncatePreview,
  ID_TOKEN_RE,
  MAX_PREVIEW_CHARS,
} from "./message-format.js";

export {
  DEFAULT_POLL_INTERVAL_SECONDS,
  DEFAULT_TIMEOUT_SECONDS,
} from "./types.js";

export type {
  ApprovalOutcome,
  AwaitApprovalInput,
  AwaitApprovalResult,
  BridgeDependencies,
  Clock,
  DecisionSource,
  PendingDecision,
  ProposeApprovalInput,
  ProposeApprovalResult,
  SupportedActionType,
  TelegramTransport,
} from "./types.js";

export const VERSION = "0.1.0";
