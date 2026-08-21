#!/usr/bin/env bash
# verify-test-baseline.sh — the transfer acceptance gate, made executable.
#
# TRANSFER-MAP.md §8 condition 2: "a package has moved correctly when its own
# suite passes at the same count." This script is that check.
#
# Baseline captured 2026-08-21 in CortexOS @ 90df272, all suites green.
# Run it here to confirm the baseline still holds; run it in the new repo after
# each package lands. A package that arrives with fewer passing tests than its
# baseline has NOT moved correctly, regardless of whether the suite is green —
# silently skipped tests are the failure mode this exists to catch.
#
# Usage:  bash verify-test-baseline.sh [scope-prefix]
#         scope-prefix defaults to @ifos (use @core in the new repo)
set -uo pipefail
SCOPE="${1:-@ifos}"

# package|expected_passed|expected_skipped
BASELINE="
approval-routing|86|0
autosend-bridge-telegram|34|0
web-scraper|12|0
bullhorn|52|0
companies-house|13|0
cv-library|20|0
granola|33|0
open-banking|32|3
quickbooks|27|3
reed|18|0
workos|24|0
xero|29|3
"

fail=0; total_p=0; total_s=0
printf '%-28s %-12s %-12s %s\n' PACKAGE EXPECTED ACTUAL VERDICT
printf '%.0s-' {1..70}; echo

while IFS='|' read -r pkg exp_p exp_s; do
  [ -z "$pkg" ] && continue
  out=$(timeout 300 pnpm --filter "${SCOPE}/${pkg}" test 2>&1 | tail -25)
  line=$(echo "$out" | grep -E '^ *Tests +[0-9]' | tail -1)
  act_p=$(echo "$line" | grep -oE '[0-9]+ passed' | head -1 | grep -oE '[0-9]+')
  act_s=$(echo "$line" | grep -oE '[0-9]+ skipped' | head -1 | grep -oE '[0-9]+')
  act_p="${act_p:-0}"; act_s="${act_s:-0}"
  if [ "$act_p" -eq "$exp_p" ] && [ "$act_s" -eq "$exp_s" ]; then v="PASS"
  elif [ "$act_p" -gt "$exp_p" ]; then v="PASS (grew +$((act_p-exp_p)))"
  else v="FAIL"; fail=$((fail+1)); fi
  total_p=$((total_p+act_p)); total_s=$((total_s+act_s))
  printf '%-28s %-12s %-12s %s\n' "$pkg" "${exp_p}p/${exp_s}s" "${act_p}p/${act_s}s" "$v"
done <<< "$BASELINE"

printf '%.0s-' {1..70}; echo
echo "TOTAL: ${total_p} passed, ${total_s} skipped   (baseline: 380 passed, 9 skipped)"
[ "$fail" -eq 0 ] && { echo "BASELINE HELD"; exit 0; } || { echo "REGRESSION IN ${fail} PACKAGE(S)"; exit 1; }
