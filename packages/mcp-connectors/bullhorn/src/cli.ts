// @ifos/bullhorn CLI — thin bash↔TS bridge for the Janitor + Scribe agent
// bundles (cycle.sh / bh-bridge.sh invoke `node dist/cli.js <command>`;
// mirrors @ifos/xero + @ifos/quickbooks + @ifos/cv-library connector-CLI
// pattern). Command surface BOUND by the agreed CLI contract (orchestrator
// ruling, docs/features/agent-build/04-reviews/review-scribe.md).
//
// Commands:
//   check-auth — NETWORK-FREE: reports whether creds are in env + whether a
//             token bundle exists on disk; print JSON {ok, creds_present,
//             tokens_present, corporation_id, region}. ok=true only when both
//             creds AND tokens are present (a refresh could succeed).
//   refresh — load tokens from disk; if EITHER token is inside the 90s safety
//             window, rotate via the two-step refreshTokens (Step A OAuth +
//             Step B REST login per src/auth.ts) and persist; otherwise leave
//             the bundle untouched. Print JSON {ok, oauth_expires_at_ms,
//             token_state: "refreshed"|"fresh"} (token_state per the agreed
//             contract — "fresh" = no rotation was needed).
//   list-candidates [--since <ISO>] [--start N] [--count N]
//             — normalised candidate rows for the Postgres `entities` cache
//               upsert (Janitor cycle.sh Step 2 scan)
//   list-contacts [--since <ISO>] [--start N] [--count N]
//   list-clients [--since <ISO>] [--start N] [--count N]
//             — same, for ClientContact / ClientCorporation
//   update-candidate --id <N> --patch <json>
//             — POST /entity/Candidate/{id} (Janitor Step 9 merge/backfill);
//               prints {ok, changed_entity_id}. STATE-CHANGING.
//   update-client --id <N> --patch <json>
//             — POST /entity/ClientCorporation/{id} (Janitor Step 9 client
//               backfill); prints {ok, changed_entity_id}. STATE-CHANGING.
//   update-entity --entity-type Candidate|ClientContact|JobOrder|Placement
//                 --id <N> --patch <json>
//             — generic POST /entity/{EntityType}/{id} per the agreed
//               contract; prints {ok, updated, entity_type, id}.
//               STATE-CHANGING. (update-candidate / update-client stay.)
//   create-note (--person-id <N> | --entity-type <T> --entity-id <N>)
//               (--comments <text> | --body-file <path>) [--title <text>]
//               [--action Note]
//             — PUT /entity/Note (Janitor Step 9 tacit-note attach + Scribe
//               post-call note); prints {ok, note_id}. STATE-CHANGING.
//               --title (optional) is prepended as the first line of the
//               note body (Bullhorn Note has no subject field — honest
//               mapping, documented). Entity targeting: Bullhorn's Note API
//               attaches via personReference (Person = Candidate |
//               ClientContact). Any other --entity-type returns an explicit
//               {ok:false, reason:"unsupported_entity"} — NEVER faked;
//               callers fall back to person resolution per the contract.
//
// PATH A: client_id/secret via process.env (caller sources _secrets.env); the
// corporation_id + region from env (BULLHORN_SANDBOX_* dev names, BULLHORN_*
// overrides); tokens from the vault bundle on disk. JSON status on stdout,
// NEVER a token value. Errors -> {ok:false,error}, exit 1; structured
// refusals -> {ok:false, reason:...}, exit 1.
//
// Config from env + on-disk bundle (bootstrap consent flow is founder-gated —
// Bullhorn dev creds pending per spec-001 §8; this CLI is the wired surface
// that goes live when creds land):
//   BULLHORN_CLIENT_ID / BULLHORN_CLIENT_SECRET            (env)
//   BULLHORN_CORPORATION_ID | BULLHORN_SANDBOX_CORPORATION_ID  (env)
//   BULLHORN_REGION | BULLHORN_SANDBOX_REGION (east|west|uk; default uk)
//   <token_dir>/bullhorn-tokens-<corporation_id>.json      (BullhornTokens)
//   token_dir = IFOS_TOKEN_DIR | ~/.ifos-local-vault/dev-sandbox
//   (IFOS_TOKEN_DIR override is the per-tenant token-path mechanism per the
//    agreed contract.)

import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import { loadTokens, refreshTokens, shouldRefresh } from "./auth.js";
import { BullhornClient as BullhornTransport } from "./client.js";
import { listCandidates, updateCandidate } from "./candidates.js";
import { listContacts } from "./contacts.js";
import { listClients, updateClient } from "./clients.js";
import { createNote } from "./notes.js";
import type {
  BullhornCandidate,
  BullhornClient as BullhornClientCorp,
  BullhornContact,
  BullhornOAuthConfig,
  BullhornRegion,
} from "./types.js";

