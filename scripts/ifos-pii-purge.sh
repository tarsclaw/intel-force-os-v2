#!/usr/bin/env bash
# shellcheck disable=SC2329,SC2015
#
# IFOS PII purge — nightly cron for recent_edit text-field redaction
#
# Per Founder Decision D3 (recommended D3-B path; pending advisor confirm
# from D2 SeedLegals engagement): purge `original_text` + `edited_text`
# from `recent_edit` rows older than the configured retention window.
# Metadata (edit_distance, resolution, tone_rules_triggered, resolved_at,
# action_type, agent_name) retained indefinitely for v2.0 LoRA SFT corpus.
#
# Rationale: UK GDPR Art. 5(1)(e) data minimisation requires bounded
# retention of PII-bearing fields. Aggregated metadata is sufficient for
# SFT training signal; raw text bodies are not required beyond review
# window.
#
# Retention window: read from autosend-policy.yaml `defaults.pii_retention_days`
# (added in v0.3 supplement; defaults to 90 days). Per-tenant override via
# tenant_adapters.config.pii_retention_days (D3-C compatibility).
#
# Cron deployment: /etc/cron.daily/ifos-pii-purge → calls this script.
# Run on Hetzner VPS as the ifos system user (no SSH tunnel needed since
# we're on-VPS).
#
# Usage (on VPS):
#   sudo -u ifos_user bash /usr/local/bin/ifos-pii-purge.sh [--dry-run]
#
# Usage (founder local + SSH tunnel for testing):
#   SSH_MODE=1 bash scripts/ifos-pii-purge.sh --dry-run
#
# Side effects:
#   - UPDATE recent_edit SET original_text=NULL, edited_text=NULL,
#     text_purged_at=now() WHERE resolved_at < now() - interval '<N> days'
#   - One audit row to decision_log per run: agent_name='_pii_purger',
#     phase='gating_failed', payload with row_count + tenants_touched

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Config
# ────────────────────────────────────────────────────────────────────────

DEFAULT_RETENTION_DAYS=90
DRY_RUN=0
SSH_MODE=0

# REPO_ROOT reserved for future use (e.g., loading retention from autosend-policy.yaml)
# Currently unused — purge defaults are CLI-arg + sane internal default.

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --retention-days) DEFAULT_RETENTION_DAYS="$2"; shift 2 ;;
    --help)
      cat <<EOF
Usage: $0 [--dry-run] [--retention-days N]

  --dry-run         Show planned UPDATE rows count; don't execute UPDATE
  --retention-days  Override default (90); range 30-365

Environment:
  SSH_MODE=1        Use SSH tunnel + read-rs password prompt (local testing).
                    Default: direct local Postgres (on-VPS deployment).
  IFOS_DB_URL       Direct connection string (overrides SSH_MODE config).
EOF
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

# Retention bounds: 30-365 days
if (( DEFAULT_RETENTION_DAYS < 30 || DEFAULT_RETENTION_DAYS > 365 )); then
  echo "FATAL: retention-days must be in [30, 365]; got ${DEFAULT_RETENTION_DAYS}"
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# Connection setup
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_DB_URL:-}" ]]; then
  # Direct connection string already set (production cron path; ifos system
  # user's environment provides URL with ifos_app role)
  PSQL_CONN=(--dbname "${IFOS_DB_URL}")
elif (( SSH_MODE == 1 )); then
  # Local-testing mode: SSH tunnel + interactive password
  readonly VPS_HOST="178.105.87.24"
  readonly VPS_SSH_USER="maddox"
  readonly VPS_SSH_KEY="${HOME}/.ssh/ifos_hetzner_ed25519"
  readonly LOCAL_PORT="55432"

  if ! ssh -i "${VPS_SSH_KEY}" -o BatchMode=yes -o ConnectTimeout=10 \
          "${VPS_SSH_USER}@${VPS_HOST}" "true" 2>/dev/null; then
    echo "FATAL: SSH to ${VPS_SSH_USER}@${VPS_HOST} failed"
    exit 1
  fi

  ssh -i "${VPS_SSH_KEY}" -N -L "${LOCAL_PORT}:localhost:5432" \
      -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 \
      "${VPS_SSH_USER}@${VPS_HOST}" &
  SSH_PID=$!
  trap 'kill ${SSH_PID} 2>/dev/null || true; unset PGPASSWORD' EXIT INT TERM
  sleep 2

  printf 'Enter ifos_app Postgres password (silent): '
  read -rs PGPASSWORD
  printf '\n'
  export PGPASSWORD

  PSQL_CONN=(-h localhost -p "${LOCAL_PORT}" -U ifos_app -d ifos_v2)
else
  # On-VPS deployment: direct localhost connection (default)
  PSQL_CONN=(-h localhost -p 5432 -U ifos_app -d ifos_v2)
