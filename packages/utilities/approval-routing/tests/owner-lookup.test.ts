// Owner lookup — SQL shape + RLS scoping against a fake RunPsql (zero live
// DB in W1; DB-backed fixture suites arrive in W3).

import { describe, expect, it } from "vitest";

import {
  createPostgresOwnerLookup,
  OWNER_FIELD_BY_ENTITY_TYPE,
  OWNER_LOOKUP_SQL,
  type RunPsql,
} from "../src/owner-lookup.js";

function makeRunPsql(stdout: string): RunPsql & { calls: { args: string[]; sql: string }[] } {
  const calls: { args: string[]; sql: string }[] = [];
  const fn = (async (args: string[], sql: string) => {
    calls.push({ args, sql });
    return stdout;
  }) as RunPsql & { calls: { args: string[]; sql: string }[] };
  fn.calls = calls;
  return fn;
}

describe("createPostgresOwnerLookup", () => {
  it("requires db_url", () => {
    expect(() => createPostgresOwnerLookup({ db_url: "" })).toThrow(/db_url/);
  });

  it("queries candidate owner via data->>'owner_user_id' with RLS SET LOCAL", async () => {
    const runPsql = makeRunPsql("101\n");
    const lookup = createPostgresOwnerLookup({ db_url: "postgres://x", runPsql });
    const result = await lookup("tenant-a", { entity_type: "candidate", entity_id: "CAND-1" });
    expect(result).toEqual({ owner_bullhorn_user_id: "101" });

    expect(runPsql.calls).toHaveLength(1);
    const { args, sql } = runPsql.calls[0];
    // RLS scoping by construction.
    expect(sql).toContain("SET LOCAL app.current_tenant = :'tenant'");
    expect(sql).toBe(OWNER_LOOKUP_SQL);
    // Caller input travels as psql -v variables only (no SQL interpolation).
    expect(args).toContain("tenant=tenant-a");
    expect(args).toContain("etype=candidate");
    expect(args).toContain("eid=CAND-1");
    expect(args).toContain("ofield=owner_user_id");
    expect(args).toContain("ON_ERROR_STOP=1");
    expect(args[0]).toBe("postgres://x");
  });

  it("queries client owner via the verified account_owner_user_id field", async () => {
    const runPsql = makeRunPsql("202\n");
    const lookup = createPostgresOwnerLookup({ db_url: "postgres://x", runPsql });
    const result = await lookup("tenant-a", { entity_type: "client", entity_id: "CLI-9" });
    expect(result).toEqual({ owner_bullhorn_user_id: "202" });
    expect(runPsql.calls[0].args).toContain("ofield=account_owner_user_id");
  });

  it("returns null WITHOUT querying for entity types with no schema-defined owner field", async () => {
    const runPsql = makeRunPsql("999\n");
    const lookup = createPostgresOwnerLookup({ db_url: "postgres://x", runPsql });
    // brief (JobOrder) + placement carry no owner field in vertical-schema v0.x.
    expect(await lookup("tenant-a", { entity_type: "brief", entity_id: "B-1" })).toBeNull();
    expect(await lookup("tenant-a", { entity_type: "placement", entity_id: "P-1" })).toBeNull();
    expect(runPsql.calls).toHaveLength(0);
  });

  it("returns null when the row is absent or the owner field is empty (never invents)", async () => {
    const lookupEmpty = createPostgresOwnerLookup({
      db_url: "postgres://x",
      runPsql: makeRunPsql("\n"),
    });
    expect(
      await lookupEmpty("tenant-a", { entity_type: "candidate", entity_id: "CAND-NOOWNER" }),
    ).toBeNull();

    const lookupNoRows = createPostgresOwnerLookup({
      db_url: "postgres://x",
      runPsql: makeRunPsql(""),
    });
    expect(
      await lookupNoRows("tenant-a", { entity_type: "candidate", entity_id: "CAND-GONE" }),
    ).toBeNull();
  });

  it("propagates psql failures (real error — caller falls back)", async () => {
    const failing: RunPsql = async () => {
      throw new Error("psql failed: connection refused");
    };
    const lookup = createPostgresOwnerLookup({ db_url: "postgres://x", runPsql: failing });
    await expect(
      lookup("tenant-a", { entity_type: "candidate", entity_id: "C1" }),
    ).rejects.toThrow(/psql failed/);
  });

  it("documents the verified mapping table (candidate/contractor/client only)", () => {
    expect(OWNER_FIELD_BY_ENTITY_TYPE).toEqual({
      candidate: "owner_user_id",
      contractor: "owner_user_id",
      client: "account_owner_user_id",
    });
  });
});
