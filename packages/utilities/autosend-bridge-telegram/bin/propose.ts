// CLI: propose an orange-tier approval to the operator's Telegram chat.
//
// Usage (Concierge cycle.sh Step 11 / Cash Conductor cycle.sh Step 10):
//   node dist/bin/propose.js \
//     --action gmail_outlook_send_to_candidate \
//     --tenant <slug> \
//     --operator-chat <telegram-chat-id> \
//     --target <recipient-email> \
//     --preview <≤500-char draft preview> \
//     --vault-path /vault/<slug>/concierge-drafts/<id>.md \
//     [--timeout-seconds 14400]
//
// stdout: {"approval_id": "...", "posted_at_iso": "...", "expires_at_iso": "..."}
//
// env:
//   TELEGRAM_BOT_TOKEN  — required (production); sourced by the shell layer
//                         from the tenant/sandbox _secrets.env. Never logged.
//   IFOS_BRIDGE_FAKE    — approve|reject|timeout: fixture mode; skips the
//                         Telegram post entirely; output carries "fake": true.

import { proposeApproval } from "../src/bridge.js";
import { createTelegramTransport } from "../src/transport-telegram.js";
import type { SupportedActionType, TelegramTransport } from "../src/types.js";
import { emit, fail, fakeMode, parseArgs, requireArg } from "./cli-shared.js";

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const action = requireArg(args, "action") as SupportedActionType;
  const tenant = requireArg(args, "tenant");
  const operatorChat = requireArg(args, "operator-chat");
  const target = requireArg(args, "target");
  const preview = requireArg(args, "preview");
  const vaultPath = requireArg(args, "vault-path");
  const timeoutSeconds = args.has("timeout-seconds")
    ? Number(args.get("timeout-seconds"))
    : undefined;

  const fake = fakeMode();
  let transport: TelegramTransport;
  if (fake) {
    transport = {
      // Fixture mode: no network; record nothing. The approval message text is
      // still rendered + input validation still runs inside proposeApproval;
      // only the Telegram post is skipped.
      postMessage: async () => ({ message_id: "fake-0" }),
    };
  } else {
    const token = process.env.TELEGRAM_BOT_TOKEN;
    if (!token) {
      fail(
        "TELEGRAM_BOT_TOKEN unset — cannot post to Telegram. " +
          "Set IFOS_BRIDGE_FAKE=approve|reject|timeout for fixture runs, or provision the bot token.",
      );
    }
    transport = createTelegramTransport({ bot_token: token as string });
  }

  const result = await proposeApproval(
    {
      action_type: action,
      tenant_slug: tenant,
      operator_telegram_chat_id: operatorChat,
      target,
      draft_preview: preview,
      vault_path: vaultPath,
      timeout_seconds: timeoutSeconds,
    },
    { transport, decisions: { fetchDecision: async () => null } },
  );

  emit(fake ? { ...result, fake: true } : result);
}

main().catch((err: unknown) => {
  fail((err as Error)?.message ?? String(err));
});