/**
 * Structured CLI failure — carries the exact JSON payload the entry point
 * prints to stdout before exit 1. Plain errors map to {ok:false, error};
 * structured refusals (e.g. unsupported_entity) carry their own shape.
 */
export class CliFailure extends Error {
  readonly payload: Record<string, unknown>;
  constructor(payload: Record<string, unknown>) {
    super(String(payload.error ?? payload.reason ?? "cli failure"));
    this.payload = payload;
  }
}

function fail(error: string): never {
  throw new CliFailure({ ok: false, error });
}

/** Minimal --flag <value> parser over argv slice. */
function parseFlags(argv: string[]): Record<string, string> {
  const flags: Record<string, string> = {};
  for (let i = 0; i < argv.length; i += 1) {
    const tok = argv[i];
    if (tok?.startsWith("--")) {
      flags[tok.slice(2)] = argv[i + 1] ?? "";
      i += 1;
    }
  }
  return flags;
}

function tokenDir(): string {
  return (
    process.env.IFOS_TOKEN_DIR ?? join(homedir(), ".ifos-local-vault", "dev-sandbox")
  );
}

function resolveRegion(): BullhornRegion {
  const raw = (
    process.env.BULLHORN_REGION ??
    process.env.BULLHORN_SANDBOX_REGION ??
    "uk"
  ).toLowerCase();
  if (raw === "east" || raw === "west" || raw === "uk") return raw;
  return "uk";
}

function buildConfig(): BullhornOAuthConfig {
  const client_id = process.env.BULLHORN_CLIENT_ID;
  const client_secret = process.env.BULLHORN_CLIENT_SECRET;
  if (!client_id || !client_secret) {
    fail("BULLHORN_CLIENT_ID / BULLHORN_CLIENT_SECRET not in env (source _secrets.env; founder-gated)");
  }
  const corporation_id =
    process.env.BULLHORN_CORPORATION_ID ??
    process.env.BULLHORN_SANDBOX_CORPORATION_ID ??
    "";
  if (!corporation_id) {
    fail("BULLHORN_CORPORATION_ID / BULLHORN_SANDBOX_CORPORATION_ID not in env");
  }
  return {
    client_id,
    client_secret,
    corporation_id,
    region: resolveRegion(),
    token_file_path: join(tokenDir(), `bullhorn-tokens-${corporation_id}.json`),
  };
}

/** Bullhorn epoch-ms timestamp → ISO string ('' when absent). */
function toIso(ms: number | null | undefined): string {
  return typeof ms === "number" && Number.isFinite(ms)
    ? new Date(ms).toISOString()
    : "";
}

/** Lucene-style dateLastModified range filter for --since. */
function sinceQuery(sinceIso: string | undefined): string {
  if (!sinceIso) return "isDeleted:false";
  const ms = Date.parse(sinceIso);
  if (!Number.isFinite(ms)) fail(`--since is not a parseable timestamp: '${sinceIso}'`);
  return `isDeleted:false AND dateLastModified:[${ms} TO *]`;
}

/** Parse a required positive-integer id flag. */
function parseId(raw: string | undefined, label: string): number {
  const id = Number(raw);
  if (!Number.isFinite(id) || id <= 0 || !Number.isInteger(id)) {
    fail(`${label} requires a positive numeric bullhorn id (got '${raw ?? ""}')`);
  }
  return id;
}

// Normalisers — unified rows for the Postgres `entities` cache upsert
// (cycle.sh Step 2 INSERTs these generically; data jsonb carries the shape
// the Steps 3-6 jq pipelines consume).
function normCandidate(c: BullhornCandidate & { phone?: string | null; mobile?: string | null }) {
  return {
    entity_type: "candidate",
    entity_id: String(c.id),
    data: {
      bullhorn_id: c.id,
      name: [c.firstName ?? "", c.lastName ?? ""].join(" ").trim(),
      first_name: c.firstName ?? "",
      last_name: c.lastName ?? "",
      email: c.email ?? c.email2 ?? c.email3 ?? "",
      phone: c.phone ?? c.mobile ?? "",
      status: c.status ?? "",
      occupation: c.occupation ?? "",
      date_added: toIso(c.dateAdded),
      date_last_modified: toIso(c.dateLastModified),
    },
  };
}

