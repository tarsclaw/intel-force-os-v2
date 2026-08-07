// Loader + validator for /vault/{tenant}/routing/function-roles.yaml —
// the only per-firm routing artefact (spec §6).
//
// Schema implemented VERBATIM from docs/specs/approval-routing-architecture.md
// §6.3 as schema_version 1:
//   tenant_id, schema_version, confirmed_at?, confirmed_by?,
//   firm_default_approver { person_ref, display_name }   ← REQUIRED (ladder step 3)
//   functions[]: { function, holder { person_ref, display_name, source },
//                  escalation[] { person_ref, display_name },
//                  ttl_minutes (number|null), breaks_quiet_hours (bool) }
//   function ∈ finance | ops_data | business_development |
//              candidate_comms_default | client_comms_default | admin
//   holder.source ∈ graph_inferred | diagnostic_confirmed | manual
//
// Strictness: unknown schema_version, missing firm_default_approver, unknown
// function name, or malformed holder → RoutingConfigError (typed) — the
// caller treats the resolver as unavailable and falls back to the
// single-operator path (PLAN.md decision 2). We fail the whole file rather
// than partially load: a half-valid routing map silently misroutes approvals.

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { parseYaml, YamlParseError, type YamlValue } from "./yaml-lite.js";
import {
  FUNCTION_NAMES,
  RoutingConfigError,
  type FunctionEscalationEntry,
  type FunctionName,
  type FunctionRoleEntry,
  type FunctionRolesMap,
  type HolderSource,
} from "./types.js";

export const FUNCTION_ROLES_RELATIVE_PATH = join("routing", "function-roles.yaml");

/** Vault path of a tenant's function-roles file. */
export function functionRolesPath(vaultRoot: string, tenantSlug: string): string {
  return join(vaultRoot, tenantSlug, FUNCTION_ROLES_RELATIVE_PATH);
}

function isRecord(v: YamlValue): v is { [key: string]: YamlValue } {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}

function invalid(message: string): RoutingConfigError {
  return new RoutingConfigError("function_roles_invalid", `function-roles.yaml: ${message}`);
}

function requireString(
  obj: { [key: string]: YamlValue },
  key: string,
  ctx: string,
): string {
  const v = obj[key];
  if (typeof v !== "string" || v.trim() === "") {
    throw invalid(`${ctx}.${key} must be a non-empty string`);
  }
  return v;
}

const HOLDER_SOURCES: readonly string[] = ["graph_inferred", "diagnostic_confirmed", "manual"];

function parseHolder(v: YamlValue, ctx: string): FunctionRoleEntry["holder"] {
  if (!isRecord(v)) throw invalid(`${ctx}.holder must be a map`);
  const source = requireString(v, "source", `${ctx}.holder`);
  if (!HOLDER_SOURCES.includes(source)) {
    throw invalid(
      `${ctx}.holder.source must be one of ${HOLDER_SOURCES.join("|")} (got "${source}")`,
    );
  }
  return {
    person_ref: requireString(v, "person_ref", `${ctx}.holder`),
    display_name: requireString(v, "display_name", `${ctx}.holder`),
    source: source as HolderSource,
  };
}

function parseEscalation(v: YamlValue, ctx: string): FunctionEscalationEntry[] {
  if (v === undefined || v === null) {
    throw invalid(`${ctx}.escalation must be a list ([] for none)`);
  }
  if (!Array.isArray(v)) throw invalid(`${ctx}.escalation must be a list`);
  return v.map((entry, i) => {
    if (!isRecord(entry)) throw invalid(`${ctx}.escalation[${i}] must be a map`);
    return {
      person_ref: requireString(entry, "person_ref", `${ctx}.escalation[${i}]`),
      display_name: requireString(entry, "display_name", `${ctx}.escalation[${i}]`),
    };
  });
}

function parseTtl(v: YamlValue, ctx: string): number | null {
  if (v === null || v === undefined) return null;
  if (typeof v !== "number" || !Number.isInteger(v) || v <= 0) {
    throw invalid(`${ctx}.ttl_minutes must be a positive integer or null`);
  }
  return v;
}

