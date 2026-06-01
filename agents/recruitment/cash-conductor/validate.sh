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

# ────────────────────────────────────────────────────────────────────────
# G1 — invoice number + amount + contact (per ULTRAPLAN A4 line 538)
# Reads draft YAML frontmatter (per agent.md §3 Output 2 schema):
#   invoice_id, contact_email, amount_due, days_overdue, escalation_position
# Cross-checks against cash_conductor_invoices.<invoice_id>.
# ────────────────────────────────────────────────────────────────────────

# TODO(W7-8): parse draft YAML frontmatter; SELECT FROM cash_conductor_invoices
# WHERE invoice_id = <draft.invoice_id>; assert TotalAmt/Balance match draft.amount_due
# AND CustomerRef.email matches draft.contact_email. On any mismatch:
# _fail "G1: invoice/amount/contact triple-check failed" + fire ESC_ADDRESSEE_MISMATCH
# (per agent.md §6; blocking; operator + ifos_oncall routing).
_ok "G1: invoice/amount/contact triple-check — SKELETON (W7-8 wires the SQL)"

# ────────────────────────────────────────────────────────────────────────
# G2 — NOT paid in last 24h (defence-in-depth; per ULTRAPLAN A4 line 538 verbatim)
# Re-query accounting (Xero/QB) at draft time; if paid_in_last_24h: _fail + ESC_AGENT_OUTPUT_SHAPE
# ────────────────────────────────────────────────────────────────────────

# TODO(W7-8): @ifos/xero getInvoice OR @ifos/quickbooks getInvoice → check
# AmountPaid timestamp; if within 24h _fail + emit ESC_AGENT_OUTPUT_SHAPE
# (output-shape constraint per catalogue line 184) via:
# hh_decision_action "validate_gate_a_fail" "invoice:<id>" "<hash>" "ESC_AGENT_OUTPUT_SHAPE; paid-in-24h"
_ok "G2: not-paid-in-24h — SKELETON (W7-8 wires the accounting re-query)"

# ────────────────────────────────────────────────────────────────────────
# G3 — voice classifier score by position threshold (per agent.md §3.2)
# Position 1-2: ≥0.75 ; Position 3: ≥0.80 (sensitive sends like position-3 escalation)
# ────────────────────────────────────────────────────────────────────────

# TODO(W7-8): parse draft YAML for voice_score + escalation_position; compare
# to threshold; on fail emit ESC_VOICE_DRIFT (warn per catalogue lines 120-125)
# + hh_decision_action validate_gate_a_fail.
_ok "G3: voice classifier per-position threshold — SKELETON (W7-8 wires)"

# ────────────────────────────────────────────────────────────────────────
# G4 — No PII outside firm boundary (regex pass against chase body)
# ────────────────────────────────────────────────────────────────────────

# TODO(W7-8): grep draft body for email patterns NOT matching the tenant's
# firm-domain whitelist; if any: _fail + ESC_PII_LEAKAGE_RISK (blocking;
# operator + ifos_oncall).
_ok "G4: no PII outside firm boundary — SKELETON (W7-8 wires firm-domain whitelist)"

# ────────────────────────────────────────────────────────────────────────
# G5 — Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
# Only fires on Stage 1-2 auto-write path; Stage 3-4 already operator-queued.
# ────────────────────────────────────────────────────────────────────────

_ok "G5: reconciliation match-confidence ≥0.85 — SKELETON (W7-8 wires)"

# ────────────────────────────────────────────────────────────────────────
# G6 — Open Banking token age ≥7 days from PSD2 consent expiry
# Per @ifos/open-banking getTokenAgeStage; ≤7d = "blocking" stage = hard fail.
# ────────────────────────────────────────────────────────────────────────

# TODO(W7-8): @ifos/open-banking loadTokens + getTokenAgeStage; if stage=="blocking"
# _fail + ESC_OPEN_BANKING_TOKEN_AGING (catalogue staged severity per §2.7;
# blocking severity routes operator + ifos_oncall_chat_id).
_ok "G6: Open Banking token ≥7d from PSD2 expiry — SKELETON (W7-8 wires)"

# ────────────────────────────────────────────────────────────────────────
# G7 — Accounting auth refreshed in Step 1
# Sanity check that cycle.sh Step 1 wrote a fresh auth_refresh_complete row.
# ────────────────────────────────────────────────────────────────────────

_ok "G7: accounting auth refresh in this session — SKELETON (W7-8 wires)"

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nValidate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # TODO(W7-8): per-failure routing — different ESC code per failure class
  # (G1 → ESC_ADDRESSEE_MISMATCH; G2 → ESC_AGENT_OUTPUT_SHAPE; G3 → ESC_VOICE_DRIFT;
  #  G4 → ESC_PII_LEAKAGE_RISK; G5 → ESC_RECONCILIATION_AMBIGUOUS or downgrade;
  #  G6 → ESC_OPEN_BANKING_TOKEN_AGING; G7 → ESC_ACCOUNTING_AUTH)
  # hh_decision_action "validate_gate_a_fail" "tenant:${CTX_TENANT_SLUG}" payload_hash \
  #   "ESC_<class>; agent_name:cash-conductor; failures:${#FAILURES[@]}"
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
