// Loader/validator/writer for /vault/{tenant}/routing/identity-map.yaml —
// the Bullhorn-user-id → M365-object-id mapping (spec §6.4, PLAN.md
// decision 8).
//
// File shape (one map per tenant, in the vault):
//   tenant_id: "<tenant-uuid-or-slug>"
//   schema_version: 1
//   identities:
//     - bullhorn_user_id: 101
//       m365_object_id: "aad-obj-..."
//       email: "sarah@firm.co.uk"
//       telegram_user_id: "12345"        # optional
//       display_name: "Sarah Khan"
//       source: manual                   # provenance, free-form non-empty
//
// Canonical identity = the M365/Entra object id (spec §6.4: Teams is the
// primary surface and Graph is the directory of record). Lookups go both
// directions: Bullhorn owner id → person_ref (routing) and person_ref →
// transport ids (the W3+ adapters). The v1 populator is the CSV/manual seed
// CLI (bin/seed-identity-map.ts); a future Graph email-match populator
// implements IdentitySource and writes through the same saveIdentityMap().

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

import { parseYaml, emitYaml, YamlParseError, type YamlValue } from "./yaml-lite.js";
import { RoutingConfigError, type IdentityRow } from "./types.js";

export const IDENTITY_MAP_RELATIVE_PATH = join("routing", "identity-map.yaml");

export function identityMapPath(vaultRoot: string, tenantSlug: string): string {
  return join(vaultRoot, tenantSlug, IDENTITY_MAP_RELATIVE_PATH);
}

export interface IdentityMap {
  tenant_id: string;
  rows: IdentityRow[];
  /** Bullhorn user id → row (routing direction). */
  byBullhornUserId(id: number | string): IdentityRow | null;
  /** M365 object id → row (transport direction). */
  byPersonRef(m365ObjectId: string): IdentityRow | null;
}

function invalid(message: string): RoutingConfigError {
  return new RoutingConfigError("identity_map_invalid", `identity-map.yaml: ${message}`);
}

function isRecord(v: YamlValue): v is { [key: string]: YamlValue } {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}

function parseRow(v: YamlValue, i: number): IdentityRow {
  const ctx = `identities[${i}]`;
  if (!isRecord(v)) throw invalid(`${ctx} must be a map`);
  const bh = v["bullhorn_user_id"];
  if (typeof bh !== "number" || !Number.isInteger(bh) || bh <= 0) {
    throw invalid(`${ctx}.bullhorn_user_id must be a positive integer (Bullhorn user id)`);
  }
  const str = (key: string): string => {
    const s = v[key];
    if (typeof s !== "string" || s.trim() === "") {
      throw invalid(`${ctx}.${key} must be a non-empty string`);
    }
    return s;
  };
  const row: IdentityRow = {
    bullhorn_user_id: bh,
    m365_object_id: str("m365_object_id"),
    email: str("email"),
    display_name: str("display_name"),
    source: str("source"),
  };
  const tg = v["telegram_user_id"];
  if (tg !== undefined && tg !== null) {
    if (typeof tg === "string" && tg.trim() !== "") row.telegram_user_id = tg;
    else if (typeof tg === "number" && Number.isInteger(tg)) row.telegram_user_id = String(tg);
    else throw invalid(`${ctx}.telegram_user_id must be a string or integer when present`);
  }
  return row;
}

function buildMap(tenantId: string, rows: IdentityRow[]): IdentityMap {
  const byBh = new Map<string, IdentityRow>();
  const byRef = new Map<string, IdentityRow>();
  for (const row of rows) {
    const bhKey = String(row.bullhorn_user_id);
    if (byBh.has(bhKey)) {
      throw invalid(`duplicate bullhorn_user_id ${bhKey}`);
    }
    byBh.set(bhKey, row);
    // person_ref duplicates are allowed (one human may absorb several Bullhorn
    // users after a leaver hand-over); first row wins for the reverse lookup.
    if (!byRef.has(row.m365_object_id)) byRef.set(row.m365_object_id, row);
  }
  return {
    tenant_id: tenantId,
    rows,
    byBullhornUserId: (id) => byBh.get(String(id)) ?? null,
    byPersonRef: (ref) => byRef.get(ref) ?? null,
  };
}

/** Validates an already-parsed YAML document into an IdentityMap. */
export function validateIdentityMap(doc: YamlValue): IdentityMap {
  if (!isRecord(doc)) throw invalid("document must be a map");
  if (doc["schema_version"] !== 1) {
    throw invalid(
      `unknown schema_version ${JSON.stringify(doc["schema_version"])} — this loader implements schema_version 1 only`,
    );
  }
  const tenantId = doc["tenant_id"];
  if (typeof tenantId !== "string" || tenantId.trim() === "") {
    throw invalid("tenant_id must be a non-empty string");
  }
  const identities = doc["identities"];
  if (!Array.isArray(identities)) throw invalid("identities must be a list ([] for none)");
  return buildMap(tenantId, identities.map((row, i) => parseRow(row, i)));
}

/**
 * Loads + validates a tenant's identity-map.yaml.
 * Throws RoutingConfigError("identity_map_missing") when absent,
 * RoutingConfigError("identity_map_invalid") on any schema violation.
 */
export function loadIdentityMap(vaultRoot: string, tenantSlug: string): IdentityMap {
  const path = identityMapPath(vaultRoot, tenantSlug);
  let raw: string;
  try {
    raw = readFileSync(path, "utf-8");
  } catch {
    throw new RoutingConfigError(
      "identity_map_missing",
      `identity-map.yaml not found at ${path}`,
    );
  }
  let doc: YamlValue;
  try {
    doc = parseYaml(raw);
  } catch (err) {
    if (err instanceof YamlParseError) throw invalid(`unparseable: ${err.message}`);
    throw err;
  }
  return validateIdentityMap(doc);
}

/** An empty in-memory map (e.g. when the vault file is absent but the ladder should still fall through, not error). */
export function emptyIdentityMap(tenantId: string): IdentityMap {
  return buildMap(tenantId, []);
}

/** Serialises + writes identity rows to the tenant's vault file (creates routing/ if needed). */
export function saveIdentityMap(
  vaultRoot: string,
  tenantSlug: string,
  tenantId: string,
  rows: IdentityRow[],
): string {
  // Validate-before-write: round the rows through the validator so a bad
  // programmatic caller can never persist an unloadable file.
  const doc: YamlValue = {
    tenant_id: tenantId,
    schema_version: 1,
    identities: rows.map((r) => {
      const out: { [key: string]: YamlValue } = {
        bullhorn_user_id: r.bullhorn_user_id,
        m365_object_id: r.m365_object_id,
        email: r.email,
        display_name: r.display_name,
        source: r.source,
      };
      if (r.telegram_user_id !== undefined) out["telegram_user_id"] = r.telegram_user_id;
      return out;
    }),
  };
  validateIdentityMap(doc);
  const path = identityMapPath(vaultRoot, tenantSlug);
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, emitYaml(doc), "utf-8");
  return path;
}
