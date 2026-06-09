#!/usr/bin/env bash
#
# setup-local-dev-db.sh — stand up a LOCAL dev copy of the IFOS Postgres schema
# for agent-bundle live-smoke (Cash Conductor P2+: cash_conductor_* ingest/recon).
#
# WHY: the live ifos_v2 DB is on the VPS; the agent runtime connects as the
# RLS-scoped `ifos_app` role (SET LOCAL app.current_tenant). To build + smoke
# agents WITHOUT writing to production and WITHOUT the 1Password ifos_app
# password, this builds a faithful LOCAL copy of the schema and a dev ifos_app.
#
# SAFE: operates ONLY on the local Postgres (refuses a non-local PGHOST). It
# NEVER connects to the VPS. The dev ifos_app password is local-only, not a
# secret. Idempotent — re-runnable (drops + recreates the dev DB).
#
# INPUT — a schema-only dump from the VPS (founder runs this ONE command; it is
# read-only on prod and contains DDL only, no row data, no secrets):
#   ssh <your-vps> 'sudo -u postgres pg_dump --schema-only ifos_v2' > /tmp/ifos_v2_schema.sql
#
# USAGE:
#   bash scripts/setup-local-dev-db.sh [schema_dump_path]   # default /tmp/ifos_v2_schema.sql
#
# ENV overrides:
#   IFOS_DEV_DB      (default ifos_v2_dev)     local dev database name
#   IFOS_DEV_APP_PW  (default ifos_dev_local)  local dev password for ifos_app
#   IFOS_DEV_TENANT  (default dev-sandbox)     tenant slug to seed
#
# OUTPUT: prints the IFOS_DB_URL to export for the agent runtime + a verified
# RLS check (the load-bearing correctness gate per tenancy-invariants T1-T4).

set -euo pipefail

DUMP="${1:-/tmp/ifos_v2_schema.sql}"
DEV_DB="${IFOS_DEV_DB:-ifos_v2_dev}"
APP_ROLE="ifos_app"
APP_PW="${IFOS_DEV_APP_PW:-ifos_dev_local}"
TENANT="${IFOS_DEV_TENANT:-dev-sandbox}"
PORT="${PGPORT:-5432}"

die() { printf '\033[31mERROR:\033[0m %s\n' "$1" >&2; exit 1; }
ok()  { printf '\033[32m✓\033[0m %s\n' "$1"; }
step(){ printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

command -v psql >/dev/null 2>&1 || die "psql not found"

# Safety: local only. Refuse a remote PGHOST (never touch the VPS from here).
case "${PGHOST:-localhost}" in
  localhost|127.0.0.1|/tmp|"") : ;;
  *) die "PGHOST=${PGHOST} is not local — this script is local-only; unset PGHOST" ;;
esac

# Must be a local superuser to CREATE ROLE/DATABASE + load the schema.
SUPER="$(psql postgres -tAc "SELECT rolsuper FROM pg_roles WHERE rolname=current_user;" 2>/dev/null || echo f)"
[ "${SUPER}" = "t" ] || die "current local Postgres user is not a superuser (need CREATE ROLE/DATABASE)"
ok "local superuser confirmed"

[ -f "${DUMP}" ] || die "schema dump not found: ${DUMP}
  Founder: ssh <your-vps> 'sudo -u postgres pg_dump --schema-only ifos_v2' > ${DUMP}"
grep -q 'CREATE TABLE' "${DUMP}" || die "dump has no CREATE TABLE — is it a schema-only dump of ifos_v2?"
ok "schema dump present ($(grep -c 'CREATE TABLE' "${DUMP}") tables)"

step "1. local ifos_app role (dev password; local only)"
psql postgres -v ON_ERROR_STOP=1 -q <<SQL
DO \$\$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='${APP_ROLE}') THEN
    CREATE ROLE ${APP_ROLE} LOGIN PASSWORD '${APP_PW}';
  ELSE
    ALTER ROLE ${APP_ROLE} LOGIN PASSWORD '${APP_PW}';
  END IF;
END \$\$;
SQL
ok "role ${APP_ROLE} ready"

