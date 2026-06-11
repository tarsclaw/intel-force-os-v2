// RLS-scoped owner lookup over the Postgres `entities` cache — ladder step 1.
//
// ── VERIFIED owner-field mapping (honest; checked 2026-06-11 against the
//    actual repo, not assumed) ─────────────────────────────────────────────
//
// The entities table is (tenant_slug, entity_type, entity_id, data jsonb, ...).
// Owner data lives INSIDE data jsonb. Where it is defined, per
// docs/verticals/recruitment/vertical-schema.yaml:
//
//   entity_type   data field                source                              schema line
//   candidate     owner_user_id (integer)   Bullhorn.Candidate.owner.id         ~91-95
//   contractor    owner_user_id (integer)   inherits candidate base set         ~163-165 ("candidate-overlap fields")
//   client        account_owner_user_id     Bullhorn.ClientCorporation.owner.id ~262-265
//   brief         — none defined —          (JobOrder owner not in schema v0.x)
//   placement     — none defined —          (Placement owner not in schema v0.x)
//   contact       — none defined —
//
// CRITICAL honest finding: although the Bullhorn connector FETCHES owner
// (packages/mcp-connectors/bullhorn/src/candidates.ts DEFAULT_FIELDS includes
// "owner"), the CLI normalisers that feed the entities cache
// (packages/mcp-connectors/bullhorn/src/cli.ts normCandidate/normContact/
// normClient) DROP it — no owner field reaches data jsonb today, and no
// agent fixture seeds one. Therefore live cached rows currently resolve to
// not-found here and the ladder falls through to function role / firm
// default (§4.2) — which is the correct, honest behaviour. Adding
// owner_user_id to the normalisers is W3+ work (flagged in w1-summary.md);
// this reader is coded to the vertical-schema field names so it lights up
// the moment ingest populates them. We NEVER invent an owner.
//
// Posture mirrors the proven autosend-bridge decisions-postgres.ts shape:
// zero npm deps, shells `psql` via execFile with -v variables (no SQL string
// interpolation of caller input), every query inside
// BEGIN; SET LOCAL app.current_tenant = <tenant>; ... COMMIT (tenant-scoped
// by construction), injectable RunPsql keeps unit tests offline.

import { execFile } from "node:child_process";

import type { OwnerLookup, OwnerLookupResult, RecordRef } from "./types.js";

/** Runs psql with the given args + stdin SQL; resolves stdout. Rejects on non-zero exit. */
export type RunPsql = (args: string[], stdinSql: string) => Promise<string>;

const defaultRunPsql: RunPsql = (args, stdinSql) =>
  new Promise((resolve, reject) => {
    const child = execFile("psql", args, { timeout: 30_000 }, (err, stdout, stderr) => {
      if (err) {
        reject(new Error(`psql failed: ${stderr.trim() || err.message}`));
        return;
      }
      resolve(stdout);
    });
    child.stdin?.write(stdinSql);
    child.stdin?.end();
  });

/**
 * entity_type → owner field inside entities.data (vertical-schema.yaml; see
 * the verified mapping in the file header). Absent key = no owner concept
 * for that entity type in schema v0.x → not-found → ladder falls through.
 */
export const OWNER_FIELD_BY_ENTITY_TYPE: Readonly<Record<string, string>> = {
  candidate: "owner_user_id",
  contractor: "owner_user_id",
  client: "account_owner_user_id",
};

// The owner field name is selected from the fixed map above (never from
// caller input) and passed as a psql variable, so caller-controlled strings
// never reach SQL except as bound -v values.
export const OWNER_LOOKUP_SQL = `BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT data->>:'ofield'
FROM entities
WHERE tenant_slug = :'tenant'
  AND entity_type = :'etype'
  AND entity_id = :'eid'
LIMIT 1;
COMMIT;
`;

export interface OwnerLookupConfig {
  /** Postgres connection string (IFOS_DB_URL). Never logged. */
  db_url: string;
  /** Injectable psql runner (tests). Defaults to execFile("psql", ...). */
  runPsql?: RunPsql;
}

/**
 * Creates the OwnerLookup used as ladder step 1. Returns null (not-found)
 * when the entity type has no schema-defined owner field, the row is absent,
 * or the owner field is empty/null — never invents an owner.
 */
export function createPostgresOwnerLookup(config: OwnerLookupConfig): OwnerLookup {
  if (!config.db_url) throw new Error("createPostgresOwnerLookup: db_url is required");
  const runPsql = config.runPsql ?? defaultRunPsql;

  return async (
    tenant_slug: string,
    record: RecordRef,
  ): Promise<OwnerLookupResult | null> => {
    const ownerField = OWNER_FIELD_BY_ENTITY_TYPE[record.entity_type];
    if (!ownerField) return null; // no owner concept for this entity type (schema v0.x)

    const stdout = await runPsql(
      [
        config.db_url,
        "-tAq",
        "-v",
        "ON_ERROR_STOP=1",
        "-v",
        `tenant=${tenant_slug}`,
        "-v",
        `ofield=${ownerField}`,
        "-v",
        `etype=${record.entity_type}`,
        "-v",
        `eid=${record.entity_id}`,
      ],
      OWNER_LOOKUP_SQL,
    );

    const value = stdout
      .split("\n")
      .map((l) => l.trim())
      .find((l) => l !== "");
    if (!value) return null;
    return { owner_bullhorn_user_id: value };
  };
}

export { defaultRunPsql };
