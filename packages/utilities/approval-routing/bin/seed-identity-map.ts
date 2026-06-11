// CLI: seed/extend a tenant's identity-map.yaml + render the routing
// confirmation summary.
//
// Three modes:
//
//   1. CSV import (onboarding bulk seed):
//      node dist/bin/seed-identity-map.js --tenant <slug> --csv people.csv \
//        [--vault-root /vault] [--tenant-id <uuid>]
//      CSV header (order-free): bullhorn_user_id,m365_object_id,email,
//      display_name[,telegram_user_id][,source]. Default source: csv_import.
//
//   2. Single-row manual add:
//      node dist/bin/seed-identity-map.js --tenant <slug> --add \
//        --bullhorn-user-id 101 --m365-object-id <aad-id> \
//        --email sarah@firm.co.uk --display-name "Sarah Khan" \
//        [--telegram-user-id 12345] [--source manual]
//
//   3. Confirmation render (the spec-§10.6 confirm-in-Diagnostic default, as
//      a standalone CLI until the onboarding wizard exists):
//      node dist/bin/seed-identity-map.js --tenant <slug> --render-confirmation
//      Prints a Diagnostic-style cited summary of the current function-roles
//      map + identity map ("finance → Priya Finance (source: graph_inferred)
//      — confirm?"), citing the vault file each claim comes from.
//
// Merge semantics: rows are keyed by bullhorn_user_id; an import/add REPLACES
// the existing row for that id and leaves all others untouched.
// stdout: {ok, path, total_rows, added, updated} (modes 1-2); human-readable
// summary (mode 3). exit 0 ok / 1 error / 3 config absent (mode 3 only).

import { readFileSync } from "node:fs";

import { functionRolesPath, loadFunctionRoles } from "../src/function-roles.js";
import {
  identityMapPath,
  loadIdentityMap,
  saveIdentityMap,
  type IdentityMap,
} from "../src/identity-map.js";
import { RoutingConfigError, type IdentityRow, type FunctionRolesMap } from "../src/types.js";
import { EXIT_CONFIG_ABSENT, emit, fail, parseArgs, requireArg } from "./cli-shared.js";

// ── Minimal CSV (RFC-4180 subset: quoted fields, embedded commas/quotes) ──

function parseCsvLine(line: string): string[] {
  const out: string[] = [];
  let field = "";
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (inQuotes) {
      if (c === '"') {
        if (line[i + 1] === '"') {
          field += '"';
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field += c;
      }
    } else if (c === '"' && field === "") {
      inQuotes = true;
    } else if (c === ",") {
      out.push(field);
      field = "";
    } else {
      field += c;
    }
  }
  out.push(field);
  return out.map((f) => f.trim());
}

const CSV_REQUIRED = ["bullhorn_user_id", "m365_object_id", "email", "display_name"];

function rowsFromCsv(csvPath: string): IdentityRow[] {
  let raw: string;
  try {
    raw = readFileSync(csvPath, "utf-8");
  } catch {
    fail(`CSV not found at ${csvPath}`);
  }
  const lines = (raw as string).split(/\r?\n/).filter((l) => l.trim() !== "");
  if (lines.length < 2) fail("CSV must contain a header row plus at least one data row");
  const header = parseCsvLine(lines[0]).map((h) => h.toLowerCase());
  for (const required of CSV_REQUIRED) {
    if (!header.includes(required)) fail(`CSV header missing required column "${required}"`);
  }
  const rows: IdentityRow[] = [];
  for (let n = 1; n < lines.length; n++) {
    const cells = parseCsvLine(lines[n]);
    const get = (col: string): string => {
      const idx = header.indexOf(col);
      return idx >= 0 ? (cells[idx] ?? "") : "";
    };
    const bh = Number(get("bullhorn_user_id"));
    if (!Number.isInteger(bh) || bh <= 0) {
      fail(`CSV row ${n + 1}: bullhorn_user_id must be a positive integer (got "${get("bullhorn_user_id")}")`);
    }
    const row: IdentityRow = {
      bullhorn_user_id: bh,
      m365_object_id: get("m365_object_id"),
      email: get("email"),
      display_name: get("display_name"),
      source: get("source") || "csv_import",
    };
    const tg = get("telegram_user_id");
    if (tg) row.telegram_user_id = tg;
    for (const key of ["m365_object_id", "email", "display_name"] as const) {
      if (!row[key]) fail(`CSV row ${n + 1}: ${key} must be non-empty`);
    }
    rows.push(row);
  }
  return rows;
}

// ── Confirmation render (spec §10.6 default) ──────────────────────────────

