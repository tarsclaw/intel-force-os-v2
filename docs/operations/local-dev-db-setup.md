# Local dev DB setup — for agent live-smoke (Cash Conductor P2+)

**Purpose:** stand up a faithful **local** copy of the IFOS Postgres schema so agent bundles (Cash Conductor reconciliation/ingest, later Scribe/Janitor) can be built and live-smoked **without writing to the production VPS** and **without the 1Password `ifos_app` password.**

**Why this exists (the gate it resolves):** the live `ifos_v2` DB is on the VPS (Hetzner). The agent runtime connects as the RLS-scoped `ifos_app` role (`SET LOCAL app.current_tenant`). The repo's migrations are *incremental* (`v0.1→v0.4`) and do **not** create the base schema, so there's nothing in-repo to build a full DB from. This procedure copies the **schema only** (DDL, no rows, no secrets) from the VPS into a local dev DB.

**Safety:** the setup script (`scripts/setup-local-dev-db.sh`) operates **only on the local Postgres** (refuses a remote `PGHOST`); it never connects to the VPS. The dev `ifos_app` password is local-only (not a secret). It's idempotent (drops + recreates the dev DB on each run).

---

## Step 1 — Founder: get the schema dump (one command, read-only on prod)

```bash
ssh <your-vps> 'sudo -u postgres pg_dump --schema-only ifos_v2' > /tmp/ifos_v2_schema.sql
```
Schema-only = table/role/RLS/trigger DDL, **no row data, no credentials**. Safe to put in `/tmp` and feed to the script.

## Step 2 — Build the local dev DB

```bash
bash scripts/setup-local-dev-db.sh /tmp/ifos_v2_schema.sql
```
The script (idempotent, local-only):
1. confirms you're a local superuser; verifies the dump is a real schema dump;
2. creates a local `ifos_app` role (dev password `ifos_dev_local`, overridable);
3. drops + recreates a local `ifos_v2_dev` database;
4. loads the schema dump; asserts `tenant_adapters` + `decision_log` + `cash_conductor_invoices` + `cash_conductor_transactions` exist;
5. seeds a `dev-sandbox` `tenant_adapters` row (best-effort — if the table needs more NOT-NULL columns it prints `\d tenant_adapters` so you extend the INSERT);
6. **RLS correctness gate** (the load-bearing check, per tenancy-invariants T1-T4): as `ifos_app`, an `INSERT` *without* `SET LOCAL app.current_tenant` must be **rejected** by row-level security. PASS = isolation enforced; a WARNING here means RLS isn't active — investigate before trusting any writes;
7. prints the `IFOS_DB_URL` to export.

## Step 3 — Point the agent at it

```bash
export IFOS_DB_URL="postgresql://ifos_app:ifos_dev_local@localhost:5432/ifos_v2_dev"
# sanity: the agent's RLS-scoped read works
psql "$IFOS_DB_URL" -c "BEGIN; SET LOCAL app.current_tenant='dev-sandbox'; SELECT count(*) FROM tenant_adapters; COMMIT;"
```
With `IFOS_DB_URL` set, `hook-helpers.sh` switches from offline-JSONL mode to live Postgres, and the Cash Conductor cycle.sh ingest (Steps 3-4) writes to the local `cash_conductor_*` tables under RLS.

---

## Notes / gotchas

- **`tenant_adapters` config-key allowlist:** if a step needs to SET `config->>'accounting_provider'`/`'open_banking_provider'`, the v0.4 allowlist trigger may reject unallowlisted keys — context.sh falls back to `xero`/`truelayer` defaults, so the dev-sandbox row does **not** need those keys set. (Schema-before-code: don't write unallowlisted config keys.)
- **Connection ids** (Xero tenant id, TrueLayer account id) are read by the connector CLIs from the on-disk token companions (`xero-tenant.json`, `ob-account.json`) — they don't need to be in `tenant_adapters`.
- **Refresh the schema** anytime prod migrates: re-run Step 1 + Step 2 (idempotent).
- **Never** point this script at a remote `PGHOST` — it's a local-dev tool by design.

*Companion to the W7 Cash Conductor build (`agents/recruitment/cash-conductor/agent.md` §4 + §8) and `scripts/run-tenancy-audit.sh` (the RLS pattern this mirrors).*
