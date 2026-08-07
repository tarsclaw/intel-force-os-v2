// resolve_approver(action) → ResolveResult — the §4 record-owner-first
// ladder as a PURE function over injected dependencies (spec §9 Phase A:
// "Pure function over (Bullhorn owner lookup, function-roles map, firm
// default)").
//
//   1. RECORD OWNER  — entities cache owner → identity-map → person_ref
//   2. FUNCTION ROLE — registry routing_rule "function_role:<name>" → §6.3 map
//   3. FIRM DEFAULT  — function-roles firm_default_approver (always set)
//
// Gap rules (§4.2):
//   - record-bound action whose record has no owner (or owner unmappable in
//     the identity map) → firm default, result flagged unowned_record: true.
//     The CALLER emits the Janitor-finding audit row off that flag.
//   - function unmapped/unfilled → firm default ("nothing falls through").
//
// Every result carries ladder_step + reason — routing itself is auditable
// (spec §9 Phase A decision-log integration; the W3 caller writes the row).
//
// Property precedence (action class vs function row): the action-class
// registry is per-CLASS and shipped (§5.1 — "every action class carries five
// routing properties"), so an explicit registry key wins; the §6.3
// per-function ttl_minutes / breaks_quiet_hours apply when the registry row
// omitted the key and the resolution went through a function. The
// *_explicit flags on ActionClassRow keep "ttl_minutes: null" (explicit:
// hold indefinitely) distinguishable from an absent key.

import { findFunction } from "./function-roles.js";
import type { ActionClassRegistry } from "./registry.js";
import type { IdentityMap } from "./identity-map.js";
import type {
  ActionClassRow,
  EscalationHop,
  FunctionRoleEntry,
  FunctionRolesMap,
  OwnerLookup,
  ResolveInput,
  ResolveResult,
} from "./types.js";

export interface ResolveDeps {
  registry: ActionClassRegistry;
  functionRoles: FunctionRolesMap;
  identityMap: IdentityMap;
  /** Ladder step 1 — entities-cache owner reader. */
  ownerLookup: OwnerLookup;
}

/** Appends the firm default as the terminal escalation hop (§5: "escalate per chain, then firm default"). */
function buildEscalationPlan(
  row: ActionClassRow,
  chain: { person_ref: string; display_name?: string }[],
  resolvedPersonRef: string,
  firmDefault: { person_ref: string; display_name: string },
): EscalationHop[] {
  const afterMinutes = row.escalation_after_minutes;
  if (afterMinutes === null) return []; // class never escalates (e.g. credit note: holds)

  const hops: EscalationHop[] = [];
  const push = (p: { person_ref: string; display_name?: string }): void => {
    const last = hops.length > 0 ? hops[hops.length - 1].person_ref : resolvedPersonRef;
    if (p.person_ref === last) return; // skip no-op hops (boutique collapse: same human)
    const hop: EscalationHop = { person_ref: p.person_ref, after_minutes: afterMinutes };
    if (p.display_name !== undefined) hop.display_name = p.display_name;
    hops.push(hop);
  };
  for (const entry of chain) push(entry);
  push(firmDefault);
  return hops;
}

function effectiveTtl(row: ActionClassRow, fn: FunctionRoleEntry | null): number | null {
  if (row.ttl_minutes_explicit) return row.ttl_minutes;
  if (fn) return fn.ttl_minutes;
  return row.ttl_minutes;
}

function effectiveQuietHours(row: ActionClassRow, fn: FunctionRoleEntry | null): boolean {
  if (row.breaks_quiet_hours_explicit) return row.breaks_quiet_hours;
  if (fn) return fn.breaks_quiet_hours;
  return row.breaks_quiet_hours;
}

function firmDefaultResult(
  row: ActionClassRow,
  deps: ResolveDeps,
  reason: string,
  opts: { unowned_record?: boolean } = {},
): ResolveResult {
  const firmDefault = deps.functionRoles.firm_default_approver;
  const result: ResolveResult = {
    person_ref: firmDefault.person_ref,
    display_name: firmDefault.display_name,
    ladder_step: "firm_default",
    // Firm default IS the terminal rung — nobody to escalate to beyond it.
    escalation_plan: [],
    ttl_minutes: effectiveTtl(row, null),
    on_expiry: row.on_expiry,
    breaks_quiet_hours: effectiveQuietHours(row, null),
    trust_bucket: row.trust_bucket,
    reason,
  };
  if (opts.unowned_record) result.unowned_record = true;
  return result;
}