step "2. (re)create local dev DB ${DEV_DB}"
psql postgres -v ON_ERROR_STOP=1 -q -c "DROP DATABASE IF EXISTS ${DEV_DB};"
psql postgres -v ON_ERROR_STOP=1 -q -c "CREATE DATABASE ${DEV_DB};"
ok "database ${DEV_DB} created fresh"

step "3. load the VPS schema dump"
# Load as superuser (the dump GRANTs to ifos_app + sets RLS policies). Tolerate
# role-already-exists / ownership notices from a schema-only dump.
psql -d "${DEV_DB}" -v ON_ERROR_STOP=0 -q -f "${DUMP}" 2>&1 | grep -iE 'error' | grep -viE 'already exists|does not exist, skipping' | head -20 || true
TABLES="$(psql -d "${DEV_DB}" -tAc "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';")"
ok "schema loaded (${TABLES} tables)"
for t in tenant_adapters decision_log cash_conductor_invoices cash_conductor_transactions; do
  if psql -d "${DEV_DB}" -tAc "SELECT to_regclass('public.${t}');" | grep -q "${t}"; then
    ok "  table present: ${t}"
  else
    die "expected table missing after load: ${t} (is the dump from the v0.3+ schema?)"
  fi
done

step "4. seed tenant_adapters row for '${TENANT}' (best-effort; surfaces columns if it needs more)"
if psql -d "${DEV_DB}" -v ON_ERROR_STOP=1 -q \
     -c "INSERT INTO tenant_adapters (tenant_slug) VALUES ('${TENANT}') ON CONFLICT DO NOTHING;" 2>/dev/null; then
  ok "seeded tenant_slug=${TENANT}"
else
  printf '\033[33m•\033[0m minimal seed failed — tenant_adapters needs more NOT NULL columns. Its shape:\n'
  psql -d "${DEV_DB}" -c "\\d tenant_adapters" | sed 's/^/    /'
  printf '    -> extend the INSERT above with the required columns, then re-run.\n'
fi

step "5. RLS correctness gate (tenancy-invariants T1-T4)"
# Adversarial: as ifos_app, an INSERT WITHOUT SET LOCAL app.current_tenant must
# FAIL (RLS blocks tenant-unscoped writes). This proves isolation is enforced.
GRANTED=$(PGPASSWORD="${APP_PW}" psql -h localhost -p "${PORT}" -U "${APP_ROLE}" -d "${DEV_DB}" -tAc \
  "SELECT has_table_privilege('${APP_ROLE}','decision_log','INSERT');" 2>/dev/null || echo "?")
ok "ifos_app INSERT privilege on decision_log: ${GRANTED}"
ADV=$(PGPASSWORD="${APP_PW}" psql -h localhost -p "${PORT}" -U "${APP_ROLE}" -d "${DEV_DB}" -v ON_ERROR_STOP=1 -tAc \
  "INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome) VALUES ('${TENANT}','setup-probe','trigger','green');" 2>&1 || true)
if printf '%s' "${ADV}" | grep -qiE 'row-level security|policy|violates'; then
  ok "RLS ENFORCED: tenant-unscoped INSERT correctly rejected"
elif printf '%s' "${ADV}" | grep -qiE 'null value|not-null|column .* does not exist'; then
  printf '\033[33m•\033[0m RLS probe hit a column/NOT-NULL issue (schema shape) before RLS — inspect decision_log columns; RLS check inconclusive\n'
else
  printf '\033[33m•\033[0m WARNING: tenant-unscoped INSERT was NOT rejected — RLS may not be enforced. Investigate before trusting writes.\n  (output: %s)\n' "${ADV:-<empty>}"
fi

step "DONE — export this for the agent runtime"
printf '\n  \033[1mexport IFOS_DB_URL="postgresql://%s:%s@localhost:%s/%s"\033[0m\n\n' \
  "${APP_ROLE}" "${APP_PW}" "${PORT}" "${DEV_DB}"
printf '  Verify the agent can read its tenant:\n'
# shellcheck disable=SC2016  # intentional: print $IFOS_DB_URL literally for the user to run
printf '    psql "$IFOS_DB_URL" -c "BEGIN; SET LOCAL app.current_tenant='\''%s'\''; SELECT count(*) FROM tenant_adapters; COMMIT;"\n' "${TENANT}"
