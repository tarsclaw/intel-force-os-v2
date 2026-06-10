#!/usr/bin/env bash
# Sourcing Scout — §3 Markdown report renderer (agent.md §4 Step 10).
#
# Renders the agent.md §3 output shape (ranked candidates + source breakdown +
# diagnostic/exception list) from the run's proposal JSON to stdout.
# Deterministic: same proposal → same report. cycle.sh Step 10 captures stdout
# → vault on Gate A PASS, or /tmp partial draft on Gate A FAIL (--partial adds
# the partial-draft banner).
#
# The LinkedIn row renders "deferred to v1.1+; vendor pending" per the agent.md
# v1.0 disposition (Proxycurl shutdown) — never a scraped result.
#
# Usage: render-scout-report.sh <proposal_json> [--partial]

set -euo pipefail

if [[ $# -lt 1 || ! -f "${1:-}" ]]; then
  printf 'render-scout-report.sh: usage: render-scout-report.sh <proposal_json> [--partial]\n' >&2
  exit 2
fi
PROPOSAL="$1"
PARTIAL=0
[[ "${2:-}" == "--partial" ]] && PARTIAL=1

command -v jq >/dev/null 2>&1 || { printf 'render-scout-report.sh: jq required\n' >&2; exit 2; }

_q() { jq -r "$1" "${PROPOSAL}"; }

BRIEF_ID="$(_q '.brief_id // "n/a"')"
BRIEF_TITLE="$(_q '.brief.role // .brief_id // "Untitled brief"')"
TENANT="$(_q '.tenant_slug // "unknown"')"
N_CANDIDATES="$(_q '.candidates | length')"
GENERATED="$(date -u +%Y-%m-%d)"

printf '# Sourcing Scout — %s\n' "${BRIEF_TITLE}"
printf '**Generated:** %s  **Brief ID:** %s  **Tenant:** %s\n' "${GENERATED}" "${BRIEF_ID}" "${TENANT}"
printf '**Sources searched:** Bullhorn ATS + LinkedIn (deferred to v1.1+; vendor pending) + Reed + CV-Library\n'
printf '**Aggregate candidates:** %s (top 5-15 ranked)\n\n' "${N_CANDIDATES}"

if [[ "${PARTIAL}" -eq 1 ]]; then
  printf '> **PARTIAL DRAFT — Gate A failed.** This draft was held at /tmp and NOT written\n'
  printf '> to the vault. See the diagnostic + exception list below for the failure detail.\n\n'
fi

printf '## Brief context\n\n'
jq -r '
  .brief as $b
  | "Role: \($b.role // "n/a"). Location: \($b.location // "n/a"). " +
    "Salary band: \($b.salary_band // "n/a"). Work mode: \($b.work_mode // "n/a"). " +
    "Seniority: \($b.seniority // "n/a"). Key dimensions extracted: \($b.key_dims // "n/a")."
' "${PROPOSAL}"
printf '\n## Ranked candidates\n\n'

jq -r '
  .candidates
  | to_entries[]
  | .key as $i | .value as $c
  | "### \($i + 1). \($c.name) — confidence \($c.confidence)\n" +
    "**Source:** \(($c.sources // [$c.source]) | join(" + "))" +
    " | **Contact:** \($c.contact_method.type):\($c.contact_method.value)\n" +
    "**Match rationale:**\n\($c.rationale_body // $c.rationale_body_preview)\n" +
    "**Voice score:** \($c.voice_score)\(if $c.voice_reason then " (\($c.voice_reason))" else "" end)\n" +
    "**Profile refs:** \(($c.refs // []) | join(" | "))\n"
' "${PROPOSAL}"

printf '## Source breakdown\n\n'
printf '| Source | Queried | Candidates contributed | Note |\n|---|---|---|---|\n'
jq -r '
  .source_stats as $s
  | ["bullhorn", "linkedin", "reed", "cvlibrary"][]
  | . as $k
  | ($s[$k] // {queried: false, returned: 0, note: "no data"}) as $row
  | "| \($k) | \($row.queried) | \($row.returned) | \($row.note // "") |"
' "${PROPOSAL}"

printf '\n## Diagnostic + exception list\n\n'
if [[ "$(_q '.exceptions | length')" -gt 0 ]]; then
  jq -r '.exceptions[] | "- \(.)"' "${PROPOSAL}"
else
  printf -- '- No exceptions recorded this run.\n'
fi
printf -- '- Sources degraded this run: %s\n' "$(_q '(.sources_degraded // []) | if length == 0 then "none" else join(", ") end')"
