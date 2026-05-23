#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2015
#
# IFOS tenant provisioning — consolidated remediation script
#
# Performs ALL post-Day-4 manual operations that today's session
# (2026-05-23, Day 12) surfaced as required for a working tenant:
#
#   1. Validate tenant slug pattern
#   2. INSERT tenant row in tenants table (postgres superuser)
#   3. Create /vault/<slug>/ directory with correct permissions
#   4. Grant TRIGGER privilege on entities to ifos_app (if first tenant)
#   5. Transfer v0.2 table ownership to postgres (if not already)
#   6. Re-grant explicit privileges to ifos_app after ownership transfer
#   7. Apply FORCE ROW LEVEL SECURITY on all v0.2 tables (if not already)
#   8. Verify cross-tenant isolation via adversarial query
#   9. Emit summary + audit trail
#
# Path A discipline: founder runs via sudo on the VPS. Credentials never
# enter chat.
#
# Usage (on VPS):
#   sudo bash /usr/local/bin/provision-tenant.sh <tenant-slug> "<tenant name>"
#
# Usage (founder local via SSH):
#   ssh -i ~/.ssh/ifos_hetzner_ed25519 maddox@178.105.87.24 \
#       'sudo bash /usr/local/bin/provision-tenant.sh <slug> "<name>"'
#
# Idempotent: safe to re-run. Each step uses IF NOT EXISTS / ON CONFLICT
# DO NOTHING / pre-check guards.

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Config + arguments
# ────────────────────────────────────────────────────────────────────────

readonly DB_NAME="ifos_v2"
readonly APP_ROLE="ifos_app"
readonly SLUG_PATTERN='^[a-z][a-z0-9-]{2,63}$'

