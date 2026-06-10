#!/usr/bin/env bash
# Janitor agent — validate.sh (Gate A enforcement; W6-7 LIVE)
#
# Status: LIVE per spec-001 §5 (W6-7 build slice) — all 7 checks enforced.
# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
#
# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
# hard-fail gate that runs BETWEEN write batch generation (cycle.sh Step 9
# proposal phase) and the actual @ifos/bullhorn write call. If any check fails,
# validate.sh exits non-zero + emits the mandatory validate_gate_a_fail action
# row + the per-class ESC_* escalation row to decision_log; the proposed write
# does NOT execute; cycle.sh skips that proposal + continues.
#
# Invocation contract:
#   bash validate.sh <write_proposal_json>
#
# Inputs:
#   - $1: path to a JSON file describing the proposed Bullhorn write. Shape:
#         {
#           "action_type": "bullhorn_candidate_dedupe" | "bullhorn_field_backfill" |
#                          "bullhorn_note_attach",
#           "entity_type": "candidate" | "contractor" | "contact" | "client",
#           "primary_id": <bullhorn_id>,
#           "merge_target_id": <bullhorn_id>,    // only for dedupe action_type
#           "confidence": <float 0.0-1.0>,       // only for dedupe action_type
#           "match_dimensions": ["name", "email", "phone", "linkedin"],
#           "last_activity_days": <int>,         // dedupe: MIN(days) across the pair
#           "voice_score": <float|"unscored">,   // only for note_attach action_type
#           "narrative_body": "...",             // only for note_attach action_type
#           "field_changes": { "<field>": "<new_value>" },  // backfill
#           "source": "companies_house" | "linkedin" | "derivation",  // backfill
#           "source_confidence": <float 0.0-1.0> // backfill
#         }
#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_AGENT_DIR,
#          CTX_JANITOR_DEDUP_THRESHOLD (default 0.85),
#          CTX_FIRM_DOMAIN_WHITELIST (G6 boundary; conservative default),
#          CTX_JANITOR_BATCH_INDEX (G7; 1-based position in this run's batch)
#
# Exit codes:
#   0  All Gate A checks pass; cycle.sh proceeds to actual write
#   1  At least one check failed; validate_gate_a_fail + ESC_* rows emitted;
#      cycle.sh skips this write
#   2  validate.sh invocation error (bad args, missing file, etc.)
#
# Checks (per agent.md §5 Gate A + spec-001 §5):
#   G1 — Bullhorn auth refresh succeeded in Step 1 (no stale-token writes).
#         Hard-fails on token_state:failed; a degraded/absent state (creds
#         founder-gated → no live write possible; cycle.sh defers transport)
#         is a WARN — there is no stale-token risk when no token exists.
#   G2 — Dedup proposal: confidence ≥ CTX_JANITOR_DEDUP_THRESHOLD (default 0.85;
#         per ULTRAPLAN A2 line 510 + tenant override range [0.75, 0.95])
#         → ESC_AGENT_OUTPUT_SHAPE
#   G3 — Dedup proposal: NEITHER record has Bullhorn activity in last 90 days
#         (per ULTRAPLAN A2 line 510 verbatim). Recent (or UNKNOWN) activity →
#         REJECT the auto-write + ESC_DUPLICATE_DETECTED (SUCCESS-path Telegram
#         approval gate per catalogue §2.5; NOT a Gate A failure code).
#   G4 — Field-backfill: source_confidence ≥0.7 (CH 404 / LinkedIn empty / no
#         derivation source → fail) → ESC_AGENT_OUTPUT_SHAPE
#   G5 — Tacit-note narrative: voice classifier ≥0.75. Hard-when-scored;
#         warn-when-unscored (empty voice_corpus → unscored/no_corpus per CC
#         honesty precedent) → ESC_VOICE_DRIFT
#   G6 — No PII outside firm boundary in tacit-note narratives (regex pass)
#         → ESC_PII_LEAKAGE_RISK (BLOCKING; precedence over all other classes)
#   G7 — Write batch size: this proposal's batch index ≤ 100/min defensive cap
#         (per agent.md §5) → ESC_AGENT_OUTPUT_SHAPE (spec-001 §5 routing)

set -uo pipefail

# ────────────────────────────────────────────────────────────────────────
# Pre-flight
# ────────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  printf 'janitor/validate.sh: usage: validate.sh <write_proposal_json>\n' >&2
  exit 2
fi

readonly PROPOSAL="$1"

