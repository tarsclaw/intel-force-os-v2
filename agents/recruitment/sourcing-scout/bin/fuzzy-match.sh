#!/usr/bin/env bash
# Sourcing Scout — cross-source fuzzy matcher (agent.md §4 Step 7).
#
# CARRIED COPY of the Janitor fuzzy matcher (spec-001 §4 Step 3: weights
# name·0.3 + email·0.4 + phone·0.2 + linkedin·0.1; threshold ≥0.85). The
# Janitor bundle has not landed its helper yet — per spec-003 §9 this bundle
# carries its own copy; RECONCILE AT REVIEW when the Janitor matcher lands.
#
# Scoring note (documented for the reconciliation): a literal absolute-sum of
# the weights can never reach 0.85 for the common cross-job-board case where
# one source carries phone and the other carries linkedin_url (name+email
# = 0.7). This implementation therefore normalises by the COMPARABLE weight
# (dimensions where BOTH records carry a value) and additionally requires at
# least one STRONG identifier match (email | phone | linkedin) so two records
# sharing only a name never merge. Same weights, same 0.85 threshold.
#
# Normalisation: name → lowercase + collapsed whitespace; email → lowercase;
# phone → digits only, last 10 (UK +44/0 prefix equivalence); linkedin →
# lowercase, protocol/www/trailing-slash stripped.
#
# Input  (stdin): JSON array of unified candidates
#                 [{ref, source, name, email, phone, linkedin_url, ...}, ...]
# Output (stdout): {"pre_dedupe": N, "post_dedupe": M, "candidates": [...]}
#                 each output candidate carries sources[] + refs[] provenance
#                 + confidence (deterministic v1.0 rank heuristic: base 0.55
#                 + 0.15 per extra source + contactability bonuses, cap 0.97;
#                 LLM ranking is the documented enhancement per spec-003 §8).
#
# Deterministic + zero-network: pure jq over stdin. Fixture-testable.
#
# Usage: fuzzy-match.sh [--threshold 0.85]

set -euo pipefail

THRESHOLD="0.85"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold) THRESHOLD="${2:-0.85}"; shift 2 ;;
    *)           printf 'fuzzy-match.sh: unknown arg %s\n' "$1" >&2; exit 2 ;;
  esac
done

command -v jq >/dev/null 2>&1 || { printf 'fuzzy-match.sh: jq required\n' >&2; exit 2; }

jq --argjson thr "${THRESHOLD}" '
  def nname:  ((.name // "")  | ascii_downcase | gsub("\\s+"; " ") | gsub("(^ +)|( +$)"; ""));
  def nemail: ((.email // "") | ascii_downcase | gsub("\\s"; ""));
  def nphone: ((.phone // "") | gsub("[^0-9]"; "") | if length > 10 then .[-10:] else . end);
  def nli:    ((.linkedin_url // "") | ascii_downcase
               | sub("^https?://"; "") | sub("^www\\."; "") | sub("/+$"; ""));

  # Pairwise score: matched-weight / comparable-weight over dims both records
  # carry; 0 unless at least one strong identifier (email|phone|linkedin) matched.
  def score($a; $b):
    [ {w: 0.3, av: ($a|nname),  bv: ($b|nname),  strong: false},
      {w: 0.4, av: ($a|nemail), bv: ($b|nemail), strong: true},
      {w: 0.2, av: ($a|nphone), bv: ($b|nphone), strong: true},
      {w: 0.1, av: ($a|nli),    bv: ($b|nli),    strong: true} ]
    | reduce .[] as $d ({comp: 0, match: 0, strong: false};
        if ($d.av != "" and $d.bv != "")
        then .comp += $d.w
             | if $d.av == $d.bv
               then .match += $d.w | .strong = (.strong or $d.strong)
               else . end
        else . end)
    | if (.comp > 0 and .strong) then (.match / .comp) else 0 end;

  # Fill empty contact fields on the cluster representative from a new member.
  def merge_fields($r; $c):
    $r
    | .email        = (if ((.email // "") == "")        then $c.email        else .email end)
    | .phone        = (if ((.phone // "") == "")        then $c.phone        else .phone end)
    | .linkedin_url = (if ((.linkedin_url // "") == "") then $c.linkedin_url else .linkedin_url end)
    | .headline     = (if ((.headline // "") == "")     then $c.headline     else .headline end)
    | .location     = (if ((.location // "") == "")     then $c.location     else .location end);

  . as $input
  | reduce $input[] as $c ([];
      ( [ to_entries[] | select(score(.value.rep; $c) >= $thr) | .key ] | .[0] ) as $idx
      | if $idx == null
        then . + [ { rep: $c, members: [$c] } ]
        else .[$idx].members += [$c]
             | .[$idx].rep = merge_fields(.[$idx].rep; $c)
        end )
  | map(
      ( [.members[].source] | unique ) as $sources
      | .rep + {
          sources: $sources,
          refs:    ([.members[].ref] | unique),
          # Deterministic v1.0 confidence heuristic (LLM ranking = documented
          # enhancement): multi-source corroboration + contactability.
          confidence: ( 0.55
                        + 0.15 * (($sources | length) - 1)
                        + (if ((.rep.email // "") != "")        then 0.05 else 0 end)
                        + (if ((.rep.phone // "") != "")        then 0.05 else 0 end)
                        + (if ((.rep.linkedin_url // "") != "") then 0.03 else 0 end)
                      | if . > 0.97 then 0.97 else . end | (. * 100 | round) / 100 )
        } )
  | { pre_dedupe: ($input | length), post_dedupe: length, candidates: . }
'