if [[ $# -lt 2 ]]; then
  cat <<EOF
Usage: $0 <tenant-slug> "<tenant name>"

Arguments:
  tenant-slug  Lowercase letters/digits/dashes, must start with letter,
               3-64 chars. Pattern: $SLUG_PATTERN
               Examples: migration-test, acme-recruitment
  tenant name  Free-form human-readable name (quote if has spaces)
               Examples: "Acme Recruitment Ltd"

Optional env vars:
  IFOS_VAULT_ROOT  Vault directory root (default: /vault)
  IFOS_TENANT_TIER One of: pilot, paid, enterprise (default: pilot)
EOF
  exit 2
fi

TENANT_SLUG="$1"
TENANT_NAME="$2"
VAULT_ROOT="${IFOS_VAULT_ROOT:-/vault}"
TENANT_TIER="${IFOS_TENANT_TIER:-pilot}"

# ────────────────────────────────────────────────────────────────────────
# UX helpers
# ────────────────────────────────────────────────────────────────────────

_step() { printf '\n\033[1;34m── %s ──\033[0m\n' "$1"; }
_pass() { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; [[ -n "${2:-}" ]] && printf '    %s\n' "$2"; exit 1; }
_warn() { printf '  \033[1;33m!\033[0m %s\n' "$1"; }
_info() { printf '  \033[0;36m·\033[0m %s\n' "$1"; }

_psql_super() {
  sudo -u postgres psql -d "$DB_NAME" -t -A "$@"
}

# ────────────────────────────────────────────────────────────────────────
# Step 0 — Pre-flight + slug validation
# ────────────────────────────────────────────────────────────────────────

_step "Step 0 — Pre-flight"

if [[ $EUID -ne 0 ]]; then
  _fail "Must run as root (use sudo)" "sudo bash $0 $TENANT_SLUG \"$TENANT_NAME\""
fi
_pass "Running as root"

if ! command -v psql >/dev/null 2>&1; then
  _fail "psql not on PATH"
fi
_pass "psql present"

if ! [[ "$TENANT_SLUG" =~ $SLUG_PATTERN ]]; then
  _fail "Invalid tenant slug" "Must match pattern $SLUG_PATTERN"
fi
_pass "Tenant slug pattern valid: $TENANT_SLUG"

if ! _psql_super -c "SELECT 1;" >/dev/null 2>&1; then
  _fail "Cannot connect to $DB_NAME as postgres superuser"
fi
_pass "Postgres reachable as postgres superuser"

if ! _psql_super -c "SELECT rolname FROM pg_roles WHERE rolname='$APP_ROLE';" | grep -q "$APP_ROLE"; then
  _fail "Role $APP_ROLE does not exist" "Day-4 §6.3 creates this role"
fi
_pass "Role $APP_ROLE exists"

if [[ ! -d "$VAULT_ROOT" ]]; then
  _fail "Vault root $VAULT_ROOT does not exist" "Check LUKS volume mount"
fi
_pass "Vault root $VAULT_ROOT exists"

# ────────────────────────────────────────────────────────────────────────
# Step 1 — Insert tenant row (idempotent via ON CONFLICT)
# ────────────────────────────────────────────────────────────────────────

_step "Step 1 — Tenants table row"

EXISTING=$(_psql_super -c "SELECT count(*) FROM tenants WHERE tenant_slug='$TENANT_SLUG';")
if [[ "$EXISTING" == "1" ]]; then
  _warn "tenant '$TENANT_SLUG' already exists in tenants table — skipping INSERT"
else
  _psql_super -c "INSERT INTO tenants (tenant_slug, tenant_name, metadata) VALUES ('$TENANT_SLUG', '$TENANT_NAME', '{\"status\":\"active\",\"tier\":\"$TENANT_TIER\"}'::jsonb);" >/dev/null
  _pass "Inserted tenant row: $TENANT_SLUG ($TENANT_NAME, tier=$TENANT_TIER)"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 2 — Vault directory
# ────────────────────────────────────────────────────────────────────────

_step "Step 2 — Vault directory"

TENANT_VAULT="${VAULT_ROOT}/${TENANT_SLUG}"
if [[ -d "$TENANT_VAULT" ]]; then
  _warn "$TENANT_VAULT already exists — verifying permissions"
else
  mkdir -p "$TENANT_VAULT"
  _pass "Created $TENANT_VAULT"
fi

chmod 700 "$TENANT_VAULT"
chown maddox:maddox "$TENANT_VAULT"
_pass "$TENANT_VAULT mode 700 owner=maddox:maddox"

# ────────────────────────────────────────────────────────────────────────
# Step 3 — TRIGGER privilege on entities (idempotent)
# ────────────────────────────────────────────────────────────────────────

_step "Step 3 — Entities TRIGGER privilege"

HAS_TRIGGER=$(_psql_super -c "SELECT has_table_privilege('$APP_ROLE', 'entities', 'TRIGGER');")
if [[ "$HAS_TRIGGER" == "t" ]]; then
  _pass "$APP_ROLE already has TRIGGER on entities"
else
  _psql_super -c "GRANT TRIGGER ON entities TO $APP_ROLE;" >/dev/null
  _pass "Granted TRIGGER on entities to $APP_ROLE"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 4 — v0.2 table ownership (transfer to postgres if needed)
# ────────────────────────────────────────────────────────────────────────

_step "Step 4 — v0.2 table ownership"

V02_TABLES=(voice_corpus voice_corpus_chunks tone_rule recent_edit)
V02_SEQUENCES=(voice_corpus_id_seq voice_corpus_chunks_id_seq tone_rule_id_seq recent_edit_id_seq)
TRANSFERRED=0

for table in "${V02_TABLES[@]}"; do
  OWNER=$(_psql_super -c "SELECT tableowner FROM pg_tables WHERE tablename='$table';")
  if [[ "$OWNER" != "postgres" ]]; then
    _psql_super -c "ALTER TABLE $table OWNER TO postgres;" >/dev/null
    TRANSFERRED=$((TRANSFERRED + 1))
    _info "ALTER TABLE $table OWNER TO postgres (was $OWNER)"
  fi
done

for seq in "${V02_SEQUENCES[@]}"; do
  EXISTS=$(_psql_super -c "SELECT count(*) FROM pg_sequences WHERE sequencename='$seq';")
  if [[ "$EXISTS" == "1" ]]; then
    OWNER=$(_psql_super -c "SELECT sequenceowner FROM pg_sequences WHERE sequencename='$seq';")
    if [[ "$OWNER" != "postgres" ]]; then
      _psql_super -c "ALTER SEQUENCE $seq OWNER TO postgres;" >/dev/null
      TRANSFERRED=$((TRANSFERRED + 1))
      _info "ALTER SEQUENCE $seq OWNER TO postgres (was $OWNER)"
    fi
  fi
done

if (( TRANSFERRED == 0 )); then
  _pass "All v0.2 tables + sequences already owned by postgres"
else
  _pass "Transferred ownership of $TRANSFERRED objects to postgres"
fi

# ────────────────────────────────────────────────────────────────────────
# Step 5 — FORCE ROW LEVEL SECURITY on v0.2 tables
# ────────────────────────────────────────────────────────────────────────

_step "Step 5 — FORCE ROW LEVEL SECURITY"

for table in "${V02_TABLES[@]}"; do
  FORCED=$(_psql_super -c "SELECT relforcerowsecurity FROM pg_class WHERE relname='$table';")
  if [[ "$FORCED" == "f" ]]; then
    _psql_super -c "ALTER TABLE $table FORCE ROW LEVEL SECURITY;" >/dev/null
    _info "ALTER TABLE $table FORCE ROW LEVEL SECURITY"
  fi
done
_pass "All v0.2 tables FORCE ROW LEVEL SECURITY enabled"

# ────────────────────────────────────────────────────────────────────────
# Step 6 — Re-grant explicit privileges (idempotent)
# ────────────────────────────────────────────────────────────────────────

_step "Step 6 — Explicit privilege re-grants for $APP_ROLE"

_psql_super <<EOF >/dev/null
GRANT SELECT, INSERT, UPDATE         ON voice_corpus         TO $APP_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON voice_corpus_chunks  TO $APP_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE ON tone_rule            TO $APP_ROLE;
GRANT SELECT, INSERT                 ON recent_edit          TO $APP_ROLE;
GRANT USAGE, SELECT ON SEQUENCE voice_corpus_id_seq        TO $APP_ROLE;
GRANT USAGE, SELECT ON SEQUENCE voice_corpus_chunks_id_seq TO $APP_ROLE;
GRANT USAGE, SELECT ON SEQUENCE tone_rule_id_seq           TO $APP_ROLE;
GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO $APP_ROLE;
EOF
_pass "8 privilege grants re-applied (4 tables + 4 sequences)"

# ────────────────────────────────────────────────────────────────────────
# Step 7 — Cross-tenant isolation verification (adversarial)
# ────────────────────────────────────────────────────────────────────────

_step "Step 7 — Cross-tenant isolation smoke test"

_psql_super <<EOF >/dev/null
BEGIN;
SET LOCAL app.current_tenant='$TENANT_SLUG';
INSERT INTO decision_log (tenant_slug, agent_name, phase, payload)
VALUES ('$TENANT_SLUG', '_tenant_provision', 'trigger', '{"event":"provision-smoke"}'::jsonb);
COMMIT;
EOF
_info "Marker row inserted as '$TENANT_SLUG'"

LEAK=$(PGOPTIONS="-c app.current_tenant=not-the-real-tenant" \
  sudo -u postgres psql -d "$DB_NAME" -c "SET ROLE $APP_ROLE;" -t -A \
  -c "SELECT count(*) FROM decision_log WHERE agent_name='_tenant_provision';" \
  | tail -1 | tr -d ' ')

if [[ "$LEAK" == "0" ]]; then
  _pass "Cross-tenant read blocked by RLS (not-the-real-tenant sees 0 rows)"
else
  _fail "RLS LEAK: cross-tenant read returned $LEAK rows" \
    "Tenancy invariants compromised — DO NOT proceed with this tenant"
fi

# ────────────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────────────

_step "Summary"

printf '\nTenant provisioned: \033[1;32m%s\033[0m\n' "$TENANT_SLUG"
printf 'Tenant name:        %s\n' "$TENANT_NAME"
printf 'Tier:               %s\n' "$TENANT_TIER"
printf 'Vault directory:    %s (mode 700)\n' "$TENANT_VAULT"
printf 'Database row:       tenants.tenant_slug=%s\n' "$TENANT_SLUG"
printf 'RLS isolation:      verified (cross-tenant returns 0)\n\n'

printf 'Next steps:\n'
printf '  1. Render agents into this tenant via ifos-render-agent\n'
printf '  2. Add tenant_adapters.config overrides if needed\n'
printf '  3. Seed voice_corpus when tenant uploads source documents\n'
printf '  4. Verify full tenancy audit: bash scripts/run-tenancy-audit.sh\n\n'

printf 'Audit row: 1 row in decision_log (agent_name=_tenant_provision) as\n'
printf 'provenance for this provisioning operation.\n\n'
