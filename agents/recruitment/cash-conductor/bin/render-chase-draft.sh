#!/usr/bin/env bash
# Cash Conductor — chase-draft renderer (agent.md §3 Output 2 + §3.2 ladder).
#
# Prints a single chase-draft markdown document (YAML frontmatter + body) to
# stdout. Deterministic + zero-dependency: the same inputs always render the same
# draft, so it is fixture-testable and safe for unsupervised runs. cycle.sh Step 8
# captures stdout → writes to /vault/<tenant>/cash-conductor-drafts/<draft_id>.md
# (chmod 0600) and emits METADATA-only to decision_log (ADR-002 vault/Postgres split).
#
# v1.0 scope note: this renders a position-appropriate TEMPLATED draft (the §3.2
# tone ladder). LLM polish + an embedding voice classifier scored against a seeded
# tenant voice_corpus is the documented enhancement (the dev-sandbox corpus is
# empty, so a voice score cannot be honestly computed yet — see voice_score below).
# A consultant reviews/edits every draft before any send (drafts-only mode), so a
# templated draft fully satisfies the manual-pickup contract.
#
# Usage:
#   render-chase-draft.sh --draft-id ID --invoice-id ID --invoice-number N \
#     --amount N --days-overdue N --position 1|2|3 [--contact-email E] [--issued-date D]

set -euo pipefail

DRAFT_ID="" INVOICE_ID="" INVOICE_NUMBER="" AMOUNT="" DAYS_OVERDUE="" POSITION=""
CONTACT_EMAIL=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --draft-id)       DRAFT_ID="${2:-}"; shift 2 ;;
    --invoice-id)     INVOICE_ID="${2:-}"; shift 2 ;;
    --invoice-number) INVOICE_NUMBER="${2:-}"; shift 2 ;;
    --amount)         AMOUNT="${2:-}"; shift 2 ;;
    --days-overdue)   DAYS_OVERDUE="${2:-}"; shift 2 ;;
    --position)       POSITION="${2:-}"; shift 2 ;;
    --contact-email)  CONTACT_EMAIL="${2:-}"; shift 2 ;;
    *)                printf 'render-chase-draft.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done

for req in DRAFT_ID INVOICE_ID AMOUNT DAYS_OVERDUE POSITION; do
  if [[ -z "${!req}" ]]; then
    printf 'render-chase-draft.sh: --%s required\n' "$(printf '%s' "${req}" | tr 'A-Z_' 'a-z-')" >&2
    exit 2
  fi
done

# §3.2 tone ladder — subject + opening line per position. Position 4 is never
# drafted (operator review); reject it so a caller bug can't auto-draft an escalation.
case "${POSITION}" in
  1)
    SUBJECT="Friendly reminder — invoice ${INVOICE_NUMBER} now due"
    OPENING="Hope everything's OK on your end. This is just a friendly reminder that invoice ${INVOICE_NUMBER} (£${AMOUNT}) is now ${DAYS_OVERDUE} days past its due date."
    CLOSING="No rush if it's already in hand — just let us know if you need anything from us to process it." ;;
  2)
    SUBJECT="Following up — invoice ${INVOICE_NUMBER}"
    OPENING="Following up on invoice ${INVOICE_NUMBER} (£${AMOUNT}), which is now ${DAYS_OVERDUE} days overdue."
    CLOSING="If there's a query or anything holding it up, please let us know and we'll sort it out together." ;;
  3)
    SUBJECT="Invoice ${INVOICE_NUMBER} — can we schedule a quick call?"
    OPENING="I wanted to flag invoice ${INVOICE_NUMBER} (£${AMOUNT}), which is now ${DAYS_OVERDUE} days overdue."
    CLOSING="Could we schedule a quick call to make sure there's nothing outstanding our end? Happy to find a time that works." ;;
  *)
    printf 'render-chase-draft.sh: position %s is not draftable (1-3 only; 4=operator review)\n' "${POSITION}" >&2
    exit 2 ;;
esac

# YAML frontmatter (agent.md §3 Output 2 schema) + body. expected_send_window is
# the orange-tier approval window; drafts-only mode holds at vault until W10-13.
cat <<DRAFT
---
draft_id: ${DRAFT_ID}
invoice_id: ${INVOICE_ID}
invoice_number: ${INVOICE_NUMBER}
contact_email: ${CONTACT_EMAIL}
subject: "${SUBJECT}"
amount_due: ${AMOUNT}
days_overdue: ${DAYS_OVERDUE}
escalation_ladder_position: ${POSITION}
expected_send_window: "orange-tier approval expected within 24h (drafts-only until autosend-bridge live)"
voice_score: unscored
voice_reason: no_corpus
---

Hi,

${OPENING}

${CLOSING}

Many thanks,
The accounts team
DRAFT