function parseFunctionEntry(v: YamlValue, index: number): FunctionRoleEntry {
  const ctx = `functions[${index}]`;
  if (!isRecord(v)) throw invalid(`${ctx} must be a map`);
  const fn = requireString(v, "function", ctx);
  if (!(FUNCTION_NAMES as readonly string[]).includes(fn)) {
    throw invalid(
      `${ctx}.function "${fn}" is not a schema_version 1 function (${FUNCTION_NAMES.join("|")})`,
    );
  }
  const bqh = v["breaks_quiet_hours"];
  if (typeof bqh !== "boolean") {
    throw invalid(`${ctx}.breaks_quiet_hours must be true or false`);
  }
  if (!("escalation" in v)) throw invalid(`${ctx}.escalation is required ([] for none)`);
  if (!("ttl_minutes" in v)) throw invalid(`${ctx}.ttl_minutes is required (null = holds indefinitely)`);
  return {
    function: fn as FunctionName,
    holder: parseHolder(v["holder"], ctx),
    escalation: parseEscalation(v["escalation"], ctx),
    ttl_minutes: parseTtl(v["ttl_minutes"], ctx),
    breaks_quiet_hours: bqh,
  };
}

/** Validates an already-parsed YAML document into a FunctionRolesMap. */
export function validateFunctionRoles(doc: YamlValue): FunctionRolesMap {
  if (!isRecord(doc)) throw invalid("document must be a map");

  const schemaVersion = doc["schema_version"];
  if (schemaVersion !== 1) {
    throw invalid(
      `unknown schema_version ${JSON.stringify(schemaVersion)} — this loader implements schema_version 1 only`,
    );
  }

  const firmDefault = doc["firm_default_approver"];
  if (firmDefault === undefined || firmDefault === null) {
    throw invalid("firm_default_approver is REQUIRED (ladder step 3 — must always be set)");
  }
  if (!isRecord(firmDefault)) throw invalid("firm_default_approver must be a map");

  const functionsRaw = doc["functions"];
  if (!Array.isArray(functionsRaw)) throw invalid("functions must be a list");
  const functions = functionsRaw.map((entry, i) => parseFunctionEntry(entry, i));

  const seen = new Set<string>();
  for (const f of functions) {
    if (seen.has(f.function)) throw invalid(`duplicate function entry "${f.function}"`);
    seen.add(f.function);
  }

  const out: FunctionRolesMap = {
    tenant_id: requireString(doc, "tenant_id", "document"),
    schema_version: 1,
    firm_default_approver: {
      person_ref: requireString(firmDefault, "person_ref", "firm_default_approver"),
      display_name: requireString(firmDefault, "display_name", "firm_default_approver"),
    },
    functions,
  };
  if (typeof doc["confirmed_at"] === "string") out.confirmed_at = doc["confirmed_at"];
  if (typeof doc["confirmed_by"] === "string") out.confirmed_by = doc["confirmed_by"];
  return out;
}

/**
 * Loads + validates a tenant's function-roles.yaml.
 * Throws RoutingConfigError("function_roles_missing") when absent,
 * RoutingConfigError("function_roles_invalid") on any schema violation.
 */
export function loadFunctionRoles(vaultRoot: string, tenantSlug: string): FunctionRolesMap {
  const path = functionRolesPath(vaultRoot, tenantSlug);
  let raw: string;
  try {
    raw = readFileSync(path, "utf-8");
  } catch {
    throw new RoutingConfigError(
      "function_roles_missing",
      `function-roles.yaml not found at ${path}`,
    );
  }
  let doc: YamlValue;
  try {
    doc = parseYaml(raw);
  } catch (err) {
    if (err instanceof YamlParseError) {
      throw invalid(`unparseable: ${err.message}`);
    }
    throw err;
  }
  return validateFunctionRoles(doc);
}

/** Returns the entry for a function, or null when the firm hasn't mapped it. */
export function findFunction(
  map: FunctionRolesMap,
  fn: string,
): FunctionRoleEntry | null {
  return map.functions.find((f) => f.function === fn) ?? null;
}
