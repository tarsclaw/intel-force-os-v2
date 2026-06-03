// Capabilities tests — exercise each capability against a fake transport,
// covering happy paths + PlanTierInsufficient on 403 (the v0.1.0 unique
// error class) + the pre-emptive plan-tier guard.
// Per review-mcp-connector §6 (happy + error path per capability) plus the
// /goal-specified ≥2 capability tests including PlanTierInsufficient-on-403.

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";

import {
  GranolaAuthError,
  GranolaClient,
  GranolaPlanTierInsufficientError,
  PAID_PLAN_TOOLS,
  getAccountInfo,
  getMeeting,
  getTranscript,
  listFolders,
  listMeetings,
  queryMeetings,
  resetRateLimit,
  saveTokens,
} from "../src/index.js";
import type {
  GranolaConfig,
  GranolaToolCallResult,
  GranolaTransport,
} from "../src/index.js";

let token_file: string;

function makeConfig(): GranolaConfig {
  return {
    client_id: "fake-client",
    workspace_id: "ws-capabilities",
    token_file_path: token_file,
  };
}

async function seedTokens(config: GranolaConfig): Promise<void> {
  await saveTokens(config, {
    access_token: "fake-access",
    refresh_token: "fake-refresh",
    expires_at_ms: Date.now() + 600_000,
    token_type: "Bearer",
  });
}

/** Build a fake transport that returns canned results per tool name. */
function makeFakeTransport(
  responses: Record<string, GranolaToolCallResult | (() => GranolaToolCallResult)>,
): GranolaTransport & { calls: { tool: string; args: Record<string, unknown> }[] } {
  const calls: { tool: string; args: Record<string, unknown> }[] = [];
  return {
    calls,
    async callTool(tool_name, args) {
      calls.push({ tool: tool_name, args });
      const r = responses[tool_name];
      if (!r) {
        return {
          content: [{ type: "text", text: "no canned response" }],
          isError: true,
          _status_hint: 500,
        };
      }
      return typeof r === "function" ? r() : r;
    },
  };
}

function textResult(jsonBody: unknown): GranolaToolCallResult {
  return {
    content: [{ type: "text", text: JSON.stringify(jsonBody) }],
  };
}

function errorResult(status: number, msg: string): GranolaToolCallResult {
  return {
    content: [{ type: "text", text: msg }],
    isError: true,
    _status_hint: status,
  };
}

beforeEach(() => {
  resetRateLimit();
  token_file = join(
    tmpdir(),
    `granola-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`,
  );
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
});

describe("granola capabilities — meetings", () => {
  it("listMeetings happy path returns parsed meetings", async () => {
    const config = makeConfig();
    await seedTokens(config);
    const transport = makeFakeTransport({
      list_meetings: textResult({
        meetings: [
          {
            id: "m_1",
            title: "Standup",
            start_time: "2026-06-03T09:00:00Z",
            end_time: "2026-06-03T09:30:00Z",
            duration_minutes: 30,
            folder_id: null,
            attendees: ["alice@acme.test", "bob@acme.test"],
            notes_markdown: "# Standup notes",
            has_transcript: true,
            created_at: "2026-06-03T09:30:00Z",
            updated_at: "2026-06-03T09:30:00Z",
          },
        ],
      }),
    });
    const client = new GranolaClient({ config, transport });
    const meetings = await listMeetings(client, {
      start_date: "2026-06-01",
      end_date: "2026-06-03",
    });
    expect(meetings).toHaveLength(1);
    expect(meetings[0]?.id).toBe("m_1");
    expect(meetings[0]?.attendees).toEqual(["alice@acme.test", "bob@acme.test"]);
    expect(transport.calls[0]?.tool).toBe("list_meetings");
    expect(transport.calls[0]?.args.start_date).toBe("2026-06-01");
  });

  it("getMeeting returns null on 404 (does not throw)", async () => {
    const config = makeConfig();
    await seedTokens(config);
    const transport = makeFakeTransport({
      get_meetings: errorResult(404, "not found"),
    });
    const client = new GranolaClient({ config, transport });
    const m = await getMeeting(client, "m_missing");
    expect(m).toBeNull();
  });

  it("queryMeetings passes the query argument through", async () => {
    const config = makeConfig();
    await seedTokens(config);
    const transport = makeFakeTransport({
      query_granola_meetings: textResult({ meetings: [] }),
    });
    const client = new GranolaClient({ config, transport });
    const results = await queryMeetings(client, { query: "candidate dropout" });
    expect(results).toEqual([]);
    expect(transport.calls[0]?.args.query).toBe("candidate dropout");
  });
});

