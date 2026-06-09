// @ifos/xero CLI — thin bash↔TS bridge for the Cash Conductor agent bundle
// (cycle.sh invokes `node dist/cli.js <command>`; mirrors diagnostic-generator).
//
// Commands:
//   refresh — load tokens from disk, rotate via refreshTokens, persist;
//             print JSON {ok, expires_at_ms}
//   list-open-invoices — normalised open-invoice rows for cash_conductor_invoices ingest
//   write-payment --invoice <id> --amount <n> --date <ISO> --account <code> [--reference <ref>]
//             — applies a payment-received against an invoice (Cash Conductor
//               §4 Step 6 reconciliation write); prints JSON {ok, payment_id}.
//               Xero requires the bank GL Account code; supply --account or set
//               XERO_PAYMENT_ACCOUNT_CODE. STATE-CHANGING — only ever run against
//               the sandbox for a confirmed Stage 1-2 match.
//
// PATH A: client_id/secret via process.env (caller sources _secrets.env); the
// Xero connection tenant_id from xero-tenant.json; tokens from the vault file.
// JSON status on stdout, never a token value. Errors -> {ok:false,error}, exit 1.
//
// Config from env + on-disk bundle written by scripts/bootstrap-xero-oauth.sh:
//   XERO_CLIENT_ID / XERO_CLIENT_SECRET    (env)
//   <token_dir>/xero-tokens.json           (XeroTokens)
//   <token_dir>/xero-tenant.json           ({tenant_id})
//   token_dir = IFOS_TOKEN_DIR | ~/.ifos-local-vault/dev-sandbox

import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { loadTokens, refreshTokens, listOpenInvoices } from "./index.js";
import { XeroClient } from "./client.js";
import { buildPaymentWriteRequest, writePaymentReceived } from "./payments.js";
import type { XeroOAuthConfig } from "./index.js";

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

async function buildConfig(): Promise<XeroOAuthConfig> {
  const client_id = process.env.XERO_CLIENT_ID;
  const client_secret = process.env.XERO_CLIENT_SECRET;
  if (!client_id || !client_secret) {
    fail("XERO_CLIENT_ID / XERO_CLIENT_SECRET not in env (source _secrets.env)");
  }
  const token_dir =
    process.env.IFOS_TOKEN_DIR ??
    join(homedir(), ".ifos-local-vault", "dev-sandbox");
  let tenant_id: string;
  try {
    const raw = await fs.readFile(join(token_dir, "xero-tenant.json"), "utf8");
    tenant_id = (JSON.parse(raw) as { tenant_id: string }).tenant_id;
  } catch {
    return fail(`no xero-tenant.json in ${token_dir} — run scripts/bootstrap-xero-oauth.sh`);
  }
  return {
    client_id,
    client_secret,
    tenant_id,
    token_file_path: join(token_dir, "xero-tokens.json"),
  };
}

async function main(): Promise<void> {
  const command = process.argv[2];
  const config = await buildConfig();
  const tokens = await loadTokens(config);
  if (!tokens) {
    fail(`no tokens at ${config.token_file_path} — run scripts/bootstrap-xero-oauth.sh`);
  }

  if (command === "refresh") {
    const rotated = await refreshTokens(config, tokens);
    process.stdout.write(
      JSON.stringify({ ok: true, expires_at_ms: rotated.expires_at_ms }) + "\n",
    );
    return;
  }

  if (command === "list-open-invoices") {
    const client = new XeroClient({ config });
    const invoices = await listOpenInvoices(client, { no_cache: true });
    // Normalise to the unified cash_conductor_invoices ingest shape (cycle.sh
    // Step 4 INSERTs this generically across providers).
    const rows = invoices.map((inv) => ({
      invoice_id: inv.InvoiceID,
      invoice_number: inv.InvoiceNumber,
      issued_at: inv.Date,
      due_at: inv.DueDate,
      amount_total: inv.Total,
      amount_paid: inv.AmountPaid,
      currency: inv.CurrencyCode,
      status: inv.AmountDue > 0 ? "open" : "paid",
      client_contact_id: inv.Contact.ContactID,
      raw: inv,
    }));
    process.stdout.write(JSON.stringify(rows) + "\n");
    return;
  }

  if (command === "write-payment") {
    const flags = parseFlags(process.argv.slice(3));
    const invoice = flags.invoice;
    const date = flags.date;
    const account = flags.account ?? process.env.XERO_PAYMENT_ACCOUNT_CODE ?? "";
    const amount = Number(flags.amount);
    if (!invoice || !date || !account) {
      fail("write-payment requires --invoice, --date and --account (or XERO_PAYMENT_ACCOUNT_CODE)");
    }
    if (!Number.isFinite(amount) || amount <= 0) {
      fail(`write-payment --amount must be a positive number (got '${flags.amount ?? ""}')`);
    }
    const client = new XeroClient({ config });
    const payment = await writePaymentReceived(
      client,
      buildPaymentWriteRequest({ invoice, amount, date, account, reference: flags.reference }),
    );
    process.stdout.write(JSON.stringify({ ok: true, payment_id: payment.PaymentID }) + "\n");
    return;
  }

  fail(`unknown command '${command ?? ""}' (use: refresh | list-open-invoices | write-payment)`);
}

main().catch((e: unknown) => fail(e instanceof Error ? e.message : String(e)));
