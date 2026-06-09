// @ifos/quickbooks CLI — thin bash↔TS bridge for the Cash Conductor agent bundle
// (cycle.sh invokes `node dist/cli.js <command>`; mirrors diagnostic-generator).
//
// Commands:
//   refresh — load tokens from disk, rotate via refreshTokens, persist;
//             print JSON {ok, expires_at_ms, refresh_token_expires_at_ms}
//   list-open-invoices — normalised open-invoice rows for cash_conductor_invoices ingest
//   write-payment --invoice <id> --amount <n> --customer <ref> [--date <ISO>] [--reference <ref>]
//             — applies a payment-received against an invoice (Cash Conductor
//               §4 Step 6 reconciliation write); prints JSON {ok, payment_id}.
//               QB requires the CustomerRef the invoice belongs to (--customer);
//               cycle.sh Step 6 passes the invoice's client_contact_id. STATE-
//               CHANGING — only ever run against the sandbox for a Stage 1-2 match.
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
import { buildPaymentWriteRequest, writePaymentReceived } from "./payments.js";
import type { QbOAuthConfig } from "./index.js";

function fail(error: string): never {
  process.stdout.write(JSON.stringify({ ok: false, error }) + "\n");
  process.exit(1);
}

/** Minimal --flag <value> parser over argv[3..]. */
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
    // Normalise to the unified cash_conductor_invoices ingest shape (cycle.sh
    // Step 4 INSERTs this generically across providers). QB Balance = amount
    // outstanding, so amount_paid = TotalAmt - Balance.
    const rows = invoices.map((inv) => ({
      invoice_id: inv.Id,
      invoice_number: inv.DocNumber,
      issued_at: inv.TxnDate,
      due_at: inv.DueDate,
      amount_total: inv.TotalAmt,
      amount_paid: inv.TotalAmt - inv.Balance,
      currency: inv.CurrencyRef.value,
      status: inv.Balance > 0 ? "open" : "paid",
      client_contact_id: inv.CustomerRef.value,
      raw: inv,
    }));
    process.stdout.write(JSON.stringify(rows) + "\n");
    return;
  }

  if (command === "write-payment") {
    const flags = parseFlags(process.argv.slice(3));
    const invoice = flags.invoice;
    const customer = flags.customer;
    const amount = Number(flags.amount);
    if (!invoice || !customer) {
      fail("write-payment requires --invoice and --customer");
    }
    if (!Number.isFinite(amount) || amount <= 0) {
      fail(`write-payment --amount must be a positive number (got '${flags.amount ?? ""}')`);
    }
    const client = new QbClient({ config });
    const payment = await writePaymentReceived(
      client,
      buildPaymentWriteRequest({
        invoice,
        amount,
        customer,
        date: flags.date,
        reference: flags.reference,
      }),
    );
    process.stdout.write(JSON.stringify({ ok: true, payment_id: payment.Id }) + "\n");
    return;
  }

  fail(`unknown command '${command ?? ""}' (use: refresh | list-open-invoices | write-payment)`);
}

main().catch((e: unknown) => fail(e instanceof Error ? e.message : String(e)));