describe("granola capabilities — paid-plan guard", () => {
  it("listFolders throws GranolaPlanTierInsufficientError when plan_tier_hint='free' (pre-emptive)", async () => {
    const config = makeConfig();
    await seedTokens(config);
    let transportCalled = false;
    const transport: GranolaTransport = {
      async callTool() {
        transportCalled = true;
        return textResult({ folders: [] });
      },
    };
    const client = new GranolaClient({ config, transport });
    await expect(
      listFolders(client, { plan_tier_hint: "free" }),
    ).rejects.toBeInstanceOf(GranolaPlanTierInsufficientError);
    // Critical: pre-guard means the transport is NEVER hit
    expect(transportCalled).toBe(false);
  });

  it("getTranscript throws GranolaPlanTierInsufficientError on 403 from upstream", async () => {
    const config = makeConfig();
    await seedTokens(config);
    const transport = makeFakeTransport({
      get_meeting_transcript: errorResult(403, "Paid plan required"),
    });
    const client = new GranolaClient({ config, transport });
    await expect(
      getTranscript(client, "m_1", { plan_tier_hint: "paid" }),
    ).rejects.toBeInstanceOf(GranolaPlanTierInsufficientError);
  });

  it("PAID_PLAN_TOOLS gates only folders + transcripts; meeting tools are NOT gated", async () => {
    const config = makeConfig();
    await seedTokens(config);
    const transport = makeFakeTransport({
      list_meetings: textResult({ meetings: [] }),
    });
    const client = new GranolaClient({ config, transport });
    // Should NOT throw — list_meetings is not in PAID_PLAN_TOOLS
    const result = await listMeetings(client, { plan_tier_hint: "free" });
    expect(result).toEqual([]);
    expect(PAID_PLAN_TOOLS.has("list_meetings")).toBe(false);
  });

  it("listFolders happy path returns parsed folders when plan_tier_hint='paid'", async () => {
    const config = makeConfig();
    await seedTokens(config);
    const transport = makeFakeTransport({
      list_meeting_folders: textResult({
        folders: [
          {
            id: "f_1",
            name: "Client meetings",
            parent_folder_id: null,
            meeting_count: 12,
            created_at: "2026-01-01T00:00:00Z",
            updated_at: "2026-06-01T00:00:00Z",
          },
        ],
      }),
    });
    const client = new GranolaClient({ config, transport });
    const folders = await listFolders(client, { plan_tier_hint: "paid" });
    expect(folders).toHaveLength(1);
    expect(folders[0]?.name).toBe("Client meetings");
  });
});

describe("granola capabilities — transcripts", () => {
  it("getTranscript happy path returns parsed transcript on Paid plan", async () => {
    const config = makeConfig();
    await seedTokens(config);
    const transport = makeFakeTransport({
      get_meeting_transcript: textResult({
        meeting_id: "m_1",
        language: "en",
        duration_seconds: 1800,
        generated_at: "2026-06-03T10:00:00Z",
        segments: [
          { start_seconds: 0, end_seconds: 5.2, speaker: "Speaker 1", text: "Hello." },
          { start_seconds: 5.2, end_seconds: 9.8, speaker: "Speaker 2", text: "Hi." },
        ],
      }),
    });
    const client = new GranolaClient({ config, transport });
    const t = await getTranscript(client, "m_1", { plan_tier_hint: "paid" });
    expect(t?.meeting_id).toBe("m_1");
    expect(t?.segments).toHaveLength(2);
    expect(t?.segments[0]?.text).toBe("Hello.");
  });
});

describe("granola capabilities — account", () => {
  it("getAccountInfo returns parsed plan_tier", async () => {
    const config = makeConfig();
    await seedTokens(config);
    const transport = makeFakeTransport({
      get_account_info: textResult({
        workspace_id: "ws-capabilities",
        workspace_name: "Acme Workspace",
        plan_tier: "paid",
        user_email: "founder@acme.test",
        transcripts_enabled: true,
        folders_enabled: true,
      }),
    });
    const client = new GranolaClient({ config, transport });
    const info = await getAccountInfo(client);
    expect(info.plan_tier).toBe("paid");
    expect(info.workspace_name).toBe("Acme Workspace");
    expect(info.transcripts_enabled).toBe(true);
  });
});

describe("granola capabilities — error mapping", () => {
  it("401 on a non-Paid tool surfaces as GranolaAuthError when no refresh is possible", async () => {
    const config = makeConfig();
    await seedTokens(config);
    let callCount = 0;
    const transport: GranolaTransport = {
      async callTool() {
        callCount += 1;
        // Always 401 — even after a refresh, the server keeps rejecting
        return errorResult(401, "unauthorised");
      },
    };
    const client = new GranolaClient({ config, transport });
    await expect(getAccountInfo(client)).rejects.toBeInstanceOf(GranolaAuthError);
    // didForceRefresh allows one retry but the refresh itself would also
    // need to succeed; since refreshTokens fetches the network, we expect
    // it to fail (real fetch fails without a server). So callCount stays low.
    expect(callCount).toBeGreaterThanOrEqual(1);
  });

  it("No-tokens-on-disk surfaces as GranolaAuthError on first getValidToken", async () => {
    const config = makeConfig();
    // NO seedTokens() call — file is missing
    const transport: GranolaTransport = {
      async callTool() {
        return textResult({ meetings: [] });
      },
    };
    const client = new GranolaClient({ config, transport });
    await expect(listMeetings(client)).rejects.toBeInstanceOf(GranolaAuthError);
  });
});
