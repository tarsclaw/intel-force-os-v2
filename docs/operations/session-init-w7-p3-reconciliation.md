# Session init — W7 Cash Conductor P3 (reconciliation)

**Give this file to a fresh session to pick up exactly where we left off.** Read it after the normal CLAUDE.md session-start ritual, then fire the P3 `/goal` (bottom of this file).

_Written 2026-06-09. Last commit: `f444b34` (pushed to origin/main)._

---

## Where we are

**Cash Conductor agent — P0/P1/P2 DONE + live-verified.** cycle.sh steps **0,1,2,3,4 are LIVE**; steps 5-14 are still `TODO(W7-8)`.

- **P0** — local dev DB harness + context.sh live tenant config.
- **P1** — connector CLI bins: `refresh`, `token-stage`, `list-transactions`, `list-open-invoices` (normalised).
- **P2** — cycle.sh Step 3 bank ingest + Step 4 invoice ingest, both bulk-UPSERT under RLS.

**Next = P3: reconciliation (Steps 5-6)** — the 5-stage match + `writePaymentReceived`. agent.md §3 Output 1 + §4 Steps 5-6.

## The live local DB (already built — persists across sessions)

```bash
export IFOS_DB_URL="postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev"
# verify it's up + see the test data already ingested:
psql "$IFOS_DB_URL" -c "BEGIN; SET LOCAL app.current_tenant='dev-sandbox';
  SELECT (SELECT count(*) FROM cash_conductor_transactions) AS txns,
         (SELECT count(*) FROM cash_conductor_invoices)    AS invoices; COMMIT;"
# expect ~435 txns + 20 invoices (real Mock-Bank + QB-sandbox data — perfect recon fixtures)
```
If the DB is gone (e.g. machine reset): re-run `bash scripts/setup-local-dev-db.sh /tmp/ifos_v2_schema.sql`. If the dump is gone, re-pull it (read-only, from the prod VPS): `ssh -i ~/.ssh/ifos_hetzner_ed25519 maddox@178.105.87.24 'sudo -u postgres pg_dump --schema-only ifos_v2' > /tmp/ifos_v2_schema.sql`. Full method: `docs/operations/local-dev-db-setup.md`.

## How to smoke the agent

```bash
export IFOS_DB_URL="postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev"
set -a; . ~/.ifos-local-vault/dev-sandbox/_secrets.env; set +a   # Path A — source, NEVER cat
CTX_AGENT_DIR="$PWD/agents/recruitment/cash-conductor" CTX_TENANT_SLUG="dev-sandbox" \
  CTX_ACCOUNTING_PROVIDER="quickbooks" IFOS_REPO_ROOT="$PWD" \
  bash agents/recruitment/cash-conductor/cycle.sh --mode manual
```
- `IFOS_DB_URL` set → `hh_decision_*` writes to Postgres (live mode); unset → JSONL fallback (offline).
- The connector CLIs are `node packages/mcp-connectors/<pkg>/dist/cli.js <cmd>` (build with `pnpm --filter @ifos/<pkg> build`).

## Gotchas (will bite a fresh session)

- **agent_name is `cash-conductor` (hyphen)** in decision_log rows, not `cash_conductor` — query accordingly.
- **Default `CTX_ACCOUNTING_PROVIDER=xero`, but the Xero sandbox org is EMPTY (0 invoices).** Use `quickbooks` (20 invoices) to exercise the invoice/recon path.
- **Every DB statement is RLS-scoped** — wrap in `BEGIN; SET LOCAL app.current_tenant='<slug>'; …; COMMIT;` or rows are invisible / writes rejected.
- **Path A** — creds via `process.env` / on-disk tokens; NEVER `cat`/`Read` `*_secrets`/`*.env`/`*token*`. The connector CLIs read tokens from `~/.ifos-local-vault/dev-sandbox/`.
- `writePaymentReceived(client, payment)` is exported from `@ifos/xero` + `@ifos/quickbooks` (`./payments.js`) — Step 6 needs a CLI command wrapping it (mirror the `refresh`/`list-*` pattern).

## Then fire the P3 /goal

`/goal ` + the `w7-cash-conductor-p3-reconciliation` block (provided alongside this file). It STOPs on context decay and re-fires to continue — P3 is the hard match logic, so expect 1-2 sessions.