if [[ ! -f "${PROPOSAL}" ]]; then
  printf 'validate.sh: proposal not found at %s\n' "${PROPOSAL}" >&2
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
command -v jq >/dev/null 2>&1 || { printf 'validate.sh: jq required\n' >&2; exit 2; }
jq -e . "${PROPOSAL}" >/dev/null 2>&1 || { printf 'validate.sh: proposal is not valid JSON\n' >&2; exit 2; }

# Resolve _shared/ helpers (4-candidate fallback; matches sibling agents
# per smoke-hotfix commit d7d52c5).
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

# Dominant failure class for ESC routing. First hard fail sets it;
# ESC_PII_LEAKAGE_RISK (blocking) takes precedence over every other class
# (Scout Gate A precedence precedent).
ESC_CLASS=""
_set_esc() {
  if [[ "$1" == "ESC_PII_LEAKAGE_RISK" ]]; then
    ESC_CLASS="ESC_PII_LEAKAGE_RISK"
  else
    ESC_CLASS="${ESC_CLASS:-$1}"
  fi
}

# Dedup threshold env (default per ULTRAPLAN A2 line 510 verbatim; per-tenant
# override range [0.75, 0.95] enforced by validate_tenant_adapters_config_v0_3
# trigger on tenant_adapters.config.janitor_dedup_threshold)
readonly DEDUP_THRESHOLD="${CTX_JANITOR_DEDUP_THRESHOLD:-0.85}"

_p() { jq -r "$1 // empty" "${PROPOSAL}" 2>/dev/null; }
ACTION_TYPE="$(_p '.action_type')"
PRIMARY_ID="$(_p '.primary_id')"

case "${ACTION_TYPE}" in
  bullhorn_candidate_dedupe|bullhorn_field_backfill|bullhorn_note_attach) : ;;
  *)
    printf 'validate.sh: unknown proposal action_type %s\n' "${ACTION_TYPE:-<empty>}" >&2
    exit 2 ;;
esac

# ────────────────────────────────────────────────────────────────────────
# G1 — Bullhorn auth refresh succeeded in Step 1 (no stale-token writes)
# Re-queries decision_log for this session's bullhorn_auth_refresh row.
# token_state failed → HARD FAIL (stale-token write risk) + ESC_BULLHORN_AUTH.
# token_state absent/degraded (creds founder-gated) → WARN: no live Bullhorn
# write can occur (cycle.sh records write_state:deferred), so there is no
# stale-token risk to gate.
# ────────────────────────────────────────────────────────────────────────

_g1_state=""
if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
  _g1_row="$(psql "${IFOS_DB_URL}" -tAq -v ON_ERROR_STOP=1 \
    --set=tenant="${CTX_TENANT_SLUG}" <<'SQL' 2>/dev/null | head -1 || true
BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT reason FROM decision_log
WHERE tenant_slug = :'tenant' AND agent_name = 'janitor'
  AND phase = 'output' AND payload->>'output_type' = 'bullhorn_auth_refresh'
  AND created_at > now() - interval '10 minutes'
ORDER BY id DESC LIMIT 1;
COMMIT;
SQL
)"
  _g1_state="$(printf '%s' "${_g1_row}" | grep -oE 'bullhorn_token_state:[a-z_]+' | cut -d: -f2 || true)"
fi
if [[ "${_g1_state}" == "failed" ]]; then
  _fail "G1: Bullhorn auth refresh FAILED this session — stale-token write blocked"
  _set_esc "ESC_BULLHORN_AUTH"
elif [[ "${_g1_state}" == "ok" || "${_g1_state}" == "fixture" ]]; then
  _ok "G1: Bullhorn auth refresh fresh (token_state:${_g1_state})"
else
  _warn "G1: Bullhorn auth state '${_g1_state:-no_recent_row}' — no live token (creds founder-gated); write transport defers, no stale-token risk"
fi

# ────────────────────────────────────────────────────────────────────────
# G2 — Dedup confidence ≥ threshold (default 0.85; per-tenant override range)
# Per ULTRAPLAN A2 line 510. Sub-0.70 silently drops in the Step 3 matcher
# (no proposal reaches here). 0.70-0.85 → review-band (held upstream, never
# proposed for auto-write); a proposal below threshold reaching this gate is
# an output-shape violation.
# ────────────────────────────────────────────────────────────────────────

if [[ "${ACTION_TYPE}" == "bullhorn_candidate_dedupe" ]]; then
  _g2_conf="$(_p '.confidence')"
  if [[ "${_g2_conf}" =~ ^[0-9]+(\.[0-9]+)?$ ]] \
     && awk -v c="${_g2_conf}" -v t="${DEDUP_THRESHOLD}" 'BEGIN{exit !(c>=t)}'; then
    _ok "G2: dedup confidence ${_g2_conf} ≥ ${DEDUP_THRESHOLD}"
  else
    _fail "G2: dedup confidence '${_g2_conf:-missing}' < ${DEDUP_THRESHOLD}"
    _set_esc "ESC_AGENT_OUTPUT_SHAPE"
  fi
