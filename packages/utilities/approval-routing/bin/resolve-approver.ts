// CLI: resolve the approver for an action via the §4 ladder.
//
// Usage (W3 hook-helpers orange path):
//   node dist/bin/resolve-approver.js \
//     --tenant <slug> \
//     --action-type <autosend action_type> \
//     [--entity-type candidate --entity-id CAND-123]   # record-bound actions
//     [--vault-root /vault]                            # default $IFOS_VAULT_ROOT or /vault
//     [--registry agents/_shared/action-class-registry.yaml]
//
// stdout: single-line JSON ResolveResult (person_ref, ladder_step,
//         escalation_plan, ttl_minutes, on_expiry, breaks_quiet_hours,
//         trust_bucket, reason, [unowned_record], [function], [display_name])
//
// exit codes:
//   0 — resolution produced (any ladder step)
//   3 — routing config absent/unusable (function-roles/registry missing or
//       invalid, action_type unregistered, IFOS_DB_URL unset for a
//       record-bound lookup) — caller falls back to the single-operator path
//   1 — real errors (bad args, psql failure)
//
// env:
//   IFOS_VAULT_ROOT     — vault root (default /vault; hook-helpers contract)
//   IFOS_DB_URL         — Postgres URL for the entities owner lookup
//                         (required only when --entity-type/--entity-id given)
//   IFOS_ROUTING_REGISTRY — registry path override (lowest precedence after --registry)
//   IFOS_ROUTING_FAKE   — '{"person_ref":...}' fixture mode: emits the
//                         injected ResolveResult verbatim with "fake": true;
//                         no vault reads, no DB.

import { loadFunctionRoles } from "../src/function-roles.js";
import { emptyIdentityMap, loadIdentityMap, type IdentityMap } from "../src/identity-map.js";
import { createPostgresOwnerLookup } from "../src/owner-lookup.js";
import { loadRegistry } from "../src/registry.js";
import { resolveApprover } from "../src/resolve.js";
import { RoutingConfigError, type OwnerLookup, type ResolveInput } from "../src/types.js";
import {
  EXIT_CONFIG_ABSENT,
  emit,
  fail,
  parseArgs,
  requireArg,
  routingFake,
} from "./cli-shared.js";

const DEFAULT_REGISTRY_PATH = "agents/_shared/action-class-registry.yaml";

async function main(): Promise<void> {
  const fake = routingFake();
  if (fake) {
    emit({ ...fake, fake: true });
    return;
  }

  const args = parseArgs(process.argv.slice(2));
  const tenant = requireArg(args, "tenant");
  const actionType = requireArg(args, "action-type");
  const entityType = args.get("entity-type");
  const entityId = args.get("entity-id");
  if ((entityType && !entityId) || (!entityType && entityId)) {
    fail("--entity-type and --entity-id must be supplied together");
  }
  const vaultRoot = args.get("vault-root") ?? process.env.IFOS_VAULT_ROOT ?? "/vault";
  const registryPath =
    args.get("registry") ?? process.env.IFOS_ROUTING_REGISTRY ?? DEFAULT_REGISTRY_PATH;

  const input: ResolveInput = { tenant_slug: tenant, action_type: actionType };
  if (entityType && entityId) {
    input.record = { entity_type: entityType, entity_id: entityId };
  }

  try {
    const registry = loadRegistry(registryPath);
    const functionRoles = loadFunctionRoles(vaultRoot, tenant);

    // Identity map: absent file is NOT fatal — record-owner resolution just
    // falls through the ladder (§4.2); function-bound routing never needs it.
    let identityMap: IdentityMap;
    try {
      identityMap = loadIdentityMap(vaultRoot, tenant);
    } catch (err) {
      if (err instanceof RoutingConfigError && err.code === "identity_map_missing") {
        identityMap = emptyIdentityMap(tenant);
      } else {
        throw err;
      }
    }

    let ownerLookup: OwnerLookup;
    if (input.record) {
      const dbUrl = process.env.IFOS_DB_URL;
      if (!dbUrl) {
        fail(
          "IFOS_DB_URL unset — cannot resolve the record owner from the entities cache. " +
            "Caller falls back to the single-operator path.",
          EXIT_CONFIG_ABSENT,
        );
      }
      ownerLookup = createPostgresOwnerLookup({ db_url: dbUrl as string });
    } else {
      // Non-record-bound action: ladder step 1 is structurally skipped.
      ownerLookup = async () => null;
    }

    const result = await resolveApprover(input, {
      registry,
      functionRoles,
      identityMap,
      ownerLookup,
    });
    emit(result);
  } catch (err) {
    if (err instanceof RoutingConfigError) {
      fail(`${err.code}: ${err.message}`, EXIT_CONFIG_ABSENT);
    }
    throw err;
  }
}

main().catch((err: unknown) => {
  fail((err as Error)?.message ?? String(err));
});
