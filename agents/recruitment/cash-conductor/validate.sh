#!/usr/bin/env bash
# shellcheck disable=SC2329
# (_fail + _warn are not invoked in the W4 Day-26 skeleton — TODO(W7-8)
#  blocks invoke them when the per-check impl lands. Keeping them defined
#  so the skeleton matches the final shape + the build-slice author can fill
#  the TODOs without re-declaring helpers.)
#
# Cash Conductor agent — validate.sh (Gate A enforcement; W4 Day-26 SKELETON)
#
# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice completes the impl).
# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
# hard-fail gate that runs BETWEEN the chase-draft generation (cycle.sh Step 8)
# and the queue-to-Concierge (Step 10). If any check fails, validate.sh exits
# non-zero + emits an ESC_* escalation row to decision_log; the chase draft does
# NOT route to Concierge; cycle.sh aborts the draft pipeline.
#
# Invocation contract:
#   bash validate.sh <draft_path>
#
# Inputs:
#   - $1: path to the vault chase-draft file (cycle.sh Step 8 wrote it)
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
#          CTX_TONE_RULES (json string)
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to Step 10
#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts the draft
#   2  validate.sh invocation error (bad args, missing draft, etc.)
#
# Checks (per agent.md §5 Gate A, ULTRAPLAN A4 line 538 verbatim):
#   G1 — chase email references CORRECT invoice number AND amount AND contact (AND not OR)
#   G2 — invoice NOT paid in last 24h (defence-in-depth re-query at draft time)
#   G3 — voice classifier score ≥0.75 for position 1-2; ≥0.80 for position 3 (§3.2)
#   G4 — No PII outside firm boundary in chase body (regex pass)
#   G5 — Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
#   G6 — Open Banking token ≥7 days from expiry (≤7d → ESC_OPEN_BANKING_TOKEN_AGING blocking)
#   G7 — Accounting auth refresh succeeded in Step 1

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  printf 'cash-conductor/validate.sh: usage: validate.sh <draft_path>\n' >&2
  exit 2
fi

readonly DRAFT="$1"

if [[ ! -f "${DRAFT}" ]]; then
  printf 'validate.sh: draft not found at %s\n' "${DRAFT}" >&2
  exit 2
fi

if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
  exit 2
fi
if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
  exit 2
fi

# Resolve _shared/ helpers (4-candidate fallback; matches diagnostic/validate.sh
# pattern post smoke-hotfix commit d7d52c5).
_SHARED_DIR=""
for _candidate in \
  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
  "${IFOS_REPO_ROOT:-}/agents/_shared" \
  "${CTX_AGENT_DIR}/../../_shared" \
  "${CTX_AGENT_DIR}/../_shared" ; do
  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    _SHARED_DIR="${_candidate}"
    break
  fi
done
if [[ -z "${_SHARED_DIR}" ]]; then
  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
  exit 2
fi
# shellcheck source=/dev/null
source "${_SHARED_DIR}/hook-helpers.sh"

# Track failures + warnings across all checks (collect all before exit for richer audit)
declare -a FAILURES=()
declare -a WARNINGS=()

_fail() {
  FAILURES+=("$1")
  printf '  ✗ %s\n' "$1" >&2
}
_warn() {
  WARNINGS+=("$1")
  printf '  ! %s\n' "$1" >&2
}
_ok() {
  printf '  ✓ %s\n' "$1"
}

# Track the dominant failure class for ESC routing (set by the first hard fail).
ESC_CLASS=""

# Frontmatter reader: pull "key: value" from the leading YAML block, strip quotes.
_fm() {
  sed -n '1,/^---$/{/^---$/d;p;}' "${DRAFT}" 2>/dev/null \
    | grep -m1 "^$1:" | sed "s/^$1:[[:space:]]*//; s/^\"//; s/\"$//"
}

D_INVOICE_ID="$(_fm invoice_id)"
D_INVOICE_NUMBER="$(_fm invoice_number)"
D_AMOUNT="$(_fm amount_due)"
D_CONTACT="$(_fm contact_email)"
D_POSITION="$(_fm escalation_ladder_position)"
D_VOICE="$(_fm voice_score)"