else
  _ok "G2: N/A (not a dedupe proposal)"
fi

# ────────────────────────────────────────────────────────────────────────
# G3 — No Bullhorn activity in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
# Recent activity = placement / interview / note in last 90d on EITHER side
# (proposal carries the pair MIN as last_activity_days). Recent OR UNKNOWN →
# REJECT this auto-write + ESC_DUPLICATE_DETECTED (SUCCESS-path Telegram
# approval gate per catalogue §2.5 — the proposal is not erroneous; the
# operator decides).
# ────────────────────────────────────────────────────────────────────────

if [[ "${ACTION_TYPE}" == "bullhorn_candidate_dedupe" ]]; then
  _g3_days="$(_p '.last_activity_days')"
  if [[ "${_g3_days}" =~ ^[0-9]+$ && "${_g3_days}" -ge 90 ]]; then
    _ok "G3: no Bullhorn activity in last 90d (min ${_g3_days}d)"
  else
    _fail "G3: pair has recent/unknown Bullhorn activity (last_activity_days='${_g3_days:-unknown}') — auto-write rejected; operator approval gate fires"
    _set_esc "ESC_DUPLICATE_DETECTED"
  fi
else
  _ok "G3: N/A (not a dedupe proposal)"
fi

# ────────────────────────────────────────────────────────────────────────
# G4 — Field-backfill source confidence ≥0.7
# CH 404 / LinkedIn empty / no derivation source → low-confidence; reject.
# ────────────────────────────────────────────────────────────────────────

if [[ "${ACTION_TYPE}" == "bullhorn_field_backfill" ]]; then
  _g4_conf="$(_p '.source_confidence')"
  _g4_src="$(_p '.source')"
  if [[ "${_g4_conf}" =~ ^[0-9]+(\.[0-9]+)?$ ]] \
     && awk -v c="${_g4_conf}" 'BEGIN{exit !(c>=0.7)}'; then
    _ok "G4: backfill source_confidence ${_g4_conf} ≥ 0.7 (source:${_g4_src:-unknown})"
  else
    _fail "G4: backfill source_confidence '${_g4_conf:-missing}' < 0.7 (source:${_g4_src:-unknown})"
    _set_esc "ESC_AGENT_OUTPUT_SHAPE"
  fi
else
  _ok "G4: N/A (not a backfill proposal)"
fi

# ────────────────────────────────────────────────────────────────────────
# G5 — Tacit-note voice classifier ≥0.75
# Per agent.md §7. Hard-when-scored; warn-when-unscored (empty tenant
# voice_corpus → unscored/no_corpus, never a faked number — CC precedent).
# ────────────────────────────────────────────────────────────────────────

