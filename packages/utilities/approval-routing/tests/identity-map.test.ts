// Identity map — round-trip (save → load) + bidirectional lookup + typed
// rejection cases (spec §6.4, PLAN.md decision 8).

import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, beforeEach, describe, expect, it } from "vitest";

import {
  loadIdentityMap,
  saveIdentityMap,
  validateIdentityMap,
  emptyIdentityMap,
  identityMapPath,
} from "../src/identity-map.js";
import { parseYaml } from "../src/yaml-lite.js";
import { RoutingConfigError, type IdentityRow } from "../src/types.js";
import { fixtureIdentityMap, readFixture } from "./test-helpers.js";

describe("validateIdentityMap", () => {
  it("accepts the fixture and exposes bidirectional lookups", () => {
    const map = fixtureIdentityMap();
    expect(map.tenant_id).toBe("fixture-tenant-uuid");
    expect(map.rows).toHaveLength(2);

    // Bullhorn → identity (routing direction); number and string keys both work.
    expect(map.byBullhornUserId(101)?.display_name).toBe("Sarah Khan");
    expect(map.byBullhornUserId("101")?.m365_object_id).toBe("aad-sarah-khan");
    expect(map.byBullhornUserId(999)).toBeNull();

    // person_ref → identity (transport direction).
    expect(map.byPersonRef("aad-jane-founder")?.bullhorn_user_id).toBe(102);
    expect(map.byPersonRef("aad-jane-founder")?.telegram_user_id).toBeUndefined();
    expect(map.byPersonRef("aad-sarah-khan")?.telegram_user_id).toBe("7700101");
    expect(map.byPersonRef("aad-nobody")).toBeNull();
  });

  it("rejects duplicate bullhorn_user_id rows (typed)", () => {
    const doc = parseYaml(readFixture("identity-map.valid.yaml")) as Record<string, unknown>;
    const identities = doc["identities"] as Record<string, unknown>[];
    doc["identities"] = [...identities, { ...identities[0] }];
    try {
      validateIdentityMap(doc);
      expect.unreachable("expected RoutingConfigError");
    } catch (err) {
      expect(err).toBeInstanceOf(RoutingConfigError);
      expect((err as RoutingConfigError).code).toBe("identity_map_invalid");
    }
  });

  it("rejects unknown schema_version, bad bullhorn_user_id, missing fields", () => {
    const base = (): Record<string, unknown> =>
      parseYaml(readFixture("identity-map.valid.yaml")) as Record<string, unknown>;

    const v2 = base();
    v2["schema_version"] = 2;
    expect(() => validateIdentityMap(v2)).toThrow(RoutingConfigError);

    const badId = base();
    (badId["identities"] as Record<string, unknown>[])[0]["bullhorn_user_id"] = "abc";
    expect(() => validateIdentityMap(badId)).toThrow(RoutingConfigError);

    const noEmail = base();
    delete (noEmail["identities"] as Record<string, unknown>[])[0]["email"];
    expect(() => validateIdentityMap(noEmail)).toThrow(RoutingConfigError);
  });

  it("emptyIdentityMap resolves nothing (ladder falls through, no error)", () => {
    const map = emptyIdentityMap("t1");
    expect(map.byBullhornUserId(101)).toBeNull();
    expect(map.byPersonRef("aad-x")).toBeNull();
  });
});

describe("saveIdentityMap ↔ loadIdentityMap round-trip", () => {
  let vaultRoot: string;

  beforeEach(() => {
    vaultRoot = mkdtempSync(join(tmpdir(), "ifos-idmap-test-"));
  });
  afterEach(() => {
    rmSync(vaultRoot, { recursive: true, force: true });
  });

  it("writes routing/identity-map.yaml and loads back identical rows", () => {
    const rows: IdentityRow[] = [
      {
        bullhorn_user_id: 7,
        m365_object_id: "aad-7",
        email: "seven@firm.co.uk",
        display_name: "Seven — O'Seven", // exercises emitter quoting
        source: "manual",
        telegram_user_id: "777",
      },
      {
        bullhorn_user_id: 8,
        m365_object_id: "aad-8",
        email: "eight@firm.co.uk",
        display_name: "Eight",
        source: "graph_email_match",
      },
    ];
    const path = saveIdentityMap(vaultRoot, "t1", "tenant-uuid-1", rows);
    expect(path).toBe(identityMapPath(vaultRoot, "t1"));
    const map = loadIdentityMap(vaultRoot, "t1");
    expect(map.tenant_id).toBe("tenant-uuid-1");
    expect(map.rows).toEqual(rows);
  });

  it("throws identity_map_missing (typed) when the vault file is absent", () => {
    try {
      loadIdentityMap(vaultRoot, "t1");
      expect.unreachable("expected RoutingConfigError");
    } catch (err) {
      expect(err).toBeInstanceOf(RoutingConfigError);
      expect((err as RoutingConfigError).code).toBe("identity_map_missing");
    }
  });

  it("refuses to persist invalid rows (validate-before-write)", () => {
    const rows = [
      {
        bullhorn_user_id: -1,
        m365_object_id: "aad-x",
        email: "x@y.co",
        display_name: "X",
        source: "manual",
      },
    ] as IdentityRow[];
    expect(() => saveIdentityMap(vaultRoot, "t1", "t-uuid", rows)).toThrow(RoutingConfigError);
  });
});
