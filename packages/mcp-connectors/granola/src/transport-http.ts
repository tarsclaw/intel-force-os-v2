// Granola MCP HTTP transport — the default GranolaTransport implementation.
//
// Wraps @modelcontextprotocol/sdk's StreamableHTTPClientTransport + Client
// behind the thin `GranolaTransport` interface (src/types.ts), so the
// auth / rate-limit / plan-tier / error-mapping layers in GranolaClient stay
// transport-agnostic and the fixture suite can still inject a fake transport.
//
// AUTH: the Granola wrapper (GranolaClient.getValidToken) owns token loading +
// refresh. This transport is constructed with a `getToken` callback and injects
// `Authorization: Bearer <token>` on every HTTP request via a custom fetch, so a
// rotated token is always reflected without reconnecting.
//
// ERROR MAPPING: the GranolaClient.callTool loop expects the transport to RETURN
// a GranolaToolCallResult (with isError + _status_hint) rather than throw — that
// is how it maps 401/403/404/429/5xx into typed errors + retries. So transport-
// and HTTP-level failures here are caught and translated into that envelope
// (StreamableHTTPError.code → _status_hint), mirroring the fake transport.
//
// VERIFICATION STATUS: this file typechecks and the 33 fixture tests stay green
// (they inject a fake transport and never construct this class). The live path
// against https://mcp.granola.ai/mcp is UNVERIFIED until the Phase-1b live tests
// run (founder OAuth dance + ≥1 recorded meeting). Honest-signal per
// review-mcp-connector §10: a pre-built transport with no live test is acceptable
// IF marked unverified — it is, here and in README §Live tests.

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import {
  StreamableHTTPClientTransport,
  StreamableHTTPError,
} from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import type { GranolaToolCallResult, GranolaTransport } from "./types.js";

const CLIENT_INFO = { name: "ifos-granola", version: "0.1.0" };

export interface GranolaHttpTransportOptions {
  /** Granola MCP server URL (e.g. https://mcp.granola.ai/mcp). */
  mcp_server_url: string;
  /** Returns a fresh Bearer access token. Called per HTTP request so token
   *  rotation handled by GranolaClient.getValidToken is always reflected. */
  getToken: () => Promise<string>;
}

export class GranolaHttpTransport implements GranolaTransport {
  private readonly opts: GranolaHttpTransportOptions;
  private client: Client | null = null;
  private connecting: Promise<Client> | null = null;

  constructor(opts: GranolaHttpTransportOptions) {
    this.opts = opts;
  }

  /** Lazily connect once; concurrent callers share one connect Promise. */
  private async ensureClient(): Promise<Client> {
    if (this.client) return this.client;
    if (this.connecting) return this.connecting;

    const getToken = this.opts.getToken;
    const authedFetch = async (
      url: string | URL,
      init?: RequestInit,
    ): Promise<Response> => {
      const token = await getToken();
      const headers = new Headers(init?.headers);
      headers.set("Authorization", `Bearer ${token}`);
      return fetch(url, { ...init, headers });
    };

    this.connecting = (async () => {
      const transport = new StreamableHTTPClientTransport(
        new URL(this.opts.mcp_server_url),
        { fetch: authedFetch },
      );
      const client = new Client(CLIENT_INFO);
      await client.connect(transport);
      this.client = client;
      return client;
    })();

    try {
      return await this.connecting;
    } finally {
      this.connecting = null;
    }
  }

  async callTool(
    tool_name: string,
    args: Record<string, unknown>,
  ): Promise<GranolaToolCallResult> {
    let client: Client;
    try {
      client = await this.ensureClient();
    } catch (err) {
      return toErrorResult(err, `connect to ${this.opts.mcp_server_url} failed`);
    }
    try {
      const res = await client.callTool({ name: tool_name, arguments: args });
      return {
        content: normalizeContent(res.content),
        isError: res.isError === true,
      };
    } catch (err) {
      return toErrorResult(err, `Granola MCP tool '${tool_name}' call failed`);
    }
  }
}

/** Narrow the SDK's content-block union down to the IFOS envelope shape.
 *  Unknown block kinds are coerced to a text representation (never dropped). */
function normalizeContent(content: unknown): GranolaToolCallResult["content"] {
  if (!Array.isArray(content)) return [];
  const out: GranolaToolCallResult["content"] = [];
  for (const block of content) {
    const b = block as {
      type?: string;
      text?: unknown;
      uri?: unknown;
      resource?: { uri?: unknown };
    };
    if (b.type === "text" && typeof b.text === "string") {
      out.push({ type: "text", text: b.text });
    } else if (b.type === "resource" || b.type === "resource_link") {
      const uri =
        typeof b.uri === "string"
          ? b.uri
          : typeof b.resource?.uri === "string"
            ? b.resource.uri
            : "";
      out.push({ type: "resource", uri });
    } else {
      out.push({ type: "text", text: JSON.stringify(block) });
    }
  }
  return out;
}

/** Translate a thrown transport/HTTP error into the isError envelope the
 *  GranolaClient.callTool loop maps into typed errors. */
function toErrorResult(err: unknown, prefix: string): GranolaToolCallResult {
  let status = 0;
  if (err instanceof StreamableHTTPError && typeof err.code === "number") {
    status = err.code;
  }
  const message = err instanceof Error ? err.message : String(err);
  return {
    content: [{ type: "text", text: `${prefix}: ${message}` }],
    isError: true,
    _status_hint: status,
  };
}
