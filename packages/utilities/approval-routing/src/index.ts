// @ifos/approval-routing — public surface (W1 resolver core).

export * from "./types.js";
export {
  loadFunctionRoles,
  validateFunctionRoles,
  findFunction,
  functionRolesPath,
  FUNCTION_ROLES_RELATIVE_PATH,
} from "./function-roles.js";
export {
  loadIdentityMap,
  validateIdentityMap,
  saveIdentityMap,
  emptyIdentityMap,
  identityMapPath,
  IDENTITY_MAP_RELATIVE_PATH,
  type IdentityMap,
} from "./identity-map.js";
export {
  loadRegistry,
  validateRegistry,
  parseRoutingRule,
  type ActionClassRegistry,
} from "./registry.js";
export {
  createPostgresOwnerLookup,
  defaultRunPsql,
  OWNER_FIELD_BY_ENTITY_TYPE,
  OWNER_LOOKUP_SQL,
  type OwnerLookupConfig,
  type RunPsql,
} from "./owner-lookup.js";
export { resolveApprover, type ResolveDeps } from "./resolve.js";
export { parseYaml, emitYaml, YamlParseError, type YamlValue } from "./yaml-lite.js";
