// @ifos/bullhorn CLI — thin bash↔TS bridge for the Janitor agent bundle
// (cycle.sh invokes `node dist/cli.js <command>`; mirrors @ifos/xero +
// @ifos/quickbooks + @ifos/cv-library connector-CLI pattern).
//
// Commands:
//   check-auth — NETWORK-FREE: reports whether creds are in env + whether a
//             token bundle exists on disk; print JSON {ok, creds_present,
//             tokens_present, corporation_id, region}. ok=true only when both
//             creds AND tokens are present (a refresh could succeed).
//   refresh — load tokens from disk, rotate via the two-step refreshTokens
//             (Step A OAuth + Step B REST login per src/auth.ts), persist;
//             print JSON {ok, oauth_expires_at_ms}
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
//   create-note --person-id <N> --comments <text> [--action Note]
//             — PUT /entity/Note (Janitor Step 9 tacit-note attach);
//               prints {ok, note_id}. STATE-CHANGING.
//
// PATH A: client_id/secret via process.env (caller sources _secrets.env); the
// corporation_id + region from env (BULLHORN_SANDBOX_* dev names, BULLHORN_*
// overrides); tokens from the vault bundle on disk. JSON status on stdout,
// NEVER a token value. Errors -> {ok:false,error}, exit 1.
//
// Config from env + on-disk bundle (bootstrap consent flow is founder-gated —
// Bullhorn dev creds pending per spec-001 §8; this CLI is the wired surface
// that goes live when creds land):
//   BULLHORN_CLIENT_ID / BULLHORN_CLIENT_SECRET            (env)
//   BULLHORN_CORPORATION_ID | BULLHORN_SANDBOX_CORPORATION_ID  (env)
//   BULLHORN_REGION | BULLHORN_SANDBOX_REGION (east|west|uk; default uk)
//   <token_dir>/bullhorn-tokens-<corporation_id>.json      (BullhornTokens)
//   token_dir = IFOS_TOKEN_DIR | ~/.ifos-local-vault/dev-sandbox

import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { loadTokens, refreshTokens } from "./auth.js";
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

function fail(error: string): never {
  process.stdout.write(JSON.stringify({ ok: false, error }) + "\n");
  process.exit(1);
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

async function main(): Promise<void> {
  const command = process.argv[2];
  const flags = parseFlags(process.argv.slice(3));

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
    process.stdout.write(
      JSON.stringify({
        ok: creds_present && tokens_present,
        creds_present,
        tokens_present,
        corporation_id,
        region: resolveRegion(),
      }) + "\n",
    );
    return;
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
    const rotated = await refreshTokens(config, tokens);
    process.stdout.write(
      JSON.stringify({ ok: true, oauth_expires_at_ms: rotated.oauth_expires_at_ms }) + "\n",
    );
    return;
  }

  const transport = new BullhornTransport({ config });
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
    process.stdout.write(JSON.stringify(rows.map(normCandidate)) + "\n");
    return;
  }

  if (command === "list-contacts") {
    const rows = await listContacts(transport, {
      query: sinceQuery(flags.since),
      fields: "id,clientCorporation,firstName,lastName,email,phone,status,dateLastModified",
      start,
      count,
      no_cache: true,
    });
    process.stdout.write(JSON.stringify(rows.map(normContact)) + "\n");
    return;
  }

  if (command === "list-clients") {
    const rows = await listClients(transport, {
      query: sinceQuery(flags.since),
      start,
      count,
      no_cache: true,
    });
    process.stdout.write(JSON.stringify(rows.map(normClient)) + "\n");
    return;
  }

  if (command === "update-candidate" || command === "update-client") {
    const id = Number(flags.id);
    if (!Number.isFinite(id) || id <= 0) {
      fail(`${command} requires --id <positive bullhorn id> (got '${flags.id ?? ""}')`);
    }
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
    process.stdout.write(
      JSON.stringify({ ok: true, changed_entity_id: res.changedEntityId }) + "\n",
    );
    return;
  }

  if (command === "create-note") {
    const personId = Number(flags["person-id"]);
    const comments = flags.comments ?? "";
    if (!Number.isFinite(personId) || personId <= 0 || !comments) {
      fail("create-note requires --person-id <positive id> and --comments <text>");
    }
    const res = await createNote(transport, {
      action: flags.action || "Note",
      comments,
      personReference: { id: personId },
    });
    process.stdout.write(JSON.stringify({ ok: true, note_id: res.changedEntityId }) + "\n");
    return;
  }

  fail(
    `unknown command '${command ?? ""}' (use: check-auth | refresh | list-candidates | ` +
      `list-contacts | list-clients | update-candidate | update-client | create-note)`,
  );
}

main().catch((e: unknown) => fail(e instanceof Error ? e.message : String(e)));