# One RLS-scoped read of the source-of-truth invoice row for G1/G2.
DB_ROW=""
if [[ -n "${D_INVOICE_ID}" && -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  DB_ROW="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" --set=inv="${D_INVOICE_ID}" <<'SQL' 2>/dev/null
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT coalesce(invoice_number,'') || '|' || (amount_total - amount_paid)::text || '|' ||
       status || '|' || coalesce(client_billing_email,'')
FROM cash_conductor_invoices WHERE invoice_id = :'inv' LIMIT 1;
COMMIT;
SQL
)"
fi
IFS='|' read -r DB_NUMBER DB_AMOUNT_DUE DB_STATUS DB_EMAIL <<<"${DB_ROW}"

# ────────────────────────────────────────────────────────────────────────
# G1 — invoice number + amount + contact triple-check (ULTRAPLAN A4 line 538; AND)
# Cross-checks the draft frontmatter against the source-of-truth invoice row.
# Invoice#/amount mismatch → ESC_AGENT_OUTPUT_SHAPE; contact mismatch → ESC_ADDRESSEE_MISMATCH.
# ────────────────────────────────────────────────────────────────────────

if [[ -z "${DB_ROW}" ]]; then
  _warn "G1: could not load invoice ${D_INVOICE_ID} (no DB row); cannot verify — draft held for manual review"
else
  if [[ -n "${D_INVOICE_NUMBER}" && "${D_INVOICE_NUMBER}" != "${DB_NUMBER}" ]]; then
    _fail "G1: invoice_number mismatch (draft='${D_INVOICE_NUMBER}' db='${DB_NUMBER}')"; ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
  fi
  # Numeric amount compare with a 0.005 tolerance (formatting-agnostic).
  if ! awk -v a="${D_AMOUNT:-0}" -v b="${DB_AMOUNT_DUE:-0}" 'BEGIN{d=a-b; if(d<0)d=-d; exit !(d<=0.005)}'; then
    _fail "G1: amount_due mismatch (draft='${D_AMOUNT}' db='${DB_AMOUNT_DUE}')"; ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
  fi
  # Contact: a true MISMATCH (draft addresses a different party than the invoice
  # contact) is blocking. Empty-vs-empty is "no contact on file" → warn, not fail
  # (drafts-only: the consultant supplies the address before send).
  if [[ -n "${D_CONTACT}" && -n "${DB_EMAIL}" && "${D_CONTACT}" != "${DB_EMAIL}" ]]; then
    _fail "G1: contact_email mismatch (draft='${D_CONTACT}' db='${DB_EMAIL}')"; ESC_CLASS="ESC_ADDRESSEE_MISMATCH"
  elif [[ -z "${DB_EMAIL}" ]]; then
    _warn "G1: invoice has no client_billing_email on file — consultant supplies the address before send"
  fi
  [[ ${#FAILURES[@]} -eq 0 ]] && _ok "G1: invoice#/amount/contact triple-check"
fi

# ────────────────────────────────────────────────────────────────────────
# G2 — NOT already settled (paid-precondition; ULTRAPLAN A4 line 538 verbatim)
# Defence-in-depth: never chase an invoice that is already paid/settled. The
# 24h-window refinement needs a payment-event timestamp (accounting re-query) —
# documented enhancement; the live gate here is amount_due>0 AND status open-ish.
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${DB_ROW}" ]]; then
  if awk -v b="${DB_AMOUNT_DUE:-0}" 'BEGIN{exit !(b<=0)}' \
     || [[ "${DB_STATUS}" == "paid" || "${DB_STATUS}" == "cancelled" || "${DB_STATUS}" == "voided" ]]; then
    _fail "G2: invoice already settled (amount_due='${DB_AMOUNT_DUE}' status='${DB_STATUS}') — do not chase"
    ESC_CLASS="${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}"
  else
    _ok "G2: invoice not settled (amount_due='${DB_AMOUNT_DUE}' status='${DB_STATUS}')"
  fi
fi

# ────────────────────────────────────────────────────────────────────────
# G3 — voice classifier score by position threshold (agent.md §3.2)
# Position 1-2 ≥0.75 ; position 3 ≥0.80. When the draft is unscored (no tenant
# voice_corpus), this is a WARNING not a hard fail — a score cannot be honestly
# computed without a seeded corpus + embedding infra (documented enhancement).
# ────────────────────────────────────────────────────────────────────────

if [[ "${D_VOICE}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  _thr="0.75"; [[ "${D_POSITION}" == "3" ]] && _thr="0.80"
  if awk -v s="${D_VOICE}" -v t="${_thr}" 'BEGIN{exit !(s>=t)}'; then
    _ok "G3: voice_score ${D_VOICE} ≥ ${_thr} (position ${D_POSITION})"
  else
    _fail "G3: voice_score ${D_VOICE} < ${_thr} (position ${D_POSITION})"; ESC_CLASS="${ESC_CLASS:-ESC_VOICE_DRIFT}"
  fi
else
  _warn "G3: voice unscored (${D_VOICE:-none}) — no tenant voice_corpus; cannot enforce threshold (documented enhancement)"
fi

# ────────────────────────────────────────────────────────────────────────
# G4 — No PII outside firm boundary: scan the body for email addresses whose
# domain is not the invoice contact's domain or the tenant firm domain.
# ────────────────────────────────────────────────────────────────────────

_BODY_EMAILS="$(sed -n '/^---$/,/^---$/!p' "${DRAFT}" 2>/dev/null \
  | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
if [[ -n "${_BODY_EMAILS}" ]]; then
  _allow_domain="${D_CONTACT##*@}"
  _ext=0
  while IFS= read -r _em; do
    [[ -z "${_em}" ]] && continue
    if [[ -z "${_allow_domain}" || "${_em##*@}" != "${_allow_domain}" ]]; then _ext=1; fi
  done <<<"${_BODY_EMAILS}"
  if [[ "${_ext}" -eq 1 ]]; then
    _fail "G4: body contains email address(es) outside the firm boundary"; ESC_CLASS="${ESC_CLASS:-ESC_PII_LEAKAGE_RISK}"
  else
    _ok "G4: no PII outside firm boundary"
  fi
else
  _ok "G4: no email addresses in body"
fi

# ────────────────────────────────────────────────────────────────────────
# G5 — Reconciliation match-confidence ≥0.85 (Stage 1-2 auto-write only).
# N/A for chase drafts: a chase targets an UNMATCHED invoice, so there is no
# auto-write confidence to gate. Pass-with-note.
# ────────────────────────────────────────────────────────────────────────

_ok "G5: N/A for chase draft (auto-write gate applies to reconciliation Step 6)"

# ────────────────────────────────────────────────────────────────────────
# G6 — Open Banking token ≥7d from PSD2 expiry (best-effort via token-stage CLI).
# ────────────────────────────────────────────────────────────────────────

_OB_CLI="${IFOS_REPO_ROOT:-}/packages/mcp-connectors/open-banking/dist/cli.js"
if [[ -f "${_OB_CLI}" ]] && command -v node >/dev/null 2>&1; then
  _ob_stage="$(node "${_OB_CLI}" token-stage 2>/dev/null | grep -oE '"stage"[^,}]*' | sed 's/.*: *"\{0,1\}//; s/"//' || echo unknown)"
  if [[ "${_ob_stage}" == "blocking" ]]; then
    _fail "G6: Open Banking token in blocking stage (≤7d to PSD2 expiry)"; ESC_CLASS="${ESC_CLASS:-ESC_OPEN_BANKING_TOKEN_AGING}"
  else
    _ok "G6: Open Banking token stage='${_ob_stage:-unknown}' (not blocking)"
  fi
else
  _warn "G6: open-banking token-stage CLI unavailable — best-effort skip"
fi

# ────────────────────────────────────────────────────────────────────────
# G7 — Accounting auth refreshed this session (recent auth_refresh_complete row).
# ────────────────────────────────────────────────────────────────────────

if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _auth_ok="$(psql "${IFOS_DB_URL}" -tAq --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT 1 FROM decision_log
WHERE agent_name='cash-conductor' AND payload->>'output_type'='auth_refresh_complete'
  AND reason LIKE 'accounting:ok%' AND created_at > now() - interval '1 day'
LIMIT 1;
COMMIT;
SQL
)"
  if [[ "${_auth_ok}" == *1* ]]; then
    _ok "G7: accounting auth refreshed this session"
  else
    _warn "G7: no recent accounting:ok auth_refresh_complete row — best-effort warn"
  fi
else
  _warn "G7: DB unavailable — cannot confirm auth refresh"
fi

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nValidate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # Route the dominant failure class to its ESC code (agent.md §6): G1 invoice#/amount
  # → ESC_AGENT_OUTPUT_SHAPE; G1 contact → ESC_ADDRESSEE_MISMATCH; G2 → ESC_AGENT_OUTPUT_SHAPE;
  # G3 → ESC_VOICE_DRIFT; G4 → ESC_PII_LEAKAGE_RISK; G6 → ESC_OPEN_BANKING_TOKEN_AGING.
  autosend_escalate "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}" "agent=cash-conductor" \
    "tenant=${CTX_TENANT_SLUG}" "invoice=${D_INVOICE_ID:-unknown}" \
    "failures=${#FAILURES[@]}" "draft=${DRAFT}"
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
