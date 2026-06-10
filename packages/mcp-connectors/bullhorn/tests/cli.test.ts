// CLI bridge tests — every new/changed command path per the agreed CLI
// contract (review-scribe.md orchestrator ruling): refresh token_state
// fresh|refreshed, update-entity (generic 4-type surface), create-note
// extended targeting (--person-id | --entity-type/--entity-id, --body-file,
// --title, unsupported_entity refusal). Happy + failure per path; fetchFn
// injected — ZERO live API calls.

import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";

import { CliFailure, runCommand } from "../src/cli.js";
import {
  _resetInflightForTest,
  BULLHORN_REST_LOGIN_URL,
  BullhornValidationError,
  resetRateLimit,
  saveTokens,
} from "../src/index.js";
import type { BullhornOAuthConfig, BullhornTokens } from "../src/index.js";

const CORP = "cli-test-corp";
const FIXTURE_REST_URL = "https://rest9.bullhornstaffing.com/rest-services/fixtureCorp/";

const ENV_KEYS = [
  "BULLHORN_CLIENT_ID",
  "BULLHORN_CLIENT_SECRET",
  "BULLHORN_CORPORATION_ID",
  "BULLHORN_SANDBOX_CORPORATION_ID",
  "BULLHORN_REGION",
  "BULLHORN_SANDBOX_REGION",
  "IFOS_TOKEN_DIR",
] as const;

let savedEnv: Record<string, string | undefined>;
let token_dir: string;

function makeConfig(): BullhornOAuthConfig {
  return {
    client_id: "fake-client-id",
    client_secret: "fake-client-secret",
    corporation_id: CORP,
    region: "east",
    token_file_path: join(token_dir, `bullhorn-tokens-${CORP}.json`),
  };
}

function freshTokens(expiry_ms = Date.now() + 600_000): BullhornTokens {
  return {
    oauth_access_token: "fixture-oauth-access",
    oauth_refresh_token: "fixture-oauth-refresh",
    oauth_expires_at_ms: expiry_ms,
    scope: "all",
    token_type: "Bearer",
    bh_rest_token: "fixture-bhrest",
    rest_url: FIXTURE_REST_URL,
    bh_rest_token_expires_at_ms: expiry_ms,
  };
}

