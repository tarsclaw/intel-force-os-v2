# Codex Round 3 remediation summary

**Run date:** 2026-05-22
**Run directory:** `logs/codex-ratification/round-3-remediation/`

## §1 — Headline counts

- Round 3 corrected subset: 10 RATIFIED / 0 REJECTED of 10
- Founder-escalated annotations: 3 items (D1, D2/D3, D3)
- Hard ceiling: Round 3 is the last automated round under master brief §10.3

## §2 — Per-fix verification table

| Fix # | File | Verification command | Result |
|---:|---|---|---|
| 1 | `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` | `grep -n "consrc" ... || true` | PASS: 0 hits |
| 2 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | `grep -c "ALTER COLUMN original_text DROP NOT NULL" ...` | PASS: 1 |
| 2 | `docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql` | `grep -c "ALTER COLUMN original_text SET NOT NULL" ...` | PASS: 1 |
| 3 | `scripts/ifos-pii-purge.sh` | `shellcheck -s bash scripts/ifos-pii-purge.sh` | PASS |
| 3 | `scripts/ifos-pii-purge.sh` | `grep -c "BEGIN;" scripts/ifos-pii-purge.sh` | PASS: 3 |
| 4 | `scripts/run-tenancy-audit.sh` | `shellcheck -s bash scripts/run-tenancy-audit.sh` | PASS |
| 4 | `scripts/run-tenancy-audit.sh` | `grep -c "ROLLBACK" scripts/run-tenancy-audit.sh` | PASS: 1 |
| 5 | `agents/_shared/hook-helpers.sh`, `agents/_shared/voice-loader.sh`, `scripts/run-codex-ratification.sh` | `shellcheck -s bash ...` | PASS |
| 5 | Helper test suites | `bash agents/_shared/tests/test-hook-helpers.sh`; `bash agents/_shared/tests/test-voice-loader.sh` | PASS: 20/20 + 9/9 |
| 5 | Renderer regression | `npm test -- --run` in `packages/agent-renderer` | PASS: 30/30 |
| 6 | `docs/decisions/bullhorn-integration-path.md` | Manual diff/read | PASS: line 95 narrowed + §1.5 Gate hierarchy added |
| 7 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | Manual diff/read | PASS: source-doc sharpening marked landed |
| 8 | `docs/decisions/autosend-approval-bridge-spec.md` | `rg "customer_message|email_send|state_change" ...` | PASS: only `diagnostic_email_send` action_type remains |
| 9 | `docs/runbooks/pii-purge-operational-pattern.md` | Manual diff/read | PASS: 90-day default marked proposed pending D2/D3 |

## §3 — Per-item Round-3 verdicts

| Item | Round-2 verdict | Round-3 verdict | Notes |
|---|---|---|---|
| `docs/decisions/bullhorn-integration-path.md` | REJECTED | RATIFIED | Gate hierarchy now encoded in source doc. |
| `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | REJECTED | RATIFIED | Disagreement closure now matches source doc. |
| `docs/decisions/autosend-approval-bridge-spec.md` | REJECTED | RATIFIED | Category enum fixed; future table inventory obligation documented. |
| `docs/runbooks/pii-purge-operational-pattern.md` | REJECTED | RATIFIED | D3 marked proposed; schema path corrected. |
| `docs/architecture/tenancy-invariants.md` | RATIFIED | RATIFIED | Narrow update for nullable text + future bridge table. |
| `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` | REJECTED via v0.2 supplement | RATIFIED | PG 12+ `consrc` issue fixed. |
| `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | REJECTED | RATIFIED | `DROP NOT NULL` added before purge CHECK. |
| `scripts/ifos-pii-purge.sh` | REJECTED | RATIFIED | Transaction wrap + checked audit write. |
| `scripts/run-tenancy-audit.sh` | REJECTED | RATIFIED | T4 write probe + transaction wrap. |
| `agents/_shared/hook-helpers.sh` + `agents/_shared/voice-loader.sh` + `scripts/run-codex-ratification.sh` | New gap from SUMMARY §5 | RATIFIED | Cross-cutting Risk #11 fix. |

## §4 — Founder-escalated items

| Item | Decision required | Path to resolution |
|---|---|---|
| `docs/decisions/autosend-safety-policy.md` §1/§9 | D1: choose v1.0 orange-tier path | Founder chooses D1-B bridge path or D1-C ad-hoc/manual path; then policy can move from annotated Proposed to Accepted/In Force for that behavior. |
| `docs/decisions/autosend-safety-policy.md` §10 | D2 + D3: legal/PII liability posture | Engage SeedLegals/external advisor; replace placeholder before first pilot LOI. |
| `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` Q13 | D3: retention duration/default | Founder confirms D3-B or alternate after advisor input; implementation path is now mechanically unblocked. |

## §5 — Cross-cutting verification

- Shellcheck clean: `scripts/ifos-pii-purge.sh`, `scripts/run-tenancy-audit.sh`, `agents/_shared/hook-helpers.sh`, `agents/_shared/voice-loader.sh`, `scripts/run-codex-ratification.sh`
- Helper tests pass: hook-helpers 20/20, voice-loader 9/9
- Renderer tests pass: 30/30
- No new lint warnings observed in the commands run

## §6 — Hard-ceiling check

Per master brief §10.3, this is the last automated round for the Round-2 rejection set. The 10 corrected items are RATIFIED. The remaining unresolved surfaces are not automated-round failures; they are founder-escalated decisions D1, D2, and D3 and must be decided by the founder before the affected policy/legal/production gates close.
