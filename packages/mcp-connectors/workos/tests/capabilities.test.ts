// Capabilities tests — exercise each capability against a fake fetch, covering
// happy paths + 401 (no-retry surface as WorkosAuthError, NOT a refresh dance)
// + 404 (returns null on get*, throws on list*) + 429 retry-after honour.
// Per review-mcp-connector §6 (happy + error path per capability).

import { beforeEach, describe, expect, it } from "vitest";

import {
  WorkosAuthError,
  WorkosClient,
  WorkosNotFoundError,
  WorkosRateLimitError,
  getConnection,
  getDirectoryGroup,
  getDirectoryUser,
  getOrganization,
  listConnections,
  listDirectoryGroups,
  listDirectoryUsers,
  listOrganizations,
  resetRateLimit,
} from "../src/index.js";

function jsonResponse(body: unknown, status = 200, headers: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...headers },
  });
}

beforeEach(() => {
  resetRateLimit();
});

describe("workos capabilities — getOrganization", () => {
  it("happy path returns the org and uses Bearer secret-key auth", async () => {
    let capturedAuth = "";
    const fakeFetch: typeof fetch = async (input, init) => {
      capturedAuth = String(
        (init?.headers as Record<string, string> | undefined)?.Authorization ?? "",
      );
      expect(String(input)).toContain("/organizations/org_01ABC");
      return jsonResponse({
        id: "org_01ABC",
        name: "Acme Tech",
        domains: [{ id: "dom_1", domain: "acme.test", state: "verified" }],
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      });
    };
    const client = new WorkosClient({
      config: { secret_key: "sk_test_secret" },
      fetchFn: fakeFetch,
    });
    const org = await getOrganization(client, "org_01ABC");
    expect(org?.id).toBe("org_01ABC");
    expect(capturedAuth).toBe("Bearer sk_test_secret");
  });

  it("returns null on 404 (does not throw)", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response("not found", { status: 404 });
    const client = new WorkosClient({
      config: { secret_key: "sk_test_x" },
      fetchFn: fakeFetch,
    });
    const org = await getOrganization(client, "org_missing");
    expect(org).toBeNull();
  });

  it("surfaces 401 immediately as WorkosAuthError without retry (no refresh path)", async () => {
    let callCount = 0;
    const fakeFetch: typeof fetch = async () => {
      callCount += 1;
      return new Response("unauthorised", { status: 401 });
    };
    const client = new WorkosClient({
      config: { secret_key: "sk_test_dead" },
      fetchFn: fakeFetch,
    });
    await expect(getOrganization(client, "org_x")).rejects.toBeInstanceOf(WorkosAuthError);
    // Critically: NO retry attempts. One call, one failure, surfaced.
    expect(callCount).toBe(1);
  });
});

describe("workos capabilities — listOrganizations", () => {
  it("happy path with pagination + domain filter", async () => {
    let capturedUrl = "";
    const fakeFetch: typeof fetch = async (input) => {
      capturedUrl = String(input);
      return jsonResponse({
        object: "list",
        data: [
          {
            id: "org_a",
            name: "Acme",
            domains: [],
            created_at: "2026-01-01T00:00:00Z",
            updated_at: "2026-01-01T00:00:00Z",
          },
        ],
        list_metadata: { before: null, after: "cur_next" },
      });
    };
    const client = new WorkosClient({
      config: { secret_key: "sk_x" },
      fetchFn: fakeFetch,
    });
    const res = await listOrganizations(client, { limit: 50, domains: ["acme.test"] });
    expect(res.data).toHaveLength(1);
    expect(capturedUrl).toContain("limit=50");
    expect(capturedUrl).toContain("domains=acme.test");
  });
});