function functionRoleResult(
  row: ActionClassRow,
  fn: FunctionRoleEntry,
  deps: ResolveDeps,
  reason: string,
): ResolveResult {
  return {
    person_ref: fn.holder.person_ref,
    display_name: fn.holder.display_name,
    ladder_step: "function_role",
    function: fn.function,
    escalation_plan: buildEscalationPlan(
      row,
      fn.escalation,
      fn.holder.person_ref,
      deps.functionRoles.firm_default_approver,
    ),
    ttl_minutes: effectiveTtl(row, fn),
    on_expiry: row.on_expiry,
    breaks_quiet_hours: effectiveQuietHours(row, fn),
    trust_bucket: row.trust_bucket,
    reason,
  };
}

/**
 * The §4 ladder. Throws RoutingConfigError (via registry.require) for an
 * unregistered action_type — the caller falls back to the single-operator
 * path. Otherwise ALWAYS resolves (firm default guarantees a person).
 */
export async function resolveApprover(
  input: ResolveInput,
  deps: ResolveDeps,
): Promise<ResolveResult> {
  const row = deps.registry.require(input.action_type);

  // ── Rule: function_role:<name> (function-bound agents) ──────────────────
  if (row.routing_rule.kind === "function_role") {
    const fnName = row.routing_rule.function;
    const fn = findFunction(deps.functionRoles, fnName);
    if (fn) {
      return functionRoleResult(
        row,
        fn,
        deps,
        `function-bound action_type "${input.action_type}" → function "${fnName}" → ${fn.holder.display_name} (holder source: ${fn.holder.source})`,
      );
    }
    return firmDefaultResult(
      row,
      deps,
      `function-bound action_type "${input.action_type}" → function "${fnName}" unmapped in function-roles.yaml → firm default (§4 step 3)`,
    );
  }

  // ── Rule: record_owner (desk-bound agents) ───────────────────────────────
  if (!input.record) {
    // Misconfiguration guard: a record_owner class invoked without a record.
    // Nothing falls through (§4 step 3) — firm default, reason says why.
    return firmDefaultResult(
      row,
      deps,
      `action_type "${input.action_type}" routes record_owner but no record was supplied → firm default (§4 step 3)`,
    );
  }

  const owner = await deps.ownerLookup(input.tenant_slug, input.record);
  if (!owner) {
    // §4.2: record with no owner in Bullhorn → firm default + Janitor-finding flag.
    return firmDefaultResult(
      row,
      deps,
      `record ${input.record.entity_type}/${input.record.entity_id} has no owner in the entities cache → firm default (§4.2 unowned-record rule)`,
      { unowned_record: true },
    );
  }

  const identity = deps.identityMap.byBullhornUserId(owner.owner_bullhorn_user_id);
  if (!identity) {
    // Owner exists in Bullhorn but is unmapped to an M365 identity — we
    // cannot route to an unmappable person; treat as the §4.2 gap (and the
    // identity gap is itself surfaceable via the same flag).
    return firmDefaultResult(
      row,
      deps,
      `record ${input.record.entity_type}/${input.record.entity_id} owner (bullhorn_user_id=${owner.owner_bullhorn_user_id}) has no identity-map row → firm default (§4.2 gap rule)`,
      { unowned_record: true },
    );
  }

  return {
    person_ref: identity.m365_object_id,
    display_name: identity.display_name,
    ladder_step: "record_owner",
    // §5: resolved approver's backup chain. v1 has no per-desk backup data
    // (desk leads are not modelled until a split-desk prospect lands), so the
    // chain after a record owner is the firm default alone.
    escalation_plan: buildEscalationPlan(
      row,
      [],
      identity.m365_object_id,
      deps.functionRoles.firm_default_approver,
    ),
    ttl_minutes: effectiveTtl(row, null),
    on_expiry: row.on_expiry,
    breaks_quiet_hours: effectiveQuietHours(row, null),
    trust_bucket: row.trust_bucket,
    reason: `record ${input.record.entity_type}/${input.record.entity_id} owner bullhorn_user_id=${owner.owner_bullhorn_user_id} → ${identity.display_name} (§4 step 1 record owner)`,
  };
}
