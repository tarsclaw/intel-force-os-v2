// The §4 ladder — pure-function unit tests over injected fakes:
// owner-hit / no-owner→firm default+flag / function role / unmapped
// function→firm default / property precedence / escalation-plan shape.

import { describe, expect, it } from "vitest";

import { resolveApprover, type ResolveDeps } from "../src/resolve.js";
import { RoutingConfigError } from "../src/types.js";
import {
  fixtureFunctionRoles,
  fixtureIdentityMap,
  fixtureRegistry,
  makeOwnerLookup,
} from "./test-helpers.js";

function deps(owners: Record<string, string> = {}): ResolveDeps {
  return {
    registry: fixtureRegistry(),
    functionRoles: fixtureFunctionRoles(),
    identityMap: fixtureIdentityMap(),
    ownerLookup: makeOwnerLookup(owners),
  };
}

describe("ladder step 1 — record owner", () => {
  it("routes a record-bound action to the owner via entities + identity-map", async () => {
    const d = deps({ "candidate/CAND-1": "101" });
    const result = await resolveApprover(
      {
        tenant_slug: "t1",
        action_type: "gmail_outlook_send_to_candidate",
        record: { entity_type: "candidate", entity_id: "CAND-1" },
      },
      d,
    );
    expect(result.ladder_step).toBe("record_owner");
    expect(result.person_ref).toBe("aad-sarah-khan");
    expect(result.display_name).toBe("Sarah Khan");
    expect(result.function).toBeUndefined();
    expect(result.unowned_record).toBeUndefined();
    expect(result.trust_bucket).toBe(2);
    expect(result.ttl_minutes).toBe(120);
    expect(result.on_expiry).toBe("safe_default");
    expect(result.breaks_quiet_hours).toBe(true);
    // Backup chain after a record owner = firm default (no desk-lead data in v1).
    expect(result.escalation_plan).toEqual([
      { person_ref: "aad-jane-founder", display_name: "Jane Founder", after_minutes: 30 },
    ]);
    expect(result.reason).toContain("bullhorn_user_id=101");
    expect(result.reason).toContain("record owner");
  });

  it("passes the tenant + record through to the owner lookup", async () => {
    const lookup = makeOwnerLookup({ "candidate/CAND-1": "101" });
    const d = { ...deps(), ownerLookup: lookup };
    await resolveApprover(
      {
        tenant_slug: "tenant-xyz",
        action_type: "gmail_outlook_send_to_candidate",
        record: { entity_type: "candidate", entity_id: "CAND-1" },
      },
      d,
    );
    expect(lookup.calls).toEqual([
      { tenant: "tenant-xyz", record: { entity_type: "candidate", entity_id: "CAND-1" } },
    ]);
  });
});

describe("ladder gaps (§4.2) — unowned / unmappable records", () => {
  it("unowned record → firm default + unowned_record flag (Janitor finding)", async () => {
    const result = await resolveApprover(
      {
        tenant_slug: "t1",
        action_type: "gmail_outlook_send_to_candidate",
        record: { entity_type: "candidate", entity_id: "CAND-NOBODY" },
      },
      deps({}),
    );
    expect(result.ladder_step).toBe("firm_default");
    expect(result.person_ref).toBe("aad-jane-founder");
    expect(result.unowned_record).toBe(true);
    expect(result.escalation_plan).toEqual([]);
    expect(result.reason).toContain("no owner");
    expect(result.reason).toContain("§4.2");
  });

  it("owner present but unmapped in the identity map → firm default + flag", async () => {
    const result = await resolveApprover(
      {
        tenant_slug: "t1",
        action_type: "gmail_outlook_send_to_candidate",
        record: { entity_type: "candidate", entity_id: "CAND-1" },
      },
      deps({ "candidate/CAND-1": "404" }), // bullhorn user 404 not in identity map
    );
    expect(result.ladder_step).toBe("firm_default");
    expect(result.unowned_record).toBe(true);
    expect(result.reason).toContain("identity-map");
    expect(result.reason).toContain("404");
  });

  it("record_owner action with NO record supplied → firm default, no unowned flag", async () => {
    const result = await resolveApprover(
      { tenant_slug: "t1", action_type: "gmail_outlook_send_to_candidate" },
      deps(),
    );
    expect(result.ladder_step).toBe("firm_default");
    expect(result.unowned_record).toBeUndefined();
    expect(result.reason).toContain("no record was supplied");
  });
});

