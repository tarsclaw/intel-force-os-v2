// Tests for the W10-13 production wiring: createTelegramTransport (real Bot
// API shape, fetch-mocked — no network) + createPostgresDecisionSource
// (psql-runner-mocked — no DB). Mirrors the offline-test posture of the rest
// of the suite.

import { describe, expect, it } from "vitest";

import {
  RECORD_DECISION_SQL,
  createPostgresDecisionSource,
} from "../src/decisions-postgres.js";
import { createTelegramTransport } from "../src/transport-telegram.js";
import type { FetchLike } from "../src/transport-telegram.js";

function fakeFetch(
  status: number,
  body: unknown,
  calls: Array<{ url: string; body: string }> = [],
): FetchLike {
  return async (url, init) => {
    calls.push({ url, body: init.body });
    return {
      ok: status >= 200 && status < 300,
      status,
      text: async () => (typeof body === "string" ? body : JSON.stringify(body)),
    };
  };
}

describe("createTelegramTransport", () => {
  it("POSTs sendMessage with chat_id + text and returns the message_id", async () => {
    const calls: Array<{ url: string; body: string }> = [];
    const transport = createTelegramTransport({
      bot_token: "TEST:token",
      fetch: fakeFetch(200, { ok: true, result: { message_id: 4242 } }, calls),
    });

    const res = await transport.postMessage({ chat_id: "987654321", text: "[ID:abc] hello" });

    expect(res.message_id).toBe("4242");
    expect(calls).toHaveLength(1);
    expect(calls[0].url).toBe("https://api.telegram.org/botTEST:token/sendMessage");
    const sent = JSON.parse(calls[0].body) as Record<string, unknown>;
    expect(sent.chat_id).toBe("987654321");
    expect(sent.text).toBe("[ID:abc] hello");
  });

  it("throws on HTTP non-2xx without leaking the bot token", async () => {
    const transport = createTelegramTransport({
      bot_token: "SECRET-TOKEN-VALUE",
      fetch: fakeFetch(403, { ok: false, description: "Forbidden: bot was blocked" }),
    });
    await expect(
      transport.postMessage({ chat_id: "1", text: "x" }),
    ).rejects.toThrow(/HTTP 403/);
    await expect(
      transport.postMessage({ chat_id: "1", text: "x" }),
    ).rejects.not.toThrow(/SECRET-TOKEN-VALUE/);
  });

  it("throws when Telegram replies ok:false even with HTTP 200", async () => {
    const transport = createTelegramTransport({
      bot_token: "t",
      fetch: fakeFetch(200, { ok: false, description: "chat not found" }),
    });
    await expect(transport.postMessage({ chat_id: "1", text: "x" })).rejects.toThrow(
      /chat not found/,
    );
  });

  it("throws on network failure without leaking the URL (token-bearing)", async () => {
    const transport = createTelegramTransport({
      bot_token: "TOKEN-XYZ",
      fetch: async () => {
        throw new Error("ECONNRESET");
      },
    });
    const err = await transport.postMessage({ chat_id: "1", text: "x" }).catch((e: Error) => e);
    expect(err).toBeInstanceOf(Error);
    expect((err as Error).message).toContain("ECONNRESET");
    expect((err as Error).message).not.toContain("TOKEN-XYZ");
  });

  it("refuses construction without a bot token", () => {
    expect(() => createTelegramTransport({ bot_token: "" })).toThrow(/bot_token/);
  });
});

describe("createPostgresDecisionSource", () => {
  it("returns null while no decision row exists", async () => {
    const source = createPostgresDecisionSource({
      db_url: "postgresql://x",
      tenant_slug: "t1",
      runPsql: async () => "\n",
    });
    expect(await source.fetchDecision("aid-1")).toBeNull();
  });

  it("parses an approved decision row and is RLS/tenant-scoped via psql vars", async () => {
    const seen: { args?: string[]; sql?: string } = {};
    const source = createPostgresDecisionSource({
      db_url: "postgresql://x",
      tenant_slug: "t1",
      runPsql: async (args, sql) => {
        seen.args = args;
        seen.sql = sql;
        return `${JSON.stringify({
          approval_id: "aid-1",
          outcome: "approved",
          decided_by: "tg-555",
          decided_at_iso: "2026-06-10T10:00:00.000Z",
        })}\n`;
      },
    });

    const decision = await source.fetchDecision("aid-1");
    expect(decision).toEqual({
      approval_id: "aid-1",
      outcome: "approved",
      decided_by: "tg-555",
      decided_at_iso: "2026-06-10T10:00:00.000Z",
    });
    expect(seen.args).toContain("tenant=t1");
    expect(seen.args).toContain("aid=aid-1");
    expect(seen.sql).toContain("SET LOCAL app.current_tenant");
    expect(seen.sql).toContain("agent_name = 'autosend-bridge'");
  });

  it("parses a rejected decision row", async () => {
    const source = createPostgresDecisionSource({
      db_url: "postgresql://x",
      tenant_slug: "t1",
      runPsql: async () =>
        `${JSON.stringify({ approval_id: "aid-2", outcome: "rejected", decided_by: "tg-9", decided_at_iso: "2026-06-10T11:00:00.000Z" })}\n`,
    });
    const decision = await source.fetchDecision("aid-2");
    expect(decision?.outcome).toBe("rejected");
  });

  it("treats payload/outcome disagreement as still-pending (defensive)", async () => {
    const source = createPostgresDecisionSource({
      db_url: "postgresql://x",
      tenant_slug: "t1",
      runPsql: async () => `${JSON.stringify({ approval_id: "aid-3", outcome: "weird" })}\n`,
    });
    expect(await source.fetchDecision("aid-3")).toBeNull();
  });

  it("propagates psql failures (caller surfaces ESC, not a silent approve)", async () => {
    const source = createPostgresDecisionSource({
      db_url: "postgresql://x",
      tenant_slug: "t1",
      runPsql: async () => {
        throw new Error("psql failed: connection refused");
      },
    });
    await expect(source.fetchDecision("aid-4")).rejects.toThrow(/connection refused/);
  });

  it("RECORD_DECISION_SQL is first-valid-reply-wins (NOT EXISTS guard) + RLS-scoped", () => {
    expect(RECORD_DECISION_SQL).toContain("WHERE NOT EXISTS");
    expect(RECORD_DECISION_SQL).toContain("SET LOCAL app.current_tenant");
    expect(RECORD_DECISION_SQL).toContain("'autosend-bridge'");
  });
});