if [[ "${ACTION_TYPE}" == "bullhorn_note_attach" ]]; then
  _g5_score="$(_p '.voice_score')"
  if [[ "${_g5_score}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    if awk -v s="${_g5_score}" 'BEGIN{exit !(s>=0.75)}'; then
      _ok "G5: tacit-note voice score ${_g5_score} ≥ 0.75"
    else
      _fail "G5: tacit-note voice score ${_g5_score} < 0.75 (after retries)"
      _set_esc "ESC_VOICE_DRIFT"
    fi
  else
    _warn "G5: voice unscored (${_g5_score:-none}) — no tenant voice_corpus; threshold unenforceable (documented enhancement)"
  fi
else
  _ok "G5: N/A (not a note proposal)"
fi

# ────────────────────────────────────────────────────────────────────────
# G6 — No PII outside firm boundary in tacit-note narrative
# Regex pass against narrative_body; email addresses NOT on the tenant
# firm-domain whitelist → fail + ESC_PII_LEAKAGE_RISK (blocking; operator +
# ifos_oncall routing; precedence over every other failure class).
# ────────────────────────────────────────────────────────────────────────

if [[ "${ACTION_TYPE}" == "bullhorn_note_attach" ]]; then
  _g6_body="$(_p '.narrative_body')"
  _g6_emails="$(printf '%s' "${_g6_body}" \
    | grep -oiE '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' | sort -u || true)"
  _g6_ext=0
  if [[ -n "${_g6_emails}" ]]; then
    _g6_allow="${CTX_FIRM_DOMAIN_WHITELIST:-}"
    while IFS= read -r _em; do
      [[ -z "${_em}" ]] && continue
      _dom="$(printf '%s' "${_em##*@}" | tr '[:upper:]' '[:lower:]')"
      _hit=0
      for _allowed in ${_g6_allow//,/ }; do
        [[ -n "${_allowed}" && "${_dom}" == "$(printf '%s' "${_allowed}" | tr '[:upper:]' '[:lower:]')" ]] && _hit=1
      done
      [[ "${_hit}" -eq 0 ]] && _g6_ext=1
    done <<<"${_g6_emails}"
  fi
  if [[ "${_g6_ext}" -eq 1 ]]; then
    _fail "G6: narrative contains email address(es) outside the firm boundary (whitelist: ${CTX_FIRM_DOMAIN_WHITELIST:-<unset>})"
    _set_esc "ESC_PII_LEAKAGE_RISK"
  else
    _ok "G6: no PII outside firm boundary in narrative"
  fi
else
  _ok "G6: N/A (not a note proposal)"
fi

# ────────────────────────────────────────────────────────────────────────
# G7 — Write batch size sanity (this proposal's batch index ≤ 100/min cap)
# Defensive per agent.md §5; routing ESC_AGENT_OUTPUT_SHAPE per spec-001 §5.
# Cross-checks @ifos/bullhorn's own per-corp 600/min hard limiter — the agent
# cap (100/min) is deliberately far inside it (agent.md §9 Q3: Bullhorn's
# published limit is undocumented; conservative until Sub-decision B answers).
# ────────────────────────────────────────────────────────────────────────

_g7_idx="${CTX_JANITOR_BATCH_INDEX:-1}"
if [[ "${_g7_idx}" =~ ^[0-9]+$ && "${_g7_idx}" -le 100 ]]; then
  _ok "G7: batch index ${_g7_idx} ≤ 100/min cap"
else
  _fail "G7: batch index '${_g7_idx}' exceeds the 100/min defensive cap — remainder defers to the next run"
  _set_esc "ESC_AGENT_OUTPUT_SHAPE"
fi

# ────────────────────────────────────────────────────────────────────────
# Verdict + audit-row emission
# ────────────────────────────────────────────────────────────────────────

printf '\nJanitor validate Gate A: '
if [[ ${#FAILURES[@]} -gt 0 ]]; then
  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
  # Per-failure-class routing (agent.md §5/§6):
  #   G1 → ESC_BULLHORN_AUTH (blocking) · G2/G4/G7 → ESC_AGENT_OUTPUT_SHAPE
  #   G3 → ESC_DUPLICATE_DETECTED (SUCCESS-path approval gate)
  #   G5 → ESC_VOICE_DRIFT · G6 → ESC_PII_LEAKAGE_RISK (blocking; precedence)
  _v_hash="$(shasum -a 256 "${PROPOSAL}" 2>/dev/null | cut -c1-16)"
  [[ -z "${_v_hash}" ]] && _v_hash="proposal-${PRIMARY_ID:-unknown}"
  hh_decision_action "validate_gate_a_fail" "tenant:${CTX_TENANT_SLUG}" "${_v_hash}" \
    "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}; agent_name:janitor; action_type:${ACTION_TYPE}; primary_id:${PRIMARY_ID:-unknown}; failures:${#FAILURES[@]}; first:${FAILURES[0]}" || true
  if [[ "${ESC_CLASS:-}" == "ESC_DUPLICATE_DETECTED" ]]; then
    # G3 hold — emit the amended catalogue §2.5 payload shape (entity ids,
    # confidence, match basis, hold reason). G3 only fires on recent/unknown
    # activity, so hold_reason is always the recency class here.
    autosend_escalate "ESC_DUPLICATE_DETECTED" "agent=janitor" \
      "tenant=${CTX_TENANT_SLUG}" "action_type=${ACTION_TYPE}" \
      "entity_a_id=${PRIMARY_ID:-unknown}" "entity_b_id=$(_p '.merge_target_id')" \
      "entity_type=$(_p '.entity_type')" "confidence_score=$(_p '.confidence')" \
      "match_basis=$(jq -r '(.match_dimensions // []) | join("+")' "${PROPOSAL}" 2>/dev/null)" \
      "hold_reason=recency_hold_90d" "failures=${#FAILURES[@]}" \
      "proposal=${PROPOSAL}"
  else
    autosend_escalate "${ESC_CLASS:-ESC_AGENT_OUTPUT_SHAPE}" "agent=janitor" \
      "tenant=${CTX_TENANT_SLUG}" "action_type=${ACTION_TYPE}" \
      "primary_id=${PRIMARY_ID:-unknown}" "failures=${#FAILURES[@]}" \
      "proposal=${PROPOSAL}"
  fi
  exit 1
fi
printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
exit 0
