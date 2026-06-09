// @ifos/quickbooks CLI — thin bash↔TS bridge for the Cash Conductor agent bundle
// (cycle.sh invokes `node dist/cli.js <command>`; mirrors diagnostic-generator).
//
// Commands:
//   refresh — load tokens from disk, rotate via refreshTokens, persist;
//             print JSON {ok, expires_at_ms, refresh_token_expires_at_ms}
//
// PATH A: client_id/secret + realm via process.env (caller sources
// _secrets.env); tokens from the vault file. JSON status on stdout, never a
// token value. Errors -> {ok:false,error}, exit 1.
//
// Config from env + on-disk bundle written by scripts/bootstrap-qb-oauth.sh:
//   QB_CLIENT_ID / QB_CLIENT_SECRET / QB_SANDBOX_REALM_ID   (env)
//   <token_dir>/qb-tokens.json                              (QbTokens)
//   token_dir = IFOS_TOKEN_DIR | ~/.ifos-local-vault/dev-sandbox

import { homedir } from "node:os";
import { join } from "node:path";
import { loadTokens, refreshTokens, listOpenInvoices } from "./index.js";
import { QbClient } from "./client.js";
import type { QbOAuthConfig } from "./index.js";

function fail(error: string): never {
  process.stdout.write(JSON.stringify({ ok: false, error }) + "\n");
  process.exit(1);
}

function buildConfig(): QbOAuthConfig {
  const client_id = process.env.QB_CLIENT_ID;
  const client_secret = process.env.QB_CLIENT_SECRET;
  const realm_id = process.env.QB_SANDBOX_REALM_ID;
  if (!client_id || !client_secret || !realm_id) {
    fail("QB_CLIENT_ID / QB_CLIENT_SECRET / QB_SANDBOX_REALM_ID not in env (source _secrets.env)");
  }
  const token_dir =
    process.env.IFOS_TOKEN_DIR ??
    join(homedir(), ".ifos-local-vault", "dev-sandbox");
  return {
    client_id,
    client_secret,
    realm_id,
    environment: "sandbox",
    token_file_path: join(token_dir, "qb-tokens.json"),
  };
}

async function main(): Promise<void> {
  const command = process.argv[2];
  const config = buildConfig();
  const tokens = await loadTokens(config);
  if (!tokens) {
    fail(`no tokens at ${config.token_file_path} — run scripts/bootstrap-qb-oauth.sh`);
  }

  if (command === "refresh") {
    const rotated = await refreshTokens(config, tokens);
    process.stdout.write(
      JSON.stringify({
        ok: true,
        expires_at_ms: rotated.expires_at_ms,
        refresh_token_expires_at_ms: rotated.refresh_token_expires_at_ms,
      }) + "\n",
    );
    return;
  }

  if (command === "list-open-invoices") {
    const client = new QbClient({ config });
    const invoices = await listOpenInvoices(client, { no_cache: true });
    process.stdout.write(JSON.stringify(invoices) + "\n");
    return;
  }

  fail(`unknown command '${command ?? ""}' (use: refresh | list-open-invoices)`);
}

main().catch((e: unknown) => fail(e instanceof Error ? e.message : String(e)));
