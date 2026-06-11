// Shared test doubles + fixture loaders — kept thin so each test reads at
// the assertion layer (autosend-bridge test-helpers idiom).

import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { validateFunctionRoles } from "../src/function-roles.js";
import { validateIdentityMap, type IdentityMap } from "../src/identity-map.js";
import { validateRegistry, type ActionClassRegistry } from "../src/registry.js";
import { parseYaml } from "../src/yaml-lite.js";
import type { FunctionRolesMap, OwnerLookup, RecordRef } from "../src/types.js";

export const FIXTURES_DIR = join(dirname(fileURLToPath(import.meta.url)), "fixtures");

export function readFixture(name: string): string {
  return readFileSync(join(FIXTURES_DIR, name), "utf-8");
}

export function fixtureFunctionRoles(): FunctionRolesMap {
  return validateFunctionRoles(parseYaml(readFixture("function-roles.valid.yaml")));
}

export function fixtureIdentityMap(): IdentityMap {
  return validateIdentityMap(parseYaml(readFixture("identity-map.valid.yaml")));
}

export function fixtureRegistry(): ActionClassRegistry {
  return validateRegistry(parseYaml(readFixture("action-class-registry.yaml")));
}

/** OwnerLookup double: fixed owner table keyed by "<entity_type>/<entity_id>". */
export function makeOwnerLookup(
  owners: Record<string, string>,
): OwnerLookup & { calls: { tenant: string; record: RecordRef }[] } {
  const calls: { tenant: string; record: RecordRef }[] = [];
  const fn = (async (tenant: string, record: RecordRef) => {
    calls.push({ tenant, record });
    const owner = owners[`${record.entity_type}/${record.entity_id}`];
    return owner ? { owner_bullhorn_user_id: owner } : null;
  }) as OwnerLookup & { calls: { tenant: string; record: RecordRef }[] };
  fn.calls = calls;
  return fn;
}
