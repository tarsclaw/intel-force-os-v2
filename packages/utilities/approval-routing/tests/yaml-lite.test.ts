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

  // ── Review fix 1 (MAJOR): apostrophes in unquoted scalars must not
  //    swallow trailing comments — the vault file is tenant-hand-edited. ──
  describe("apostrophes in plain scalars vs trailing comments", () => {
    it("strips a comment after a plain scalar containing an apostrophe (probe case)", () => {
      const doc = parseYaml("display_name: Pat O'Brien # the desk lead") as Record<string, unknown>;
      expect(doc["display_name"]).toBe("Pat O'Brien");
    });

    it("keeps an apostrophe-bearing plain scalar intact when there is no comment", () => {
      const doc = parseYaml("display_name: Pat O'Brien") as Record<string, unknown>;
      expect(doc["display_name"]).toBe("Pat O'Brien");
    });

    it("handles apostrophes inside sequence-item maps with trailing comments", () => {
      const doc = parseYaml(
        [
          "people:",
          "  - name: Pat O'Brien # desk lead",
          "    note: it's the founder's pick # confirmed",
        ].join("\n"),
      ) as Record<string, unknown>;
      expect(doc["people"]).toEqual([
        { name: "Pat O'Brien", note: "it's the founder's pick" },
      ]);
    });

    it("still protects # and : inside single-quoted values, with '' escapes and a trailing comment", () => {
      const doc = parseYaml(
        ["a: 'hash # inside: yes' # real comment", "h: 'single ''quoted''' # tail"].join("\n"),
      ) as Record<string, unknown>;
      expect(doc["a"]).toBe("hash # inside: yes");
      expect(doc["h"]).toBe("single 'quoted'");
    });

    it("still protects # and : inside double-quoted values, including escaped quotes", () => {
      const doc = parseYaml(
        ['a: "hash # inside: yes" # real comment', 'b: "say \\"hi # there\\"" # tail'].join("\n"),
      ) as Record<string, unknown>;
      expect(doc["a"]).toBe("hash # inside: yes");
      expect(doc["b"]).toBe('say "hi # there"');
    });
  });

  // ── Review fix 2 (MINOR): every block-scalar header variant must be
  //    rejected loudly, never parsed as a plain string like "|-". ──
  describe("block scalar header rejection", () => {
    it.each(["|", "|-", "|+", "|2", "|2-", ">", ">-", ">+", ">2", ">-2"])(
      "rejects 'key: %s' loudly",
      (header) => {
        expect(() => parseYaml(`key: ${header}`)).toThrow(YamlParseError);
        expect(() => parseYaml(`key: ${header}`)).toThrow(/block scalars are not supported/);
      },
    );

    it("rejects block scalar headers in sequence items", () => {
      expect(() => parseYaml("- |-")).toThrow(YamlParseError);
      expect(() => parseYaml("- >2")).toThrow(YamlParseError);
    });

    it("rejects block scalar headers even when a block body follows", () => {
      expect(() => parseYaml("key: |-\n  line one\n  line two")).toThrow(YamlParseError);
    });

    it("still accepts quoted values that merely look like block headers", () => {
      expect(parseYaml('a: "|-"')).toEqual({ a: "|-" });
      expect(parseYaml("b: '>2'")).toEqual({ b: ">2" });
    });
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

  it("round-trips apostrophe-bearing names and hash/escaped-quote strings", () => {
    const doc = { display_name: "Pat O'Brien", note: 'say "hi" # ok' };
    expect(parseYaml(emitYaml(doc))).toEqual(doc);
  });

  it("round-trips empty lists, nulls and booleans", () => {
    const doc = { a: [], b: null, c: true, d: { e: 1, f: "x: y" } };
    expect(parseYaml(emitYaml(doc))).toEqual(doc);
  });
});