function normContact(c: BullhornContact & { phone?: string | null }) {
  return {
    entity_type: "contact",
    entity_id: String(c.id),
    data: {
      bullhorn_id: c.id,
      name: [c.firstName ?? "", c.lastName ?? ""].join(" ").trim(),
      email: c.email ?? "",
      phone: c.phone ?? "",
      status: c.status ?? "",
      client_corporation_id: c.clientCorporation?.id ?? null,
      date_last_modified: toIso(c.dateLastModified),
    },
  };
}

function normClient(c: BullhornClientCorp) {
  return {
    entity_type: "client",
    entity_id: String(c.id),
    data: {
      bullhorn_id: c.id,
      name: c.name,
      status: c.status ?? "",
      industry: c.industry ?? null,
      size_employees: c.numEmployees ?? null,
      website: c.website ?? "",
      date_last_modified: toIso(c.dateLastModified),
    },
  };
}

/** update-entity allowed targets per the agreed CLI contract. */
const UPDATE_ENTITY_TYPES = ["Candidate", "ClientContact", "JobOrder", "Placement"] as const;
type UpdateEntityType = (typeof UPDATE_ENTITY_TYPES)[number];

/** Note targets Bullhorn's personReference can actually attach to (Person
 *  subtypes). Anything else → structured unsupported_entity refusal. */
const NOTE_PERSON_ENTITY_TYPES = ["Candidate", "ClientContact"] as const;

/**
 * Core command dispatch — returns the JSON-able result object; throws
 * CliFailure for structured failures and typed Bullhorn errors for transport
 * failures. Exported for vitest (fetchFn injectable; NO live API calls in
 * tests). argv = [command, ...flags].
 */