describe("ladder step 2 — function role", () => {
  it("routes a function-bound action to the §6.3 holder", async () => {
    const result = await resolveApprover(
      { tenant_slug: "t1", action_type: "xero_reminder_send_customer" },
      deps(),
    );
    expect(result.ladder_step).toBe("function_role");
    expect(result.function).toBe("finance");
    expect(result.person_ref).toBe("aad-priya-finance");
    expect(result.display_name).toBe("Priya Finance");
    expect(result.trust_bucket).toBe(3);
    expect(result.ttl_minutes).toBeNull(); // registry explicit null — holds indefinitely
    expect(result.on_expiry).toBe("hold");
    // escalation_after_minutes null → class never escalates, despite §6.3 chain.
    expect(result.escalation_plan).toEqual([]);
    expect(result.reason).toContain('function "finance"');
    expect(result.reason).toContain("graph_inferred");
  });

  it("builds the escalation plan from the §6.3 chain, terminated at the firm default", async () => {
    const result = await resolveApprover(
      { tenant_slug: "t1", action_type: "bullhorn_candidate_tag" }, // ops_data, escalation 240m
      deps(),
    );
    expect(result.ladder_step).toBe("function_role");
    expect(result.person_ref).toBe("aad-tom-ops");
    // Chain = [Jane Founder]; firm default = Jane Founder → deduped to one hop.
    expect(result.escalation_plan).toEqual([
      { person_ref: "aad-jane-founder", display_name: "Jane Founder", after_minutes: 240 },
    ]);
  });

  it("registry row omitting ttl/quiet-hours inherits the §6.3 per-function values", async () => {
    const result = await resolveApprover(
      { tenant_slug: "t1", action_type: "client_hunter_outreach_draft" },
      deps(),
    );
    expect(result.function).toBe("business_development");
    expect(result.ttl_minutes).toBe(120); // from function-roles.yaml bd row
    expect(result.breaks_quiet_hours).toBe(true); // from function-roles.yaml bd row
  });
});

describe("ladder step 3 — firm default", () => {
  it("function unmapped in the firm's map → firm default (nothing falls through)", async () => {
    const d = deps();
    // Firm mapped only finance — drop the rest.
    d.functionRoles = {
      ...d.functionRoles,
      functions: d.functionRoles.functions.filter((f) => f.function === "finance"),
    };
    const result = await resolveApprover(
      { tenant_slug: "t1", action_type: "bullhorn_candidate_tag" }, // wants ops_data
      d,
    );
    expect(result.ladder_step).toBe("firm_default");
    expect(result.person_ref).toBe("aad-jane-founder");
    expect(result.unowned_record).toBeUndefined();
    expect(result.escalation_plan).toEqual([]);
    expect(result.reason).toContain("unmapped");
  });
});

describe("registry gate", () => {
  it("unregistered action_type → typed RoutingConfigError (caller falls back)", async () => {
    await expect(
      resolveApprover({ tenant_slug: "t1", action_type: "made_up_action" }, deps()),
    ).rejects.toMatchObject({
      name: "RoutingConfigError",
      code: "action_type_unregistered",
    });
    await expect(
      resolveApprover({ tenant_slug: "t1", action_type: "made_up_action" }, deps()),
    ).rejects.toBeInstanceOf(RoutingConfigError);
  });
});

describe("auditability", () => {
  it("every resolution carries ladder_step + a non-empty reason", async () => {
    const cases: { action_type: string; record?: { entity_type: string; entity_id: string } }[] = [
      {
        action_type: "gmail_outlook_send_to_candidate",
        record: { entity_type: "candidate", entity_id: "CAND-1" },
      },
      {
        action_type: "gmail_outlook_send_to_candidate",
        record: { entity_type: "candidate", entity_id: "CAND-X" },
      },
      { action_type: "xero_reminder_send_customer" },
      { action_type: "bullhorn_candidate_tag" },
    ];
    for (const c of cases) {
      const result = await resolveApprover(
        { tenant_slug: "t1", ...c },
        deps({ "candidate/CAND-1": "101" }),
      );
      expect(result.ladder_step).toBeTruthy();
      expect(result.reason.length).toBeGreaterThan(10);
      expect(result.person_ref).toBeTruthy();
    }
  });
});