fi

# ────────────────────────────────────────────────────────────────────────
# Step 1: Count affected rows per tenant (read-only; safe to run anytime)
# ────────────────────────────────────────────────────────────────────────

echo "[$(date -u +%FT%TZ)] ifos-pii-purge starting (retention=${DEFAULT_RETENTION_DAYS}d, dry-run=${DRY_RUN})"

# Aggregate count across all tenants. Use server-side current_setting() OR
# bypass RLS by running as admin (this script runs as the ifos system user
# which can have a separate Postgres role with cross-tenant SELECT for
# admin operations). For v1.0 single-tenant pilot we use the ifos_app role
# with each tenant_slug set in turn.

ALL_TENANTS=$(psql "${PSQL_CONN[@]}" -t -A -c \
  "SELECT tenant_slug FROM tenants WHERE metadata->>'status' IN ('active','suspended') ORDER BY tenant_slug;")

if [[ -z "${ALL_TENANTS}" ]]; then
  echo "  (no active or suspended tenants — exiting clean)"
  exit 0
fi

TOTAL_ROWS_TO_PURGE=0
TENANTS_TOUCHED=()

for tenant in ${ALL_TENANTS}; do
  COUNT=$(psql "${PSQL_CONN[@]}" -q -t -A <<EOF
BEGIN;
SET LOCAL app.current_tenant='${tenant}';
SELECT count(*) FROM recent_edit
WHERE resolved_at < now() - interval '${DEFAULT_RETENTION_DAYS} days'
  AND original_text IS NOT NULL;
COMMIT;
EOF
)
  COUNT="${COUNT// /}"
  if (( COUNT > 0 )); then
    echo "  tenant=${tenant}: ${COUNT} rows beyond retention window"
    TOTAL_ROWS_TO_PURGE=$((TOTAL_ROWS_TO_PURGE + COUNT))
    TENANTS_TOUCHED+=("${tenant}")
  fi
done

echo "  Total rows to purge across $((${#TENANTS_TOUCHED[@]})) tenants: ${TOTAL_ROWS_TO_PURGE}"

if (( TOTAL_ROWS_TO_PURGE == 0 )); then
  echo "[$(date -u +%FT%TZ)] Nothing to purge — exiting clean"
  exit 0
fi

# ────────────────────────────────────────────────────────────────────────
# Step 2: Dry-run vs real UPDATE
# ────────────────────────────────────────────────────────────────────────

if (( DRY_RUN == 1 )); then
  echo "  [DRY-RUN] Would have NULL-ed original_text + edited_text on ${TOTAL_ROWS_TO_PURGE} rows"
  echo "  [DRY-RUN] Re-run without --dry-run to execute"
  exit 0
fi

ROWS_PURGED=0
for tenant in "${TENANTS_TOUCHED[@]}"; do
  PURGED=$(psql "${PSQL_CONN[@]}" -q -t -A <<EOF
BEGIN;
SET LOCAL app.current_tenant='${tenant}';
WITH purged AS (
  UPDATE recent_edit
  SET original_text = NULL,
      edited_text = NULL,
      text_purged_at = now()
  WHERE resolved_at < now() - interval '${DEFAULT_RETENTION_DAYS} days'
    AND original_text IS NOT NULL
  RETURNING 1
)
SELECT count(*) FROM purged;
COMMIT;
EOF
)
  PURGED="${PURGED// /}"
  echo "  tenant=${tenant}: purged ${PURGED} rows"
  ROWS_PURGED=$((ROWS_PURGED + PURGED))
done

# ────────────────────────────────────────────────────────────────────────
# Step 3: Audit row to decision_log
# ────────────────────────────────────────────────────────────────────────

TENANTS_JSON="[$(printf '"%s",' "${TENANTS_TOUCHED[@]}" | sed 's/,$//')]"
audit_sql=$(cat <<EOF
BEGIN;
SET LOCAL app.current_tenant='ifos-meta';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
VALUES (
  'ifos-meta',
  '_pii_purger',
  'gating_failed',
  'purged',
  jsonb_build_object(
    'rows_purged', ${ROWS_PURGED},
    'tenants_touched', '${TENANTS_JSON}'::jsonb,
    'retention_days', ${DEFAULT_RETENTION_DAYS},
    'invocation_time', '$(date -u +%FT%TZ)'
  ),
  now()
);
COMMIT;
EOF
)

if ! printf '%s\n' "${audit_sql}" | psql -v ON_ERROR_STOP=1 -q "${PSQL_CONN[@]}" >/dev/null 2>&1; then
  echo "FATAL: audit row write failed" >&2
  exit 2
fi

echo "[$(date -u +%FT%TZ)] ifos-pii-purge complete: ${ROWS_PURGED} rows purged across ${#TENANTS_TOUCHED[@]} tenants"
exit 0
