// Capabilities tests — exercise each capability against fake fetch, covering
// happy paths + 401 (no-retry) + 404 (returns null on get*) + dual-auth-mode
// header format verification.

import { beforeEach, describe, expect, it } from "vitest";

import {
  CVLibraryAuthError,
  CVLibraryClient,
  CVLibraryRateLimitError,
  getCandidate,
  resetRateLimit,
  searchCandidates,
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

describe("cv-library capabilities — auth header format", () => {
  it("Basic auth mode uses api_key as username (mirrors Reed pattern)", async () => {
    let capturedAuth = "";
    const fakeFetch: typeof fetch = async (input, init) => {
      capturedAuth = String(
        (init?.headers as Record<string, string> | undefined)?.Authorization ?? "",
      );
      expect(String(input)).toContain("api.cv-library.co.uk");
      return jsonResponse({ total: 0, results: [] });
    };
    const client = new CVLibraryClient({
      config: { account_id: "acct-x", auth_mode: "basic", api_key: "xyz789" },
      fetchFn: fakeFetch,
    });
    await searchCandidates(client, { keywords: "react" });
    // Basic auth: Authorization: Basic base64(api_key:)
    expect(capturedAuth).toBe(`Basic ${Buffer.from("xyz789:", "utf8").toString("base64")}`);
  });

  it("Bearer auth mode uses access_token", async () => {
    let capturedAuth = "";
    const fakeFetch: typeof fetch = async (input, init) => {
      capturedAuth = String(
        (init?.headers as Record<string, string> | undefined)?.Authorization ?? "",
      );
      return jsonResponse({ total: 0, results: [] });
    };
    const client = new CVLibraryClient({
      config: { account_id: "acct-x", auth_mode: "bearer", access_token: "bearer-token-abc" },
      fetchFn: fakeFetch,
    });
    await searchCandidates(client, {});
    expect(capturedAuth).toBe("Bearer bearer-token-abc");
  });
});

describe("cv-library capabilities — searchCandidates", () => {
  it("happy path returns candidate list with pagination params", async () => {
    let capturedUrl = "";
    const fakeFetch: typeof fetch = async (input) => {
      capturedUrl = String(input);
      return jsonResponse({
        total: 1,
        results: [
          {
            candidate_id: "cv-001",
            full_name: "Jane Doe",
            email: "jane.doe@example.test",
            phone: "+447700900001",
            location: "London",
            current_title: "Senior Engineer",
            years_experience: 8,
            salary_expectation: 90000,
            cv_url: "https://cv-library.co.uk/cv/cv-001",
            last_active: "2026-06-01T10:00:00Z",
          },
        ],
      });
    };
    const client = new CVLibraryClient({
      config: { account_id: "acct-x", auth_mode: "basic", api_key: "test" },
      fetchFn: fakeFetch,
    });
    const res = await searchCandidates(client, {
      keywords: "react",
      location: "London",
      salary_min: 80000,
      limit: 50,
      offset: 100,
    });
    expect(res.total).toBe(1);
    expect(res.results[0]?.full_name).toBe("Jane Doe");
    expect(capturedUrl).toContain("keywords=react");
    expect(capturedUrl).toContain("location=London");
    expect(capturedUrl).toContain("limit=50");
    expect(capturedUrl).toContain("offset=100");
  });
});

describe("cv-library capabilities — getCandidate", () => {
  it("returns null on 404 (does not throw)", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response("not found", { status: 404 });
    const client = new CVLibraryClient({
      config: { account_id: "acct-x", auth_mode: "basic", api_key: "test" },
      fetchFn: fakeFetch,
    });
    const c = await getCandidate(client, "cv-missing");
    expect(c).toBeNull();
  });

  it("surfaces 401 immediately as CVLibraryAuthError without retry", async () => {
    let callCount = 0;
    const fakeFetch: typeof fetch = async () => {
      callCount += 1;
      return new Response("unauthorised", { status: 401 });
    };
    const client = new CVLibraryClient({
      config: { account_id: "acct-x", auth_mode: "basic", api_key: "dead" },
      fetchFn: fakeFetch,
    });
    await expect(getCandidate(client, "cv-001")).rejects.toBeInstanceOf(CVLibraryAuthError);
    expect(callCount).toBe(1);
  });
});

describe("cv-library client — error paths", () => {
  it("429 with Retry-After header retries then throws CVLibraryRateLimitError", async () => {
    let callCount = 0;
    const fakeFetch: typeof fetch = async () => {
      callCount += 1;
      return new Response("rate limited", {
        status: 429,
        headers: { "Retry-After": "0" },
      });
    };
    const client = new CVLibraryClient({
      config: { account_id: "acct-x", auth_mode: "basic", api_key: "test" },
      fetchFn: fakeFetch,
    });
    await expect(getCandidate(client, "cv-001")).rejects.toBeInstanceOf(CVLibraryRateLimitError);
    expect(callCount).toBeGreaterThanOrEqual(2);
  });
});
