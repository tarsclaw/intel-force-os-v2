// Production TelegramTransport — real Telegram Bot API `sendMessage`.
//
// W10-13 Concierge build slice (per spec-004 §8: "autosend-bridge production
// wiring is THIS build's deliverable"). Replaces the test-only in-memory
// transport for live runs; the in-memory transport remains the unit-test
// wiring (BridgeDependencies are injected — see README §Dependency injection).
//
// Failure semantics: ANY failure to post (network error, non-2xx, Telegram
// `ok:false`) throws — the bridge layer wraps it in BridgeTransportError and
// the agent layer surfaces ESC_AGENT_TOOL_FAILURE (NOT
// ESC_APPROVAL_BRIDGE_TIMEOUT; that fires only when the message went out and
// the operator never replied).
//
// Secrets discipline: the bot token is passed in by the caller (sourced from
// the tenant/sandbox _secrets.env by the shell layer); it is never logged and
// never included in thrown error messages.

import type { TelegramTransport } from "./types.js";

const TELEGRAM_API_BASE = "https://api.telegram.org";

/** Minimal fetch surface so tests can inject a fake without node-fetch typings. */
export type FetchLike = (
  url: string,
  init: { method: string; headers: Record<string, string>; body: string },
) => Promise<{ ok: boolean; status: number; text(): Promise<string> }>;

export interface TelegramTransportConfig {
  /** Telegram bot token (from TELEGRAM_BOT_TOKEN; never logged). */
  bot_token: string;
  /** Override the API base (tests / self-hosted Bot API server). */
  api_base?: string;
  /** Injectable fetch (tests). Defaults to global fetch (node ≥ 20). */
  fetch?: FetchLike;
}

/**
 * Builds the production TelegramTransport over the Bot API.
 *
 * POST {api_base}/bot{token}/sendMessage  {chat_id, text}
 * → { ok: true, result: { message_id: number, ... } }
 */
export function createTelegramTransport(config: TelegramTransportConfig): TelegramTransport {
  if (!config.bot_token) {
    throw new Error("createTelegramTransport: bot_token is required (TELEGRAM_BOT_TOKEN)");
  }
  const apiBase = config.api_base ?? TELEGRAM_API_BASE;
  const doFetch: FetchLike = config.fetch ?? (globalThis.fetch as unknown as FetchLike);

  return {
    async postMessage(input: { chat_id: string; text: string }): Promise<{ message_id: string }> {
      const url = `${apiBase}/bot${config.bot_token}/sendMessage`;
      let response: Awaited<ReturnType<FetchLike>>;
      try {
        response = await doFetch(url, {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({
            chat_id: input.chat_id,
            text: input.text,
            // Plain text on purpose — /approve and /reject parse as commands;
            // markdown entities in draft previews would 400 on bad escapes.
            disable_web_page_preview: true,
          }),
        });
      } catch (cause) {
        // Never echo the URL — it embeds the bot token.
        throw new Error(
          `telegram sendMessage network failure (chat_id=${input.chat_id}): ${(cause as Error)?.message ?? "unknown"}`,
        );
      }

      const bodyText = await response.text();
      if (!response.ok) {
        throw new Error(
          `telegram sendMessage HTTP ${response.status} (chat_id=${input.chat_id}): ${truncateForError(bodyText)}`,
        );
      }

      let parsed: { ok?: boolean; result?: { message_id?: number | string }; description?: string };
      try {
        parsed = JSON.parse(bodyText) as typeof parsed;
      } catch {
        throw new Error(`telegram sendMessage returned non-JSON body (chat_id=${input.chat_id})`);
      }
      if (parsed.ok !== true || parsed.result?.message_id === undefined) {
        throw new Error(
          `telegram sendMessage rejected (chat_id=${input.chat_id}): ${parsed.description ?? "ok=false"}`,
        );
      }
      return { message_id: String(parsed.result.message_id) };
    },
  };
}

function truncateForError(text: string, max = 200): string {
  return text.length <= max ? text : `${text.slice(0, max)}…`;
}
