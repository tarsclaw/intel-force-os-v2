// yaml-lite scope tests — must parse the §6.3 artefact shape verbatim and
// fail LOUDLY (never silently misparse) on out-of-scope constructs.

import { describe, expect, it } from "vitest";

import { emitYaml, parseYaml, YamlParseError } from "../src/yaml-lite.js";
import { readFixture } from "./test-helpers.js";

describe("parseYaml", () => {
  it("parses the §6.3 function-roles fixture verbatim (comments, quotes, nested list maps, [])", () => {
    const doc = parseYaml(readFixture("function-roles.valid.yaml")) as Record<string, unknown>;
    expect(doc["tenant_id"]).toBe("fixture-tenant-uuid");
    expect(doc["schema_version"]).toBe(1);
    expect(doc["confirmed_at"]).toBe("2026-06-10T00:00:00Z");
    const firmDefault = doc["firm_default_approver"] as Record<string, unknown>;
    expect(firmDefault["display_name"]).toBe("Jane Founder");
    const functions = doc["functions"] as Record<string, unknown>[];
    expect(functions).toHaveLength(6);
    const finance = functions[0];
    expect(finance["function"]).toBe("finance");
    expect(finance["ttl_minutes"]).toBeNull(); // trailing comment after null
    expect((finance["holder"] as Record<string, unknown>)["source"]).toBe("graph_inferred");
    expect(finance["breaks_quiet_hours"]).toBe(false);
    const candDefault = functions[3];
    expect(candDefault["escalation"]).toEqual([]); // inline empty list
    expect(candDefault["ttl_minutes"]).toBe(120);
    const bd = functions[2];
    expect((bd["holder"] as Record<string, unknown>)["display_name"]).toBe("Desk Lead — Tech");
    expect(bd["breaks_quiet_hours"]).toBe(true);
    const escalation = finance["escalation"] as Record<string, unknown>[];
    expect(escalation).toEqual([
      { person_ref: "aad-jane-founder", display_name: "Jane Founder" },
    ]);
  });

  it("parses scalars: null/~, booleans, ints, floats, quoted strings with # inside", () => {
    const doc = parseYaml(
      [
        "a: null",
        "b: ~",
        "c: true",
        "d: false",
        "e: 42",
        "f: -3.5",
        'g: "hash # inside"',
        "h: 'single ''quoted'''",
        "i: plain string value",
      ].join("\n"),
    ) as Record<string, unknown>;
    expect(doc).toEqual({
      a: null,
      b: null,
      c: true,
      d: false,
      e: 42,
      f: -3.5,
      g: "hash # inside",
      h: "single 'quoted'",
      i: "plain string value",
    });
  });

  it("rejects tabs, anchors, block scalars and duplicate keys loudly", () => {
    expect(() => parseYaml("a:\n\tb: 1")).toThrow(YamlParseError);
    expect(() => parseYaml("a: &anchor 1")).toThrow(YamlParseError);
    expect(() => parseYaml("a: |")).toThrow(YamlParseError);
    expect(() => parseYaml("a: 1\na: 2")).toThrow(YamlParseError);
    expect(() => parseYaml("a: [1, 2]")).toThrow(YamlParseError);
  });
});

describe("emitYaml", () => {
  it("round-trips an identity-map-shaped document", () => {
    const doc = {
      tenant_id: "t-1",
      schema_version: 1,
      identities: [
        {
          bullhorn_user_id: 101,
          m365_object_id: "aad-1",
          email: "a@b.co",
          display_name: "Sarah — Khan", // forces quoting
          source: "manual",
        },
      ],
    };
    expect(parseYaml(emitYaml(doc))).toEqual(doc);
  });

  it("round-trips empty lists, nulls and booleans", () => {
    const doc = { a: [], b: null, c: true, d: { e: 1, f: "x: y" } };
    expect(parseYaml(emitYaml(doc))).toEqual(doc);
  });
});