function renderConfirmation(
  tenant: string,
  vaultRoot: string,
  functionRoles: FunctionRolesMap,
  identityMap: IdentityMap | null,
): string {
  const frPath = functionRolesPath(vaultRoot, tenant);
  const imPath = identityMapPath(vaultRoot, tenant);
  const lines: string[] = [];
  lines.push(`── Routing confirmation — tenant ${tenant} ──`);
  lines.push("");
  lines.push(`Function→role map (source: ${frPath})`);
  lines.push(
    functionRoles.confirmed_at
      ? `  confirmed_at: ${functionRoles.confirmed_at}${functionRoles.confirmed_by ? ` by ${functionRoles.confirmed_by}` : ""}`
      : "  confirmed_at: NOT YET CONFIRMED",
  );
  lines.push("");
  for (const fn of functionRoles.functions) {
    lines.push(
      `  ${fn.function} → ${fn.holder.display_name} (source: ${fn.holder.source}) — confirm?`,
    );
    const esc =
      fn.escalation.length > 0
        ? fn.escalation.map((e) => e.display_name).join(" → ")
        : "none";
    const ttl = fn.ttl_minutes === null ? "none (holds indefinitely)" : `${fn.ttl_minutes}m`;
    lines.push(
      `    escalation: ${esc}; ttl: ${ttl}; quiet hours: ${fn.breaks_quiet_hours ? "MAY break" : "respects"}`,
    );
  }
  lines.push("");
  lines.push(
    `  firm default approver (ladder step 3) → ${functionRoles.firm_default_approver.display_name} — confirm?`,
  );
  lines.push("");
  if (identityMap) {
    lines.push(`Identity map — ${identityMap.rows.length} row(s) (source: ${imPath})`);
    for (const row of identityMap.rows) {
      const tg = row.telegram_user_id ? `, telegram: ${row.telegram_user_id}` : "";
      lines.push(
        `  bullhorn ${row.bullhorn_user_id} → ${row.display_name} <${row.email}> (m365: ${row.m365_object_id}${tg}; source: ${row.source})`,
      );
    }
  } else {
    lines.push(
      `Identity map — ABSENT (expected at ${imPath}); record-owner routing will fall through to the firm default until it is seeded.`,
    );
  }
  lines.push("");
  lines.push(
    "Confirm these in the Diagnostic; corrections = edit the cited vault file (one holder row per change).",
  );
  return lines.join("\n");
}

// ── Main ──────────────────────────────────────────────────────────────────

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const tenant = requireArg(args, "tenant");
  const vaultRoot = args.get("vault-root") ?? process.env.IFOS_VAULT_ROOT ?? "/vault";

  if (args.has("render-confirmation")) {
    let functionRoles: FunctionRolesMap;
    try {
      functionRoles = loadFunctionRoles(vaultRoot, tenant);
    } catch (err) {
      if (err instanceof RoutingConfigError) {
        fail(`${err.code}: ${err.message}`, EXIT_CONFIG_ABSENT);
      }
      throw err;
    }
    let identityMap: IdentityMap | null = null;
    try {
      identityMap = loadIdentityMap(vaultRoot, tenant);
    } catch (err) {
      if (!(err instanceof RoutingConfigError) || err.code !== "identity_map_missing") {
        throw err;
      }
    }
    process.stdout.write(`${renderConfirmation(tenant, vaultRoot, functionRoles, identityMap)}\n`);
    return;
  }

  let newRows: IdentityRow[];
  if (args.has("csv")) {
    newRows = rowsFromCsv(requireArg(args, "csv"));
  } else if (args.has("add")) {
    const bh = Number(requireArg(args, "bullhorn-user-id"));
    if (!Number.isInteger(bh) || bh <= 0) {
      fail("--bullhorn-user-id must be a positive integer");
    }
    const row: IdentityRow = {
      bullhorn_user_id: bh,
      m365_object_id: requireArg(args, "m365-object-id"),
      email: requireArg(args, "email"),
      display_name: requireArg(args, "display-name"),
      source: args.get("source") ?? "manual",
    };
    const tg = args.get("telegram-user-id");
    if (tg) row.telegram_user_id = tg;
    newRows = [row];
  } else {
    fail("one of --csv <path>, --add, or --render-confirmation is required");
  }

  // Merge with the existing map (absent file = fresh map; invalid file = hard
  // error — never silently overwrite a corrupt-but-recoverable artefact).
  let existing: IdentityRow[] = [];
  let tenantId = args.get("tenant-id") ?? tenant;
  try {
    const current = loadIdentityMap(vaultRoot, tenant);
    existing = current.rows;
    if (!args.has("tenant-id")) tenantId = current.tenant_id;
  } catch (err) {
    if (!(err instanceof RoutingConfigError) || err.code !== "identity_map_missing") {
      throw err;
    }
  }

  const byId = new Map<number, IdentityRow>(existing.map((r) => [r.bullhorn_user_id, r]));
  let added = 0;
  let updated = 0;
  for (const row of newRows) {
    if (byId.has(row.bullhorn_user_id)) updated++;
    else added++;
    byId.set(row.bullhorn_user_id, row);
  }
  const merged = [...byId.values()].sort((a, b) => a.bullhorn_user_id - b.bullhorn_user_id);
  const path = saveIdentityMap(vaultRoot, tenant, tenantId, merged);
  emit({ ok: true, path, total_rows: merged.length, added, updated });
}

main().catch((err: unknown) => {
  if (err instanceof RoutingConfigError) {
    fail(`${err.code}: ${err.message}`);
  }
  fail((err as Error)?.message ?? String(err));
});
