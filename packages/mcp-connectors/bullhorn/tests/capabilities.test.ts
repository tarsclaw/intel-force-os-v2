// Capability tests per review-mcp-connector §6 (fixture-first; ≥1 happy
// path + ≥1 error path per capability). Bullhorn-specific: client
// requires a valid session (BhRestToken + restUrl) — tests preload via
// saveTokens before invoking the client.

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";

import {
  _resetInflightForTest,
  BULLHORN_REST_LOGIN_URL,
  BullhornAuthError,
  BullhornCache,
  BullhornClient,
  BullhornError,
  BullhornNotFoundError,
  BullhornRateLimitError,
  BullhornValidationError,
  createActivityLogEntry,
  createNote,
  getCandidate,
  getClient,
  getContact,
  getPlacement,
  listCandidates,
  listPlacements,
  resetRateLimit,
  saveTokens,
} from "../src/index.js";
import type { BullhornOAuthConfig, BullhornTokens } from "../src/index.js";

const FIXTURE_REST_URL = "https://rest9.bullhornstaffing.com/rest-services/fixtureCorp/";

const FIXTURE_TOKENS: BullhornTokens = {
  oauth_access_token: "fixture-oauth-access",
  oauth_refresh_token: "fixture-oauth-refresh",
  oauth_expires_at_ms: Date.now() + 600_000,
  scope: "all",
  token_type: "Bearer",
  bh_rest_token: "fixture-bhrest",
  rest_url: FIXTURE_REST_URL,
  bh_rest_token_expires_at_ms: Date.now() + 600_000,
};

let token_file: string;
let cache_dir: string;
let cache: BullhornCache;

function makeConfig(): BullhornOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    corporation_id: "fixture-corp-caps",
    region: "east",
    token_file_path: token_file,
  };
}

function makeOkResponse(body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

beforeEach(async () => {
  token_file = join(tmpdir(), `bullhorn-cap-tokens-${process.pid}-${Date.now()}-${Math.random()}.json`);
  cache_dir = join(tmpdir(), `bullhorn-cap-cache-${process.pid}-${Date.now()}-${Math.random()}`);
  cache = new BullhornCache(cache_dir);
  _resetInflightForTest();
  resetRateLimit();
  await saveTokens(makeConfig(), FIXTURE_TOKENS);
});

afterEach(async () => {
  await fs.unlink(token_file).catch(() => undefined);
  await fs.rm(cache_dir, { recursive: true, force: true }).catch(() => undefined);
});

describe("bullhorn capabilities — candidates", () => {
  it("getCandidate: happy path returns single candidate from /entity/Candidate/<id>", async () => {
    const fakeFetch: typeof fetch = async () =>
      makeOkResponse({
        data: {
          id: 12345,
          firstName: "Alice",
          lastName: "Walker",
          email: "alice@example.com",
          status: "Active",
          dateAdded: 1700000000000,
          dateLastModified: 1700000060000,
        },
      });
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    const cand = await getCandidate(client, 12345, { cache, no_cache: true });
    expect(cand).not.toBeNull();
    expect(cand?.id).toBe(12345);
    expect(cand?.firstName).toBe("Alice");
  });

  it("getCandidate: returns null on 404 (not raise)", async () => {
    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    const cand = await getCandidate(client, 99999, { cache, no_cache: true });
    expect(cand).toBeNull();
  });

  it("listCandidates: persistent 429 surfaces as BullhornRateLimitError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("", { status: 429, headers: { "Retry-After": "0" } });
    };
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      listCandidates(client, { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(BullhornRateLimitError);
    expect(calls).toBeGreaterThanOrEqual(2);
  });
});

describe("bullhorn capabilities — placements + client + contact", () => {
  it("getPlacement: happy path", async () => {
    const fakeFetch: typeof fetch = async () =>
      makeOkResponse({
        data: {
          id: 555,
          candidate: { id: 12345 },
          clientCorporation: { id: 7777 },
          jobOrder: { id: 888 },
          status: "Confirmed",
          dateBegin: 1700000000000,
          dateEnd: null,
          payRate: 50,
          billRate: 80,
          dateLastModified: 1700000060000,
        },
      });
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    const p = await getPlacement(client, 555, { cache, no_cache: true });
    expect(p?.id).toBe(555);
    expect(p?.status).toBe("Confirmed");
  });

  it("listPlacements: persistent 500 surfaces as BullhornError after retries", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("Bullhorn internal", { status: 500 });
    };
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      listPlacements(client, { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(BullhornError);
    expect(calls).toBeGreaterThanOrEqual(2);
  });

  it("getClient: happy path returns ClientCorporation", async () => {
    const fakeFetch: typeof fetch = async () =>
      makeOkResponse({
        data: {
          id: 7777,
          name: "Acme Tech Ltd",
          status: "Active",
          industry: "Technology",
          numEmployees: 250,
          website: "https://acme-tech.example",
          dateLastModified: 1700000060000,
        },
      });
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    const c = await getClient(client, 7777, { cache, no_cache: true });
    expect(c?.name).toBe("Acme Tech Ltd");
  });

  it("getContact: returns null on 404", async () => {
    const fakeFetch: typeof fetch = async () => new Response("", { status: 404 });
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    const c = await getContact(client, 99, { cache, no_cache: true });
    expect(c).toBeNull();
  });
});

describe("bullhorn capabilities — notes (writes; no retry)", () => {
  it("createNote: happy path returns changedEntityId", async () => {
    const fakeFetch: typeof fetch = async () =>
      makeOkResponse({
        changedEntityType: "Note",
        changedEntityId: 9001,
        changeType: "INSERT",
      });
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    const res = await createNote(client, {
      action: "Note",
      comments: "test",
      personReference: { id: 12345 },
    });
    expect(res.changedEntityId).toBe(9001);
    expect(res.changeType).toBe("INSERT");
  });

  it("createNote: 400 surfaces as BullhornValidationError (no retry on writes)", async () => {
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("invalid personReference", { status: 400 });
    };
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      createNote(client, {
        action: "Note",
        comments: "test",
        personReference: { id: 0 },
      }),
    ).rejects.toBeInstanceOf(BullhornValidationError);
    expect(calls).toBe(1); // write was NOT retried
  });

  it("createActivityLogEntry: wraps createNote with action='Activity'", async () => {
    let observedBody: string | undefined;
    const fakeFetch: typeof fetch = async (_input, init) => {
      observedBody = init?.body as string;
      return makeOkResponse({
        changedEntityType: "Note",
        changedEntityId: 9002,
        changeType: "INSERT",
      });
    };
    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    await createActivityLogEntry(client, 12345, "concierge: interview-completed sent");
    expect(observedBody).toBeDefined();
    const parsed = JSON.parse(observedBody!);
    expect(parsed.action).toBe("Activity");
    expect(parsed.personReference.id).toBe(12345);
  });
});

