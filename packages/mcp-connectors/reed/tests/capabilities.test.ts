// Capabilities tests — exercise each capability against a fake fetch, covering
// happy paths + 401 (no-retry surface as ReedAuthError, NOT a refresh dance)
// + 404 (returns null on get*, throws on list*) + 429 retry-after honour +
// Basic auth header format verification.

import { beforeEach, describe, expect, it } from "vitest";

import {
  ReedAuthError,
  ReedClient,
  ReedNotFoundError,
  ReedRateLimitError,
  getCandidate,
  listJobs,
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

describe("reed capabilities — auth header format (Basic with API key as username)", () => {
  it("constructs HTTP Basic header with api_key:empty (per reed.co.uk/developers verified 2026-06-03)", async () => {
    let capturedAuth = "";
    const fakeFetch: typeof fetch = async (input, init) => {
      capturedAuth = String(
        (init?.headers as Record<string, string> | undefined)?.Authorization ?? "",
      );
      expect(String(input)).toContain("reed.co.uk/api/1.0");
      return jsonResponse({ total_results: 0, results: [] });
    };
    const client = new ReedClient({
      config: { api_key: "abc123", account_id: "acct-fake" },
      fetchFn: fakeFetch,
    });
    await searchCandidates(client, { keywords: "react" });
    // Basic auth format: Authorization: Basic base64(api_key:)
    // For api_key="abc123", base64("abc123:") = "YWJjMTIzOg=="
    expect(capturedAuth).toBe(`Basic ${Buffer.from("abc123:", "utf8").toString("base64")}`);
    expect(capturedAuth).toBe("Basic YWJjMTIzOg==");
  });
});

describe("reed capabilities — searchCandidates", () => {
  it("happy path returns candidate list with pagination params", async () => {
    let capturedUrl = "";
    const fakeFetch: typeof fetch = async (input) => {
      capturedUrl = String(input);
      return jsonResponse({
        total_results: 1,
        results: [
          {
            candidate_id: "reed-001",
            full_name: "Jane Doe",
            email: "jane.doe@example.test",
            phone: "+447700900001",
            location: "London",
            current_title: "Senior Engineer",
            years_experience: 8,
            salary_expectation_min: 80000,
            salary_expectation_max: 100000,
            cv_url: "https://reed.co.uk/cv/reed-001",
            last_active: "2026-06-01T10:00:00Z",
          },
        ],
      });
    };
    const client = new ReedClient({
      config: { api_key: "sk_test", account_id: "acct-fake" },
      fetchFn: fakeFetch,
    });
    const res = await searchCandidates(client, {
      keywords: "react typescript",
      location: "London",
      salary_min: 80000,
      results_to_take: 50,
    });
    expect(res.total_results).toBe(1);
    expect(res.results).toHaveLength(1);
    expect(res.results[0]?.full_name).toBe("Jane Doe");
    expect(capturedUrl).toContain("keywords=react+typescript");
    expect(capturedUrl).toContain("locationName=London");
    expect(capturedUrl).toContain("minimumSalary=80000");
    expect(capturedUrl).toContain("resultsToTake=50");
  });
});

describe("reed capabilities — getCandidate", () => {
  it("returns null on 404 (does not throw)", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response("not found", { status: 404 });
    const client = new ReedClient({
      config: { api_key: "sk_test", account_id: "acct-fake" },
      fetchFn: fakeFetch,
    });
    const c = await getCandidate(client, "reed-missing");
    expect(c).toBeNull();
  });

  it("surfaces 401 immediately as ReedAuthError without retry (no refresh path)", async () => {
    let callCount = 0;
    const fakeFetch: typeof fetch = async () => {
      callCount += 1;
      return new Response("unauthorised", { status: 401 });
    };
    const client = new ReedClient({
      config: { api_key: "sk_test_dead", account_id: "acct-fake" },
      fetchFn: fakeFetch,
    });
    await expect(getCandidate(client, "reed-001")).rejects.toBeInstanceOf(ReedAuthError);
    // Critically: NO retry attempts. One call, one failure, surfaced.
    expect(callCount).toBe(1);
  });
});

describe("reed capabilities — jobs", () => {
  it("listJobs passes active_only + pagination filters", async () => {
    let capturedUrl = "";
    const fakeFetch: typeof fetch = async (input) => {
      capturedUrl = String(input);
      return jsonResponse({ total_results: 0, results: [] });
    };
    const client = new ReedClient({
      config: { api_key: "sk_test", account_id: "acct-fake" },
      fetchFn: fakeFetch,
    });
    await listJobs(client, { active_only: true, results_to_take: 20 });
    expect(capturedUrl).toContain("activeOnly=true");
    expect(capturedUrl).toContain("resultsToTake=20");
  });

  it("throws ReedNotFoundError on 404 from list endpoint", async () => {
    const fakeFetch: typeof fetch = async () =>
      new Response("not found", { status: 404 });
    const client = new ReedClient({
      config: { api_key: "sk_test", account_id: "acct-fake" },
      fetchFn: fakeFetch,
    });
    await expect(listJobs(client)).rejects.toBeInstanceOf(ReedNotFoundError);
  });
});

describe("reed client — error paths", () => {
  it("429 with Retry-After header retries then throws ReedRateLimitError", async () => {
    let callCount = 0;
    const fakeFetch: typeof fetch = async () => {
      callCount += 1;
      return new Response("rate limited", {
        status: 429,
        headers: { "Retry-After": "0" },
      });
    };
    const client = new ReedClient({
      config: { api_key: "sk_test", account_id: "acct-fake" },
      fetchFn: fakeFetch,
    });
    await expect(getCandidate(client, "reed-001")).rejects.toBeInstanceOf(ReedRateLimitError);
    expect(callCount).toBeGreaterThanOrEqual(2);
  });
});