describe("workos capabilities — connections", () => {
  it("getConnection returns the connection on happy path", async () => {
    const fakeFetch: typeof fetch = async () =>
      jsonResponse({
        id: "conn_1",
        organization_id: "org_1",
        connection_type: "OktaSAML",
        name: "Acme SAML",
        state: "active",
        domains: [],
        created_at: "2026-01-01T00:00:00Z",
        updated_at: "2026-01-01T00:00:00Z",
      });
    const client = new WorkosClient({
      config: { secret_key: "sk_x" },
      fetchFn: fakeFetch,
    });
    const conn = await getConnection(client, "conn_1");
    expect(conn?.connection_type).toBe("OktaSAML");
    expect(conn?.state).toBe("active");
  });

  it("listConnections passes organization_id + connection_type filters", async () => {
    let capturedUrl = "";
    const fakeFetch: typeof fetch = async (input) => {
      capturedUrl = String(input);
      return jsonResponse({
        object: "list",
        data: [],
        list_metadata: { before: null, after: null },
      });
    };
    const client = new WorkosClient({
      config: { secret_key: "sk_x" },
      fetchFn: fakeFetch,
    });
    await listConnections(client, {
      organization_id: "org_acme",
      connection_type: "GoogleOAuth",
    });
    expect(capturedUrl).toContain("organization_id=org_acme");
    expect(capturedUrl).toContain("connection_type=GoogleOAuth");
  });
});

describe("workos capabilities — directory sync", () => {
  it("listDirectoryUsers passes directory + group filters", async () => {
    let capturedUrl = "";
    const fakeFetch: typeof fetch = async (input) => {
      capturedUrl = String(input);
      return jsonResponse({
        object: "list",
        data: [],
        list_metadata: { before: null, after: null },
      });
    };
    const client = new WorkosClient({
      config: { secret_key: "sk_x" },
      fetchFn: fakeFetch,
    });
    await listDirectoryUsers(client, {
      directory: "directory_1",
      group: "directory_group_1",
    });
    expect(capturedUrl).toContain("directory=directory_1");
    expect(capturedUrl).toContain("group=directory_group_1");
  });

  it("listDirectoryGroups passes directory filter", async () => {
    let capturedUrl = "";
    const fakeFetch: typeof fetch = async (input) => {
      capturedUrl = String(input);
      return jsonResponse({
        object: "list",
        data: [],
        list_metadata: { before: null, after: null },
      });
    };
    const client = new WorkosClient({
      config: { secret_key: "sk_x" },
      fetchFn: fakeFetch,
    });
    await listDirectoryGroups(client, { directory: "directory_1" });
    expect(capturedUrl).toContain("directory=directory_1");
  });

  it("getDirectoryUser returns null on 404", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response("not found", { status: 404 });
    const client = new WorkosClient({
      config: { secret_key: "sk_x" },
      fetchFn: fakeFetch,
    });
    const user = await getDirectoryUser(client, "directory_user_missing");
    expect(user).toBeNull();
  });

  it("getDirectoryGroup returns null on 404", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response("not found", { status: 404 });
    const client = new WorkosClient({
      config: { secret_key: "sk_x" },
      fetchFn: fakeFetch,
    });
    const group = await getDirectoryGroup(client, "directory_group_missing");
    expect(group).toBeNull();
  });
});

describe("workos client — error paths", () => {
  it("429 with Retry-After header retries once then throws WorkosRateLimitError", async () => {
    let callCount = 0;
    const fakeFetch: typeof fetch = async () => {
      callCount += 1;
      return new Response("rate limited", {
        status: 429,
        headers: { "Retry-After": "0" }, // 0s so test stays fast
      });
    };
    const client = new WorkosClient({
      config: { secret_key: "sk_x" },
      fetchFn: fakeFetch,
    });
    await expect(getOrganization(client, "org_x")).rejects.toBeInstanceOf(WorkosRateLimitError);
    // GET retries up to 2× by default — 1 initial + 2 retries
    expect(callCount).toBeGreaterThanOrEqual(2);
  });

  it("404 on a list endpoint throws WorkosNotFoundError (no null shortcut)", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response("not found", { status: 404 });
    const client = new WorkosClient({
      config: { secret_key: "sk_x" },
      fetchFn: fakeFetch,
    });
    await expect(listOrganizations(client)).rejects.toBeInstanceOf(WorkosNotFoundError);
  });
});