export async function runCommand(
  argv: string[],
  fetchFn: typeof fetch = fetch,
): Promise<Record<string, unknown>> {
  const command = argv[0];
  const flags = parseFlags(argv.slice(1));

  if (command === "check-auth") {
    // Network-free readiness probe (mirrors @ifos/cv-library check-auth).
    const creds_present = Boolean(
      process.env.BULLHORN_CLIENT_ID && process.env.BULLHORN_CLIENT_SECRET,
    );
    const corporation_id =
      process.env.BULLHORN_CORPORATION_ID ??
      process.env.BULLHORN_SANDBOX_CORPORATION_ID ??
      "";
    let tokens_present = false;
    if (corporation_id) {
      try {
        await fs.access(join(tokenDir(), `bullhorn-tokens-${corporation_id}.json`));
        tokens_present = true;
      } catch {
        tokens_present = false;
      }
    }
    return {
      ok: creds_present && tokens_present,
      creds_present,
      tokens_present,
      corporation_id,
      region: resolveRegion(),
    };
  }

  const config = buildConfig();

  if (command === "refresh") {
    const tokens = await loadTokens(config);
    if (!tokens) {
      fail(
        `no token bundle at ${config.token_file_path} — one-time OAuth consent ` +
          `flow required to bootstrap (founder-gated until Bullhorn creds land)`,
      );
    }
    if (!shouldRefresh(tokens)) {
      // Both tokens comfortably outside the 90s safety window — no rotation
      // needed; report honestly per the agreed contract.
      return {
        ok: true,
        oauth_expires_at_ms: tokens.oauth_expires_at_ms,
        token_state: "fresh",
      };
    }
    const rotated = await refreshTokens(config, tokens, fetchFn);
    return {
      ok: true,
      oauth_expires_at_ms: rotated.oauth_expires_at_ms,
      token_state: "refreshed",
    };
  }

  const transport = new BullhornTransport({ config, fetchFn });
  const start = Number(flags.start ?? "0");
  const count = Number(flags.count ?? "100");

  if (command === "list-candidates") {
    const rows = await listCandidates(transport, {
      query: sinceQuery(flags.since),
      fields:
        "id,firstName,lastName,email,email2,email3,phone,mobile,status,dateAdded,dateLastModified,occupation",
      start,
      count,
      no_cache: true,
    });
    return { ok: true, rows: rows.map(normCandidate) };
  }

  if (command === "list-contacts") {
    const rows = await listContacts(transport, {
      query: sinceQuery(flags.since),
      fields: "id,clientCorporation,firstName,lastName,email,phone,status,dateLastModified",
      start,
      count,
      no_cache: true,
    });
    return { ok: true, rows: rows.map(normContact) };
  }

  if (command === "list-clients") {
    const rows = await listClients(transport, {
      query: sinceQuery(flags.since),
      start,
      count,
      no_cache: true,
    });
    return { ok: true, rows: rows.map(normClient) };
  }

  if (command === "update-candidate" || command === "update-client") {
    const id = parseId(flags.id, command);
    let patch: Record<string, unknown>;
    try {
      patch = JSON.parse(flags.patch ?? "") as Record<string, unknown>;
    } catch {
      fail(`${command} requires --patch <json object>`);
    }
    const res =
      command === "update-candidate"
        ? await updateCandidate(transport, id, patch)
        : await updateClient(transport, id, patch);
    return { ok: true, changed_entity_id: res.changedEntityId };
  }

  if (command === "update-entity") {
    const entityType = flags["entity-type"] ?? "";
    if (!(UPDATE_ENTITY_TYPES as readonly string[]).includes(entityType)) {
      fail(
        `update-entity --entity-type must be one of ${UPDATE_ENTITY_TYPES.join("|")} ` +
          `(got '${entityType}')`,
      );
    }
    const id = parseId(flags.id, "update-entity");
    let patch: Record<string, unknown>;
    try {
      patch = JSON.parse(flags.patch ?? "") as Record<string, unknown>;
    } catch {
      fail("update-entity requires --patch <json object>");
    }
    await transport.request<{
      changedEntityType: string;
      changedEntityId: number;
      changeType: string;
    }>(`/entity/${entityType as UpdateEntityType}/${id}`, {
      method: "POST",
      body: patch,
    });
    return { ok: true, updated: true, entity_type: entityType, id };
  }

  if (command === "create-note") {
    // Target resolution: --person-id OR (--entity-type + --entity-id) per
    // the agreed contract. Bullhorn's Note API targets a Person reference
    // (Candidate | ClientContact); other entity types are an explicit
    // structured refusal — never faked.
    let personId: number;
    if (flags["person-id"] !== undefined) {
      personId = parseId(flags["person-id"], "create-note --person-id");
    } else if (flags["entity-type"] !== undefined || flags["entity-id"] !== undefined) {
      const entityType = flags["entity-type"] ?? "";
      if (!(NOTE_PERSON_ENTITY_TYPES as readonly string[]).includes(entityType)) {
        throw new CliFailure({
          ok: false,
          reason: "unsupported_entity",
          entity_type: entityType,
          detail:
            `Bullhorn Note attaches via personReference (${NOTE_PERSON_ENTITY_TYPES.join("|")}); ` +
            `'${entityType}' cannot be targeted — caller falls back to person resolution`,
        });
      }
      personId = parseId(flags["entity-id"], "create-note --entity-id");
    } else {
      fail("create-note requires --person-id <N> OR (--entity-type <T> --entity-id <N>)");
    }

    // Body resolution: --comments inline OR --body-file path; optional
    // --title prepends as the first line (Bullhorn Note has no subject field).
    let body = flags.comments ?? "";
    if (flags["body-file"] !== undefined) {
      try {
        body = await fs.readFile(flags["body-file"], "utf8");
      } catch {
        fail(`create-note --body-file: cannot read '${flags["body-file"]}'`);
      }
    }
    if (flags.title) {
      body = `${flags.title}\n\n${body}`;
    }
    if (!body.trim()) {
      fail("create-note requires a non-empty --comments <text> or --body-file <path>");
    }

    const res = await createNote(transport, {
      action: flags.action || "Note",
      comments: body,
      personReference: { id: personId },
    });
    return { ok: true, note_id: res.changedEntityId };
  }

  fail(
    `unknown command '${command ?? ""}' (use: check-auth | refresh | list-candidates | ` +
      `list-contacts | list-clients | update-candidate | update-client | update-entity | create-note)`,
  );
}

async function main(): Promise<void> {
  try {
    const out = await runCommand(process.argv.slice(2));
    // list-* commands keep their original bare-array stdout contract
    // (cycle.sh Step 2 pipes the output straight into jsonb_to_recordset).
    if (
      (process.argv[2] === "list-candidates" ||
        process.argv[2] === "list-contacts" ||
        process.argv[2] === "list-clients") &&
      Array.isArray(out.rows)
    ) {
      process.stdout.write(JSON.stringify(out.rows) + "\n");
      return;
    }
    process.stdout.write(JSON.stringify(out) + "\n");
  } catch (e: unknown) {
    const payload =
      e instanceof CliFailure
        ? e.payload
        : { ok: false, error: e instanceof Error ? e.message : String(e) };
    process.stdout.write(JSON.stringify(payload) + "\n");
    process.exit(1);
  }
}

// Run main() only when executed as the entry point (node dist/cli.js …);
// vitest imports runCommand without side effects.
const entryHref = (() => {
  try {
    return pathToFileURL(process.argv[1] ?? "").href;
  } catch {
    return "";
  }
})();
if (import.meta.url === entryHref) {
  void main();
}
