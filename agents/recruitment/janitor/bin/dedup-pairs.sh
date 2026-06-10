#!/usr/bin/env bash
# Janitor — duplicate-pair fuzzy matcher (agent.md §4 Steps 3-4; spec-001 §4).
#
# Scores every record pair on (name, email, phone, linkedin_url) with the
# spec-001 weights (name·0.3 + email·0.4 + phone·0.2 + linkedin·0.1) and
# classifies each pair into the spec-001 §4 band→action table:
#   auto   — confidence ≥ threshold (default 0.85) AND neither record has
#            Bullhorn activity in the last 90 days (per ULTRAPLAN A2 line 510)
#   review — confidence in [0.70, threshold) OR ≥ threshold with recent (or
#            UNKNOWN) activity → held for synchronous Telegram approval via
#            ESC_DUPLICATE_DETECTED (SUCCESS path; NOT a Gate A failure)
#   drop   — confidence in (0, 0.70) → silently dropped (no ESC fire)
#
# Scoring semantics (Sourcing Scout precedent, accepted at the Scout review;
# reconciled cross-agent per spec-001 §9 / Scout deviation 1): a literal
# absolute-sum can never reach 0.85 when one record carries phone and the
# other linkedin (name+email caps at 0.7), so the score normalises by the
# COMPARABLE weight (dimensions where BOTH records carry a value) and requires
# at least one STRONG identifier match (email | phone | linkedin) — two
# records sharing only a name never pair. Same weights, same 0.85 threshold.
#
# Normalisation: name → lowercase + collapsed whitespace; email → lowercase;
# phone → digits only, last 10 (UK +44/0 prefix equivalence); linkedin →
# lowercase, protocol/www/trailing-slash stripped.
#
# Activity model: each record carries last_activity_days (int) — days since
# the record's last Bullhorn activity (placement / interview / note). Records
# with UNKNOWN activity (field absent/null) are treated as RECENT, i.e. held
# for review, never auto-merged (conservative per agent.md §9 gotcha 2:
# "dedup is hard; start conservative"). Live activity hydration comes from
# the Bullhorn scan when creds land; fixtures seed the field explicitly.
#
# Auto-band pairs are additionally greedily de-overlapped (confidence-desc):
# each record participates in at most ONE auto merge per run; an auto pair
# whose record was already claimed degrades to review (operator decides).
#
# Input  (stdin): JSON array of records
#                 [{entity_id, name, email, phone, linkedin_url,
#                   last_activity_days}, ...]
# Output (stdout): {"auto":N, "review":N, "dropped":N,
#                   "pairs":[{primary_id, target_id, confidence, dims:[...],
#                             band:"auto|review|drop", reason}, ...]}
#                  (drop-band pairs are counted but not listed)
#
# Deterministic + zero-network: pure jq over stdin. Fixture-testable.
#
# Usage: dedup-pairs.sh [--threshold 0.85] [--activity-window-days 90]

set -euo pipefail

THRESHOLD="0.85"
ACTIVITY_WINDOW="90"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold)            THRESHOLD="${2:-0.85}"; shift 2 ;;
    --activity-window-days) ACTIVITY_WINDOW="${2:-90}"; shift 2 ;;
    *)                      printf 'dedup-pairs.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done

command -v jq >/dev/null 2>&1 || { printf 'dedup-pairs.sh: jq required\n' >&2; exit 2; }