function makeOkResponse(body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

/** fetch stub that fails the test if any network call happens. */
const noFetch: typeof fetch = async () => {
  throw new Error("unexpected network call");
};

beforeEach(async () => {
  savedEnv = {};
  for (const k of ENV_KEYS) savedEnv[k] = process.env[k];
  token_dir = join(
    tmpdir(),
    `bullhorn-cli-test-${process.pid}-${Date.now()}-${Math.random()}`,
  );
  await fs.mkdir(token_dir, { recursive: true });
  process.env.BULLHORN_CLIENT_ID = "fake-client-id";
  process.env.BULLHORN_CLIENT_SECRET = "fake-client-secret";
  process.env.BULLHORN_CORPORATION_ID = CORP;
  process.env.BULLHORN_REGION = "east";
  process.env.IFOS_TOKEN_DIR = token_dir;
  delete process.env.BULLHORN_SANDBOX_CORPORATION_ID;
  delete process.env.BULLHORN_SANDBOX_REGION;
  _resetInflightForTest();
  resetRateLimit();
});

afterEach(async () => {
  for (const k of ENV_KEYS) {
    if (savedEnv[k] === undefined) delete process.env[k];
    else process.env[k] = savedEnv[k];
  }
  await fs.rm(token_dir, { recursive: true, force: true }).catch(() => undefined);
});

describe("cli refresh — token_state per the agreed contract", () => {
  it("fresh: tokens outside the safety window → no rotation, token_state:'fresh'", async () => {
    const tokens = freshTokens(Date.now() + 600_000);
    await saveTokens(makeConfig(), tokens);
    const out = await runCommand(["refresh"], noFetch); // noFetch proves zero network
    expect(out.ok).toBe(true);
    expect(out.token_state).toBe("fresh");
    expect(out.oauth_expires_at_ms).toBe(tokens.oauth_expires_at_ms);
  });

  it("refreshed: tokens inside the safety window → Step A + Step B rotation, token_state:'refreshed'", async () => {
    await saveTokens(makeConfig(), freshTokens(Date.now() + 10_000)); // < 90s window
    let oauthCalls = 0;
    let loginCalls = 0;
    const fakeFetch: typeof fetch = async (input) => {
      const url = typeof input === "string" ? input : (input as URL).toString();
      if (url.startsWith("https://auth-east.bullhornstaffing.com")) {
        oauthCalls += 1;
        return makeOkResponse({
          access_token: "rotated-oauth",
          refresh_token: "rotated-refresh",
          expires_in: 600,
          scope: "all",
          token_type: "Bearer",
        });
      }
      if (url.startsWith(BULLHORN_REST_LOGIN_URL)) {
        loginCalls += 1;
        return makeOkResponse({ BhRestToken: "rotated-bhrest", restUrl: FIXTURE_REST_URL });
      }
      throw new Error(`unexpected fetch: ${url}`);
    };
    const out = await runCommand(["refresh"], fakeFetch);
    expect(out.ok).toBe(true);
    expect(out.token_state).toBe("refreshed");
    expect(typeof out.oauth_expires_at_ms).toBe("number");
    expect(out.oauth_expires_at_ms as number).toBeGreaterThan(Date.now());
    expect(oauthCalls).toBe(1);
    expect(loginCalls).toBe(1);
  });

  it("failure: no token bundle on disk → CliFailure naming the consent bootstrap", async () => {
    await expect(runCommand(["refresh"], noFetch)).rejects.toThrowError(
      /no token bundle/,
    );
  });
});

describe("cli update-entity — generic 4-type surface (NEW per contract)", () => {
  it.each(["Candidate", "ClientContact", "JobOrder", "Placement"] as const)(
    "happy: POSTs patch to /entity/%s/<id> and returns {ok, updated, entity_type, id}",
    async (entityType) => {
      await saveTokens(makeConfig(), freshTokens());
      let observedUrl = "";
      let observedMethod = "";
      let observedBody = "";
      const fakeFetch: typeof fetch = async (input, init) => {
        observedUrl = String(input);
        observedMethod = init?.method ?? "";
        observedBody = init?.body as string;
        return makeOkResponse({
          changedEntityType: entityType,
          changedEntityId: 4242,
          changeType: "UPDATE",
        });
      };
      const out = await runCommand(
        ["update-entity", "--entity-type", entityType, "--id", "4242", "--patch", '{"status":"Active"}'],
        fakeFetch,
      );
      expect(out).toEqual({ ok: true, updated: true, entity_type: entityType, id: 4242 });
      expect(observedUrl).toContain(`/entity/${entityType}/4242`);
      expect(observedMethod).toBe("POST");
      expect(JSON.parse(observedBody).status).toBe("Active");
    },
  );

  it("failure: disallowed --entity-type → CliFailure, no network", async () => {
    await saveTokens(makeConfig(), freshTokens());
    await expect(
      runCommand(
        ["update-entity", "--entity-type", "ClientCorporation", "--id", "1", "--patch", "{}"],
        noFetch,
      ),
    ).rejects.toThrowError(/entity-type must be one of/);
  });

  it("failure: non-numeric --id → CliFailure, no network", async () => {
    await saveTokens(makeConfig(), freshTokens());
    await expect(
      runCommand(
        ["update-entity", "--entity-type", "Candidate", "--id", "abc", "--patch", "{}"],
        noFetch,
      ),
    ).rejects.toThrowError(/positive numeric bullhorn id/);
  });

  it("failure: malformed --patch → CliFailure, no network", async () => {
    await saveTokens(makeConfig(), freshTokens());
    await expect(
      runCommand(
        ["update-entity", "--entity-type", "Candidate", "--id", "5", "--patch", "{not json"],
        noFetch,
      ),
    ).rejects.toThrowError(/--patch <json object>/);
  });

  it("failure: upstream 400 surfaces as BullhornValidationError with NO write retry", async () => {
    await saveTokens(makeConfig(), freshTokens());
    let calls = 0;
    const fakeFetch: typeof fetch = async () => {
      calls += 1;
      return new Response("bad field", { status: 400 });
    };
    await expect(
      runCommand(
        ["update-entity", "--entity-type", "Placement", "--id", "9", "--patch", '{"x":1}'],
        fakeFetch,
      ),
    ).rejects.toBeInstanceOf(BullhornValidationError);
    expect(calls).toBe(1);
  });
});

describe("cli create-note — extended targeting + body sources (per contract)", () => {
  function noteFetch(observe: (body: string) => void): typeof fetch {
    return async (_input, init) => {
      observe(init?.body as string);
      return makeOkResponse({
        changedEntityType: "Note",
        changedEntityId: 9001,
        changeType: "INSERT",
      });
    };
  }

  it("happy: legacy --person-id + --comments still works → {ok, note_id}", async () => {
    await saveTokens(makeConfig(), freshTokens());
    let body = "";
    const out = await runCommand(
      ["create-note", "--person-id", "12345", "--comments", "post-call summary"],
      noteFetch((b) => (body = b)),
    );
    expect(out).toEqual({ ok: true, note_id: 9001 });
    const parsed = JSON.parse(body);
    expect(parsed.personReference.id).toBe(12345);
    expect(parsed.comments).toBe("post-call summary");
    expect(parsed.action).toBe("Note");
  });

  it("happy: --entity-type Candidate --entity-id targets the person reference", async () => {
    await saveTokens(makeConfig(), freshTokens());
    let body = "";
    const out = await runCommand(
      ["create-note", "--entity-type", "Candidate", "--entity-id", "777", "--comments", "note body"],
      noteFetch((b) => (body = b)),
    );
    expect(out.ok).toBe(true);
    expect(out.note_id).toBe(9001);
    expect(JSON.parse(body).personReference.id).toBe(777);
  });

  it("happy: --body-file reads the full body; --title prepends as first line", async () => {
    await saveTokens(makeConfig(), freshTokens());
    const bodyFile = join(token_dir, "note-body.md");
    const longBody = `call notes line 1\n${"x".repeat(1200)}\ntail line`;
    await fs.writeFile(bodyFile, longBody, "utf8");
    let body = "";
    const out = await runCommand(
      [
        "create-note",
        "--entity-type", "ClientContact",
        "--entity-id", "321",
        "--body-file", bodyFile,
        "--title", "Call with Acme",
      ],
      noteFetch((b) => (body = b)),
    );
    expect(out).toEqual({ ok: true, note_id: 9001 });
    const parsed = JSON.parse(body);
    expect(parsed.personReference.id).toBe(321);
    expect(parsed.comments).toBe(`Call with Acme\n\n${longBody}`); // FULL body, not a truncation
  });

  it("refusal: unsupported --entity-type → structured {ok:false, reason:'unsupported_entity'}, no network, never faked", async () => {
    await saveTokens(makeConfig(), freshTokens());
    let caught: unknown;
    try {
      await runCommand(
        ["create-note", "--entity-type", "JobOrder", "--entity-id", "55", "--comments", "x"],
        noFetch,
      );
    } catch (e) {
      caught = e;
    }
    expect(caught).toBeInstanceOf(CliFailure);
    const payload = (caught as CliFailure).payload;
    expect(payload.ok).toBe(false);
    expect(payload.reason).toBe("unsupported_entity");
    expect(payload.entity_type).toBe("JobOrder");
  });

  it("failure: no target flags at all → CliFailure naming both targeting forms", async () => {
    await saveTokens(makeConfig(), freshTokens());
    await expect(
      runCommand(["create-note", "--comments", "x"], noFetch),
    ).rejects.toThrowError(/--person-id <N> OR \(--entity-type <T> --entity-id <N>\)/);
  });

  it("failure: unreadable --body-file → CliFailure, no network", async () => {
    await saveTokens(makeConfig(), freshTokens());
    await expect(
      runCommand(
        ["create-note", "--person-id", "1", "--body-file", join(token_dir, "missing.md")],
        noFetch,
      ),
    ).rejects.toThrowError(/cannot read/);
  });

  it("failure: empty body (no --comments, no --body-file) → CliFailure", async () => {
    await saveTokens(makeConfig(), freshTokens());
    await expect(
      runCommand(["create-note", "--person-id", "1"], noFetch),
    ).rejects.toThrowError(/non-empty --comments/);
  });
});

describe("cli regression — existing command paths unchanged", () => {
  it("update-candidate still returns {ok, changed_entity_id}", async () => {
    await saveTokens(makeConfig(), freshTokens());
    const fakeFetch: typeof fetch = async (input) => {
      expect(String(input)).toContain("/entity/Candidate/123");
      return makeOkResponse({
        changedEntityType: "Candidate",
        changedEntityId: 123,
        changeType: "UPDATE",
      });
    };
    const out = await runCommand(
      ["update-candidate", "--id", "123", "--patch", '{"customText1":"ifos:merged_from:456"}'],
      fakeFetch,
    );
    expect(out).toEqual({ ok: true, changed_entity_id: 123 });
  });

  it("check-auth stays network-free and reports creds + tokens presence", async () => {
    await saveTokens(makeConfig(), freshTokens());
    const out = await runCommand(["check-auth"], noFetch);
    expect(out).toEqual({
      ok: true,
      creds_present: true,
      tokens_present: true,
      corporation_id: CORP,
      region: "east",
    });
  });

  it("unknown command → CliFailure listing the full surface incl. update-entity", async () => {
    await expect(runCommand(["frobnicate"], noFetch)).rejects.toThrowError(
      /update-entity \| create-note/,
    );
  });
});
