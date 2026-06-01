// Message-template rendering for the Telegram approval proposal.
//
// Telegram's plain-text message budget is 4096 bytes; we cap draft_preview at
// 500 chars + a fixed scaffold (~600 chars) to leave comfortable headroom.
//
// The `[ID:<approval_id>]` token is load-bearing: the Telegram bot command
// handler in @ifos/telegram-surface uses it to match `/approve <id>` and
// `/reject <id>` replies back to the originating proposal.

import type { ProposeApprovalInput } from "./types.js";

export const MAX_PREVIEW_CHARS = 500;
export const ID_TOKEN_RE = /^\[ID:[0-9a-f-]{8,}\]$/i;

export function truncatePreview(preview: string, max = MAX_PREVIEW_CHARS): string {
  if (preview.length <= max) return preview;
  return `${preview.slice(0, max - 1)}…`;
}

export function renderApprovalMessage(
  input: ProposeApprovalInput,
  approval_id: string,
  expires_at_iso: string,
): string {
  const preview = truncatePreview(input.draft_preview);
  const lines: string[] = [
    `[ID:${approval_id}]`,
    "",
    `🟠 ORANGE-tier autosend awaiting your decision`,
    "",
    `action: ${input.action_type}`,
    `tenant: ${input.tenant_slug}`,
    `target: ${input.target}`,
    `vault: ${input.vault_path}`,
    `expires: ${expires_at_iso}`,
    "",
    "— draft preview —",
    preview,
    "—",
    "",
    `Reply  /approve ${approval_id}  to send,  /reject ${approval_id}  to discard.`,
  ];
  return lines.join("\n");
}