jq --argjson thr "${THRESHOLD}" --argjson win "${ACTIVITY_WINDOW}" '
  def nname:  ((.name // "")  | ascii_downcase | gsub("\\s+"; " ") | gsub("(^ +)|( +$)"; ""));
  def nemail: ((.email // "") | ascii_downcase | gsub("\\s"; ""));
  def nphone: ((.phone // "") | gsub("[^0-9]"; "") | if length > 10 then .[-10:] else . end);
  def nli:    ((.linkedin_url // "") | ascii_downcase
               | sub("^https?://"; "") | sub("^www\\."; "") | sub("/+$"; ""));

  # Pairwise score over dims both records carry; matched-weight / comparable-
  # weight; 0 unless at least one strong identifier (email|phone|linkedin)
  # matched. Also returns the matched dimension names.
  def score($a; $b):
    [ {n: "name",     w: 0.3, av: ($a|nname),  bv: ($b|nname),  strong: false},
      {n: "email",    w: 0.4, av: ($a|nemail), bv: ($b|nemail), strong: true},
      {n: "phone",    w: 0.2, av: ($a|nphone), bv: ($b|nphone), strong: true},
      {n: "linkedin", w: 0.1, av: ($a|nli),    bv: ($b|nli),    strong: true} ]
    | reduce .[] as $d ({comp: 0, match: 0, strong: false, dims: []};
        if ($d.av != "" and $d.bv != "")
        then .comp += $d.w
             | if $d.av == $d.bv
               then .match += $d.w | .strong = (.strong or $d.strong) | .dims += [$d.n]
               else . end
        else . end)
    | if (.comp > 0 and .strong)
      then {confidence: ((.match / .comp * 100 | round) / 100), dims: .dims}
      else {confidence: 0, dims: []} end;

  # Activity recency: UNKNOWN (absent/null/non-number) treated as recent
  # (conservative — never auto-merge on unknown activity).
  def act($r): ($r.last_activity_days? // null) as $d
    | if ($d | type) == "number" then $d else -1 end;
  def stale($r): act($r) >= $win and act($r) >= 0;

  . as $pool
  | [ range(0; $pool | length) as $i
      | range($i + 1; $pool | length) as $j
      | $pool[$i] as $a | $pool[$j] as $b
      | score($a; $b) as $s
      | select($s.confidence > 0)
      | {
          primary_id: (if ($a.entity_id | tostring) <= ($b.entity_id | tostring)
                       then $a.entity_id else $b.entity_id end | tostring),
          target_id:  (if ($a.entity_id | tostring) <= ($b.entity_id | tostring)
                       then $b.entity_id else $a.entity_id end | tostring),
          confidence: $s.confidence,
          dims: $s.dims,
          a_stale: stale($a), b_stale: stale($b),
          a_act: act($a), b_act: act($b)
        } ]
  | map(
      if .confidence >= $thr and .a_stale and .b_stale
      then . + {band: "auto", reason: "confidence_\(.confidence)_no_90d_activity"}
      elif .confidence >= $thr
      then . + {band: "review",
                reason: (if (.a_act >= 0 and .a_act < $win) or (.b_act >= 0 and .b_act < $win)
                         then "recent_activity_days:\([(if .a_act >= 0 then .a_act else 99999 end), (if .b_act >= 0 then .b_act else 99999 end)] | min)"
                         else "activity_unknown_conservative_hold" end)}
      elif .confidence >= 0.70
      then . + {band: "review", reason: "confidence_band_0.70_to_threshold"}
      else . + {band: "drop", reason: "below_0.70"}
      end )
  | sort_by(-.confidence)
  # Greedy de-overlap for the auto band: each entity in at most one auto merge.
  | reduce .[] as $p ({used: [], pairs: []};
      if $p.band == "auto"
      then if ((.used | index($p.primary_id)) == null and (.used | index($p.target_id)) == null)
           then .used += [$p.primary_id, $p.target_id] | .pairs += [$p]
           else .pairs += [$p + {band: "review", reason: "auto_degraded_record_already_claimed_this_run"}]
           end
      else .pairs += [$p]
      end )
  | .pairs
  | {
      auto:    ([.[] | select(.band == "auto")]   | length),
      review:  ([.[] | select(.band == "review")] | length),
      dropped: ([.[] | select(.band == "drop")]   | length),
      pairs:   [.[] | select(.band != "drop") | del(.a_stale, .b_stale)]
    }
'
