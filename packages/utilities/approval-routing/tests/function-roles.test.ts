// §6.3 schema validation — accept the spec sample shape, reject every
// violation with a TYPED error (callers branch on code; CLI maps to exit 3).

import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";

import {
  findFunction,
  loadFunctionRoles,
  validateFunctionRoles,
} from "../src/function-roles.js";
import { parseYaml } from "../src/yaml-lite.js";
import { RoutingConfigError } from "../src/types.js";
import { readFixture } from "./test-helpers.js";

function docFromFixture(): Record<string, unknown> {
  return parseYaml(readFixture("function-roles.valid.yaml")) as Record<string, unknown>;
}

function expectInvalid(doc: unknown, messagePart: string): void {
  try {
    validateFunctionRoles(doc as Parameters<typeof validateFunctionRoles>[0]);
    expect.unreachable("expected RoutingConfigError");
  } catch (err) {
    expect(err).toBeInstanceOf(RoutingConfigError);
    expect((err as RoutingConfigError).code).toBe("function_roles_invalid");
    expect((err as RoutingConfigError).message).toContain(messagePart);
  }
}

describe("validateFunctionRoles — accept", () => {
  it("accepts the §6.3 sample shape (schema_version 1, all six functions)", () => {
    const map = validateFunctionRoles(docFromFixture());
    expect(map.schema_version).toBe(1);
    expect(map.tenant_id).toBe("fixture-tenant-uuid");
    expect(map.firm_default_approver).toEqual({
      person_ref: "aad-jane-founder",
      display_name: "Jane Founder",
    });
    expect(map.functions.map((f) => f.function)).toEqual([
      "finance",
      "ops_data",
      "business_development",
      "candidate_comms_default",
      "client_comms_default",
      "admin",
    ]);
    expect(findFunction(map, "finance")?.holder.source).toBe("graph_inferred");
    expect(findFunction(map, "finance")?.ttl_minutes).toBeNull();
    expect(findFunction(map, "ops_data")?.ttl_minutes).toBe(1440);
    expect(findFunction(map, "business_development")?.breaks_quiet_hours).toBe(true);
    expect(findFunction(map, "candidate_comms_default")?.escalation).toEqual([]);
    expect(findFunction(map, "no_such_function")).toBeNull();
    expect(map.confirmed_at).toBe("2026-06-10T00:00:00Z");
    expect(map.confirmed_by).toBe("aad-jane-founder");
  });

  it("accepts a boutique-collapse map (every holder = the founder) with fewer functions", () => {
    const doc = docFromFixture();
    const functions = (doc["functions"] as Record<string, unknown>[]).slice(0, 2);
    for (const f of functions) {
      (f["holder"] as Record<string, unknown>)["person_ref"] = "aad-jane-founder";
    }
    doc["functions"] = functions;
    const map = validateFunctionRoles(doc);
    expect(map.functions).toHaveLength(2);
  });
});

describe("validateFunctionRoles — reject (typed)", () => {
  it("rejects unknown schema_version", () => {
    const doc = docFromFixture();
    doc["schema_version"] = 2;
    expectInvalid(doc, "schema_version");
  });

  it("rejects missing schema_version", () => {
    const doc = docFromFixture();
    delete doc["schema_version"];
    expectInvalid(doc, "schema_version");
  });

  it("rejects missing firm_default_approver (REQUIRED — ladder step 3)", () => {
    const doc = docFromFixture();
    delete doc["firm_default_approver"];
    expectInvalid(doc, "firm_default_approver");
  });

  it("rejects firm_default_approver without person_ref", () => {
    const doc = docFromFixture();
    doc["firm_default_approver"] = { display_name: "Jane Founder" };
    expectInvalid(doc, "person_ref");
  });

  it("rejects an unknown function name", () => {
    const doc = docFromFixture();
    (doc["functions"] as Record<string, unknown>[])[0]["function"] = "payroll";
    expectInvalid(doc, '"payroll"');
  });

  it("rejects an invalid holder.source", () => {
    const doc = docFromFixture();
    const holder = (doc["functions"] as Record<string, unknown>[])[0]["holder"] as Record<
      string,
      unknown
    >;
    holder["source"] = "guessed";
    expectInvalid(doc, "holder.source");
  });

  it("rejects duplicate function entries", () => {
    const doc = docFromFixture();
    const functions = doc["functions"] as Record<string, unknown>[];
    doc["functions"] = [...functions, functions[0]];
    expectInvalid(doc, "duplicate function");
  });

  it("rejects a non-integer ttl_minutes", () => {
    const doc = docFromFixture();
    (doc["functions"] as Record<string, unknown>[])[1]["ttl_minutes"] = "soon";
    expectInvalid(doc, "ttl_minutes");
  });

  it("rejects a missing breaks_quiet_hours", () => {
    const doc = docFromFixture();
    delete (doc["functions"] as Record<string, unknown>[])[0]["breaks_quiet_hours"];
    expectInvalid(doc, "breaks_quiet_hours");
  });
});

describe("loadFunctionRoles — filesystem", () => {
  let vaultRoot: string;

  beforeEach(() => {
    vaultRoot = mkdtempSync(join(tmpdir(), "ifos-routing-test-"));
  });
  afterEach(() => {
    rmSync(vaultRoot, { recursive: true, force: true });
  });

  it("loads a valid vault file from /vault/{tenant}/routing/function-roles.yaml", () => {
    mkdirSync(join(vaultRoot, "t1", "routing"), { recursive: true });
    writeFileSync(
      join(vaultRoot, "t1", "routing", "function-roles.yaml"),
      readFixture("function-roles.valid.yaml"),
    );
    const map = loadFunctionRoles(vaultRoot, "t1");
    expect(map.functions).toHaveLength(6);
  });

  it("throws function_roles_missing (typed) when the file is absent", () => {
    try {
      loadFunctionRoles(vaultRoot, "t1");
      expect.unreachable("expected RoutingConfigError");
    } catch (err) {
      expect(err).toBeInstanceOf(RoutingConfigError);
      expect((err as RoutingConfigError).code).toBe("function_roles_missing");
    }
  });

  it("throws function_roles_invalid (typed) on unparseable YAML", () => {
    mkdirSync(join(vaultRoot, "t1", "routing"), { recursive: true });
    writeFileSync(
      join(vaultRoot, "t1", "routing", "function-roles.yaml"),
      "functions: &anchor\n",
    );
    try {
      loadFunctionRoles(vaultRoot, "t1");
      expect.unreachable("expected RoutingConfigError");
    } catch (err) {
      expect(err).toBeInstanceOf(RoutingConfigError);
      expect((err as RoutingConfigError).code).toBe("function_roles_invalid");
    }
  });
});
