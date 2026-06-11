// Action-class registry loader — agreed row shape (PLAN.md decision 4),
// both envelope shapes (parallel-authoring hedge), typed rejections.

import { describe, expect, it } from "vitest";

import { parseRoutingRule, validateRegistry } from "../src/registry.js";
import { parseYaml } from "../src/yaml-lite.js";
import { RoutingConfigError } from "../src/types.js";
import { fixtureRegistry, readFixture } from "./test-helpers.js";

describe("validateRegistry — fixture (action_types envelope)", () => {
  it("parses every fixture row with the agreed shape", () => {
    const registry = fixtureRegistry();
    expect(registry.rows.size).toBe(5);

    const candSend = registry.require("gmail_outlook_send_to_candidate");
    expect(candSend.routing_rule).toEqual({ kind: "record_owner" });
    expect(candSend.trust_bucket).toBe(2);
    expect(candSend.escalation_after_minutes).toBe(30);
    expect(candSend.ttl_minutes).toBe(120);
    expect(candSend.ttl_minutes_explicit).toBe(true);
    expect(candSend.on_expiry).toBe("safe_default");
    expect(candSend.breaks_quiet_hours).toBe(true);
    expect(candSend.digest_eligible).toBe(false);
    expect(candSend.dormant).toBeUndefined();

    const creditNote = registry.require("xero_reminder_send_customer");
    expect(creditNote.routing_rule).toEqual({ kind: "function_role", function: "finance" });
    expect(creditNote.ttl_minutes).toBeNull(); // explicit null = holds indefinitely
    expect(creditNote.ttl_minutes_explicit).toBe(true);
    expect(creditNote.escalation_after_minutes).toBeNull();

    // Row omitting ttl_minutes/breaks_quiet_hours — explicit flags false so
    // the §6.3 per-function values apply at resolve time.
    const bdDraft = registry.require("client_hunter_outreach_draft");
    expect(bdDraft.ttl_minutes_explicit).toBe(false);
    expect(bdDraft.breaks_quiet_hours_explicit).toBe(false);

    const dormant = registry.require("competitor_interception_first_contact");
    expect(dormant.dormant).toBe(true);
  });

  it("require() throws action_type_unregistered (typed) for unknown keys; get() returns null", () => {
    const registry = fixtureRegistry();
    expect(registry.get("not_a_real_action")).toBeNull();
    try {
      registry.require("not_a_real_action");
      expect.unreachable("expected RoutingConfigError");
    } catch (err) {
      expect(err).toBeInstanceOf(RoutingConfigError);
      expect((err as RoutingConfigError).code).toBe("action_type_unregistered");
    }
  });
});

describe("validateRegistry — bare-map envelope (W2 hedge)", () => {
  it("accepts rows directly under the document root", () => {
    const registry = validateRegistry(
      parseYaml(
        [
          "schema_version: 1",
          "some_action:",
          "  routing_rule: function_role:admin",
          "  trust_bucket: 2",
          "  ttl_minutes: 60",
          "  on_expiry: hold",
          "  breaks_quiet_hours: false",
          "  digest_eligible: true",
        ].join("\n"),
      ),
    );
    expect(registry.require("some_action").routing_rule).toEqual({
      kind: "function_role",
      function: "admin",
    });
  });
});

describe("validateRegistry — typed rejections", () => {
  function row(overrides: Record<string, unknown>): Record<string, unknown> {
    return {
      action_types: {
        some_action: {
          routing_rule: "record_owner",
          trust_bucket: 2,
          ttl_minutes: 60,
          on_expiry: "hold",
          breaks_quiet_hours: false,
          digest_eligible: false,
          ...overrides,
        },
      },
    };
  }

  it("rejects a malformed routing_rule", () => {
    expect(() => validateRegistry(row({ routing_rule: "desk_owner" }))).toThrow(
      RoutingConfigError,
    );
  });

  it("rejects a function_role rule pointing at a non-§6.3 function", () => {
    expect(() => validateRegistry(row({ routing_rule: "function_role:payroll" }))).toThrow(
      RoutingConfigError,
    );
  });

  it("rejects an out-of-range trust_bucket", () => {
    expect(() => validateRegistry(row({ trust_bucket: 4 }))).toThrow(RoutingConfigError);
  });

  it("rejects an unknown on_expiry", () => {
    expect(() => validateRegistry(row({ on_expiry: "explode" }))).toThrow(RoutingConfigError);
  });

  it("rejects an empty registry", () => {
    expect(() => validateRegistry({ action_types: {} })).toThrow(RoutingConfigError);
  });
});

describe("parseRoutingRule", () => {
  it("parses both rule kinds", () => {
    expect(parseRoutingRule("record_owner", "x")).toEqual({ kind: "record_owner" });
    expect(parseRoutingRule("function_role:finance", "x")).toEqual({
      kind: "function_role",
      function: "finance",
    });
  });
});

describe("registry fixture file documents the real-seed contract", () => {
  it("fixture carries the W2 path note (this is NOT the real seed)", () => {
    expect(readFixture("action-class-registry.yaml")).toContain(
      "agents/_shared/action-class-registry.yaml",
    );
  });
});
