#!/usr/bin/env bash
# Cash Conductor — deterministic chase-draft renderer test (P4b).
#
# Exercises agents/recruitment/cash-conductor/bin/render-chase-draft.sh (the SAME
# renderer cycle.sh Step 8 calls). Zero-dependency, no DB: asserts the §3 Output 2
# frontmatter schema, the §3.2 per-position tone, honest voice_score, and that
# position 4 is rejected (never auto-drafted).

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly RENDER="${REPO_ROOT}/agents/recruitment/cash-conductor/bin/render-chase-draft.sh"

_ok()   { printf '  \033[1;32m✓\033[0m %s\n' "$1"; }
_fail() { printf '  \033[1;31m✗\033[0m %s\n' "$1"; }

[[ -f "${RENDER}" ]] || { _fail "renderer missing: ${RENDER}"; exit 1; }
printf '\033[1;34m── Chase-draft renderer test ──\033[0m\n'
fails=0

assert_contains() {  # <haystack> <needle> <label>
  if printf '%s' "$1" | grep -Fq "$2"; then _ok "$3"; else _fail "$3 (missing: $2)"; fails=$((fails+1)); fi
}

# Position 1 draft — assert frontmatter schema + tone + honest voice fields.
D1="$(bash "${RENDER}" --draft-id cc-INV1-p1 --invoice-id INV1 --invoice-number 1007 \
  --amount 450.00 --days-overdue 9 --position 1 --contact-email ap@client.co)"
assert_contains "${D1}" "draft_id: cc-INV1-p1"            "p1: draft_id frontmatter"
assert_contains "${D1}" "invoice_id: INV1"               "p1: invoice_id frontmatter"
assert_contains "${D1}" "amount_due: 450.00"             "p1: amount_due frontmatter"
assert_contains "${D1}" "escalation_ladder_position: 1"  "p1: position frontmatter"
assert_contains "${D1}" "voice_score: unscored"          "p1: honest voice_score (no fake number)"
assert_contains "${D1}" "voice_reason: no_corpus"        "p1: honest voice_reason"
assert_contains "${D1}" "contact_email: ap@client.co"    "p1: contact_email frontmatter"
assert_contains "${D1}" "friendly reminder"              "p1: position-1 friendly tone"

# Position 2 + 3 tone.
D2="$(bash "${RENDER}" --draft-id cc-INV2-p2 --invoice-id INV2 --invoice-number 1008 --amount 75 --days-overdue 16 --position 2)"
assert_contains "${D2}" "Following up"                    "p2: position-2 follow-up tone"
assert_contains "${D2}" "escalation_ladder_position: 2"  "p2: position frontmatter"
D3="$(bash "${RENDER}" --draft-id cc-INV3-p3 --invoice-id INV3 --invoice-number 1009 --amount 1200 --days-overdue 23 --position 3)"
assert_contains "${D3}" "schedule a quick call"           "p3: position-3 call tone"

# Position 4 is NEVER draftable (operator review) → exit 2.
if bash "${RENDER}" --draft-id x --invoice-id INV4 --invoice-number 1010 --amount 50 --days-overdue 31 --position 4 >/dev/null 2>&1; then
  _fail "position 4 should be rejected (exit 2) but succeeded"; fails=$((fails+1))
else
  _ok "position 4 rejected (operator review, not auto-drafted)"
fi

# Missing required arg → exit 2.
if bash "${RENDER}" --draft-id x --invoice-id INV5 >/dev/null 2>&1; then
  _fail "missing required args should exit 2 but succeeded"; fails=$((fails+1))
else
  _ok "missing required args rejected"
fi

printf '\n'
if [[ "${fails}" -eq 0 ]]; then
  _ok "all chase-draft renderer assertions passed"
  exit 0
fi
_fail "${fails} assertion(s) failed"
exit 1