describe("bullhorn client — 401 forces full refresh (Step A + Step B) then retry", () => {
  // Per cluster F R4 lesson: 401 path MUST trigger explicit refreshTokens()
  // call before retrying, AND only ONCE per request lifecycle. The
  // didForceRefresh flag in client.ts enforces both invariants.
  it("401 on GET → forces refresh → retry uses new BhRestToken", async () => {
    let dataCalls = 0;
    let oauthCalls = 0;
    let loginCalls = 0;
    let observedRetryAuth: string | null = null;

    const fakeFetch: typeof fetch = async (input, init) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      // Step A: OAuth refresh
      if (url.startsWith("https://auth-east.bullhornstaffing.com")) {
        oauthCalls += 1;
        return new Response(
          JSON.stringify({
            access_token: "rotated-oauth",
            refresh_token: "rotated-refresh",
            expires_in: 600,
            scope: "all",
            token_type: "Bearer",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      // Step B: REST login
      if (url.startsWith(BULLHORN_REST_LOGIN_URL)) {
        loginCalls += 1;
        return new Response(
          JSON.stringify({
            BhRestToken: "rotated-bhrest-token",
            restUrl: FIXTURE_REST_URL,
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      // Data call: 401 first, success second
      dataCalls += 1;
      if (dataCalls === 1) {
        return new Response("", { status: 401 });
      }
      const headers = init?.headers as Record<string, string> | undefined;
      observedRetryAuth = headers?.["BhRestToken"] ?? null;
      return makeOkResponse({ data: { id: 100, firstName: "X", lastName: "Y", email: "x@y.z", status: "Active", dateAdded: 1, dateLastModified: 1 } });
    };

    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    const cand = await getCandidate(client, 100, { cache, no_cache: true });

    expect(cand).not.toBeNull();
    expect(dataCalls).toBe(2); // initial 401 + retry
    expect(oauthCalls).toBe(1); // Step A fired once
    expect(loginCalls).toBe(1); // Step B fired once
    expect(observedRetryAuth).toBe("rotated-bhrest-token"); // retry used the rotated token
  });

  it("401 after a forced refresh → throws BullhornAuthError without a second refresh", async () => {
    let oauthCalls = 0;
    let loginCalls = 0;
    let dataCalls = 0;

    const fakeFetch: typeof fetch = async (input) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      if (url.startsWith("https://auth-east.bullhornstaffing.com")) {
        oauthCalls += 1;
        return new Response(
          JSON.stringify({
            access_token: "still-bad",
            refresh_token: "still-bad-refresh",
            expires_in: 600,
            scope: "all",
            token_type: "Bearer",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      if (url.startsWith(BULLHORN_REST_LOGIN_URL)) {
        loginCalls += 1;
        return new Response(
          JSON.stringify({
            BhRestToken: "still-bad-bhrest",
            restUrl: FIXTURE_REST_URL,
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }
      // EVERY data GET returns 401 — simulates server-side consent revocation
      dataCalls += 1;
      return new Response("", { status: 401 });
    };

    const client = new BullhornClient({ config: makeConfig(), fetchFn: fakeFetch });
    await expect(
      getCandidate(client, 100, { cache, no_cache: true }),
    ).rejects.toBeInstanceOf(BullhornAuthError);
    // First 401 → forced refresh; second 401 (with rotated token) → throw.
    // NO second refresh attempt.
    expect(oauthCalls).toBe(1);
    expect(loginCalls).toBe(1);
    expect(dataCalls).toBe(2);
  });
});
