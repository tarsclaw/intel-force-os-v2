#!/usr/bin/env bash
# Scribe — Step 10 SLA bucket classifier (agent.md §4 Step 10; catalogue §2.10).
#
# Pure computation (no DB, no side effects) so the threshold logic is unit-
# testable by scripts/run-scribe-sla-test.sh and shared verbatim by cycle.sh.
#
# Thresholds (agent.md §4 Step 10 — two DIFFERENT scopes, both kept):
#   master brief §8.2 10-min product promise   → Gate B aggregation, no ESC
#   catalogue ESC_SCRIBE_SLA_MISS alerting     → >30min summary_render OR >1h note_attach
#
#   elapsed ≤ 300        under_5_min          (Gate B target met)
#   300 < elapsed ≤ 600  info_5_10_min        (info; still under product promise)
#   600 < elapsed ≤ 1800 gate_b_10min_miss    (counts against Gate B 90%; NO ESC)
#   1800 < elapsed ≤ 3600 summary_render_miss (ESC_SCRIBE_SLA_MISS sla_type=summary_render)
#   elapsed > 3600       note_attach_miss     (ESC_SCRIBE_SLA_MISS sla_type=note_attach)
#
# Usage:  sla-class.sh --elapsed <seconds>
# Output: "<class>|<esc_code>|<sla_type>"  (esc_code/sla_type empty when no ESC fires)

set -euo pipefail

ELAPSED=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --elapsed) ELAPSED="${2:-}"; shift 2 ;;
    *) printf 'sla-class.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done
if [[ -z "${ELAPSED}" || ! "${ELAPSED}" =~ ^[0-9]+$ ]]; then
  printf 'sla-class.sh: --elapsed <non-negative integer seconds> required\n' >&2
  exit 2
fi

if   (( ELAPSED <= 300 ));  then printf 'under_5_min||\n'
elif (( ELAPSED <= 600 ));  then printf 'info_5_10_min||\n'
elif (( ELAPSED <= 1800 )); then printf 'gate_b_10min_miss||\n'
elif (( ELAPSED <= 3600 )); then printf 'summary_render_miss|ESC_SCRIBE_SLA_MISS|summary_render\n'
else                             printf 'note_attach_miss|ESC_SCRIBE_SLA_MISS|note_attach\n'
fi
