// @ifos/open-banking CLI — thin bash↔TS bridge for the Cash Conductor agent
// bundle (agents/recruitment/cash-conductor/cycle.sh invokes `node dist/cli.js
// <command>`, mirroring the diagnostic-generator CLI pattern).
//
// Commands:
//   refresh       — load tokens from disk, rotate via refreshTokens, persist;
//                   print JSON {ok, expires_at_ms, consent_expires_at_ms, stage}
//   token-stage   — print JSON {stage, days_until_consent_expiry} (PSD2 ageing)
//
// PATH A: client_id/secret are read from process.env (the caller sources
// _secrets.env); tokens come from the vault file. No credential value is printed
// — only safe status fields. Output is a single JSON line on stdout so bash can
// parse it with jq; errors print JSON {ok:false,error} and exit non-zero.
//
// Config is assembled from env + the on-disk token bundle written by
// scripts/bootstrap-ob-oauth.sh:
//   TRUELAYER_CLIENT_ID / TRUELAYER_CLIENT_SECRET   (env)
//   <token_dir>/ob-tokens.json                       (OpenBankingTokens)
//   <token_dir>/ob-account.json                      ({connection_id})
//   token_dir = IFOS_TOKEN_DIR | ~/.ifos-local-vault/dev-sandbox

import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import {
  loadTokens,
  refreshTokens,
  getTokenAgeStage,
  listTransactionsSince,
} from "./index.js";
import { OpenBankingClient } from "./client.js";
import type { OpenBankingConfig } from "./index.js";

function fail(error: string): never {
  process.stdout.write(JSON.stringify({ ok: false, error }) + "\n");
  process.exit(1);
}

async function buildConfig(): Promise<OpenBankingConfig> {
  const client_id = process.env.TRUELAYER_CLIENT_ID;
  const client_secret = process.env.TRUELAYER_CLIENT_SECRET;
  if (!client_id || !client_secret) {
    fail("TRUELAYER_CLIENT_ID / TRUELAYER_CLIENT_SECRET not in env (source _secrets.env)");
  }
  const token_dir =
    process.env.IFOS_TOKEN_DIR ??
    join(homedir(), ".ifos-local-vault", "dev-sandbox");
  let connection_id: string;
  try {
    const raw = await fs.readFile(join(token_dir, "ob-account.json"), "utf8");
    connection_id = (JSON.parse(raw) as { connection_id: string }).connection_id;
  } catch {
    return fail(`no ob-account.json in ${token_dir} — run scripts/bootstrap-ob-oauth.sh`);
  }
  return {
    provider: "truelayer",
    client_id,
    client_secret,
    connection_id,
    environment: "sandbox",
    token_file_path: join(token_dir, "ob-tokens.json"),
  };
}

async function main(): Promise<void> {
  const command = process.argv[2];
  const config = await buildConfig();
  const tokens = await loadTokens(config);
  if (!tokens) {
    fail(`no tokens at ${config.token_file_path} — run scripts/bootstrap-ob-oauth.sh`);
  }

  if (command === "token-stage") {
    const report = getTokenAgeStage(tokens);
    process.stdout.write(
      JSON.stringify({
        ok: true,
        stage: report.stage,
        days_until_consent_expiry: Math.floor(report.days_until_consent_expiry),
      }) + "\n",
    );
    return;
  }

  if (command === "refresh") {
    const stageBefore = getTokenAgeStage(tokens);
    if (stageBefore.stage === "blocking") {
      fail("PSD2 consent in blocking stage (<=7d) — operator must re-consent before refresh");
    }
    const rotated = await refreshTokens(config, tokens);
    process.stdout.write(
      JSON.stringify({
        ok: true,
        expires_at_ms: rotated.expires_at_ms,
        consent_expires_at_ms: rotated.consent_expires_at_ms,
        stage: getTokenAgeStage(rotated).stage,
      }) + "\n",
    );
    return;
  }

  if (command === "list-transactions") {
    const i = process.argv.indexOf("--since");
    const since =
      i > -1 && process.argv[i + 1]
        ? (process.argv[i + 1] as string)
        : new Date(Date.now() - 89 * 24 * 60 * 60 * 1000).toISOString();
    const client = new OpenBankingClient({ config });
    const txns = await listTransactionsSince(client, config, { since, no_cache: true });
    process.stdout.write(JSON.stringify(txns) + "\n");
    return;
  }

  fail(`unknown command '${command ?? ""}' (use: refresh | token-stage | list-transactions --since <ISO>)`);
}

main().catch((e: unknown) => fail(e instanceof Error ? e.message : String(e)));
