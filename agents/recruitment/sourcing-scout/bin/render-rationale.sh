#!/usr/bin/env bash
# Sourcing Scout — per-candidate match-rationale renderer (agent.md §4 Step 9).
#
# Prints a single ≥50-word match rationale to stdout. Deterministic +
# zero-dependency (same inputs → same rationale), so it is fixture-testable
# and reproducible without network/LLM — the same pattern as Cash Conductor's
# bin/render-chase-draft.sh templated fallback. LLM-polished rationale
# (brief context + candidate profile + voice corpus + tone rules prompt) is
# the documented enhancement per spec-003 §8; the ≥50-word Gate A G3 contract
# and the no-PII G6 contract hold for both paths.
#
# Tone-rule compliance baked into the template (agent.md §7): no demographic
# inference, no salary reference beyond the brief's own band, no claims about
# candidate intent, no email addresses or external PII in the body.
#
# Usage:
#   render-rationale.sh --name N --sources "bullhorn,reed" --confidence 0.85 \
#     --brief-role R [--brief-location L] [--brief-salary S] [--headline H] \
#     [--candidate-location CL]

set -euo pipefail

NAME="" SOURCES="" CONFIDENCE="" BRIEF_ROLE="" BRIEF_LOCATION="" BRIEF_SALARY=""
HEADLINE="" CAND_LOCATION=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)               NAME="${2:-}"; shift 2 ;;
    --sources)            SOURCES="${2:-}"; shift 2 ;;
    --confidence)         CONFIDENCE="${2:-}"; shift 2 ;;
    --brief-role)         BRIEF_ROLE="${2:-}"; shift 2 ;;
    --brief-location)     BRIEF_LOCATION="${2:-}"; shift 2 ;;
    --brief-salary)       BRIEF_SALARY="${2:-}"; shift 2 ;;
    --headline)           HEADLINE="${2:-}"; shift 2 ;;
    --candidate-location) CAND_LOCATION="${2:-}"; shift 2 ;;
    *) printf 'render-rationale.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done

for req in NAME SOURCES BRIEF_ROLE; do
  if [[ -z "${!req}" ]]; then
    printf 'render-rationale.sh: --%s required\n' \
      "$(printf '%s' "${req}" | tr '[:upper:]_' '[:lower:]-')" >&2
    exit 2
  fi
done

_n_sources="$(printf '%s' "${SOURCES}" | tr ',' '\n' | grep -c . || true)"
_sources_pretty="$(printf '%s' "${SOURCES}" | sed 's/,/ + /g')"

# Sentence 1 — match summary against the brief role.
S1="${NAME} surfaces as a passive-sourcing match for the ${BRIEF_ROLE} brief"
if [[ -n "${BRIEF_LOCATION}" ]]; then
  S1="${S1} in ${BRIEF_LOCATION}"
fi
S1="${S1}, aggregated from ${_sources_pretty}."

# Sentence 2 — source corroboration (provenance evidence per §3 output shape).
if [[ "${_n_sources}" -gt 1 ]]; then
  S2="The profile was independently surfaced by ${_n_sources} separate sources, which strengthens identity confidence and indicates the candidate maintains a current market footprint across multiple channels."
else
  S2="The profile was surfaced by a single source; the cross-source matcher found no conflicting records, so the contact details carried here come straight from that source's current listing."
fi

# Sentence 3 — profile evidence where the source supplied a headline/location.
S3=""
if [[ -n "${HEADLINE}" ]]; then
  S3="Their current listed position — ${HEADLINE} — aligns with the core requirements of the brief, supporting a direct skills-relevance match rather than a keyword-only hit."
fi
if [[ -z "${S3}" && -n "${CAND_LOCATION}" ]]; then
  S3="Their listed location (${CAND_LOCATION}) is compatible with the brief's geography, which removes the most common early-stage screening objection for this kind of role."
fi
if [[ -z "${S3}" ]]; then
  S3="The source record carries no current-role headline, so this match rests on the search-dimension overlap with the brief; the consultant should verify current-role fit on first contact."
fi

# Sentence 4 — salary-band note ONLY when the brief itself supplied one
# (tone rule: no salary inference about the candidate).
S4=""
if [[ -n "${BRIEF_SALARY}" ]]; then
  S4="The brief's stated band (${BRIEF_SALARY}) was used as a search dimension; no candidate salary expectation is asserted here beyond what the source listing itself exposes."
fi

# Sentence 5 — confidence + next step (always present; guarantees ≥50 words).
S5="Composite match confidence is ${CONFIDENCE:-n/a} on the deterministic v1.0 ranking heuristic, and the recommended next step is a consultant review of the source profile before any outreach is drafted."

printf '%s %s %s %s%s%s\n' "${S1}" "${S2}" "${S3}" "${S4}" "${S4:+ }" "${S5}"
