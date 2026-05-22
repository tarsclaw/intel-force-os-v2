# Codex Round 2 autonomous ratification summary

**Run date:** 2026-05-22  
**Run directory:** `logs/codex-ratification/round-2-autonomous/`  
**Output files verified:** 26 `.output.md` files present.

## §1 — Headline counts

- Tier 1 (re-ratify): 11 RATIFIED / 3 REJECTED of 14
- Tier 2 (new Day-9): 3 RATIFIED / 1 REJECTED of 4
- Tier 3 (new Day-11): 3 RATIFIED / 5 REJECTED of 8
- Total: 17 RATIFIED / 9 REJECTED of 26

## §2 — Per-tier per-artefact table

| Tier | Path | Skill | Round-1 verdict | Round-2 verdict | Issue count | Notes |
|---|---|---|---|---|---:|---|
| 1 | `docs/decisions/ADR-001-bus-dispatcher-poll-not-chokidar.md` | architecture-decision | REJECTED | RATIFIED | 0 | Status drift fixed. |
| 1 | `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` | architecture-decision | REJECTED | RATIFIED | 0 | Parallel-brain framing clean. |
| 1 | `docs/decisions/ADR-003-agent-bundle-renderer.md` | architecture-decision | REJECTED | RATIFIED | 0 | CLI drift fixed via ADR-004. |
| 1 | `docs/decisions/bullhorn-integration-path.md` | architecture-decision | REJECTED | REJECTED | 1 | Week-1/Bullhorn gate sharpening did not land in source artefact. |
| 1 | `docs/decisions/sequencing-target.md` | architecture-decision | REJECTED | RATIFIED | 0 | Status and phase semantics clean. |
| 1 | `docs/decisions/autosend-safety-policy.md` | architecture-decision | REJECTED | REJECTED | 2 | D1/D2 remain load-bearing; policy still contradicts itself on v1.0 orange handling. |
| 1 | `docs/architecture/cortexos-primitive-status.md` | architecture-decision | REJECTED | RATIFIED | 0 | D5 softening correctly applies. |
| 1 | `docs/architecture/second-brain-design.md` | architecture-decision | REJECTED | RATIFIED | 0 | Status/cross-ref fixed. |
| 1 | `docs/architecture/agent-bundle-renderer-design.md` | architecture-decision | REJECTED | RATIFIED | 0 | Phase/CLI drift fixed. |
| 1 | `docs/architecture/vault-concurrency.md` | architecture-decision | REJECTED | RATIFIED | 0 | Migration/ESC cross-refs fixed. |
| 1 | `docs/decisions/v1.0-kill-criterion.md` | architecture-decision | REJECTED | RATIFIED | 0 | Trigger fixes incorporated. |
| 1 | `docs/runbooks/operational-hygiene-protocol.md` | architecture-decision | REJECTED | RATIFIED | 0 | D5 softening + Path B tightening sufficient. |
| 1 | `docs/verticals/recruitment/vertical-schema.yaml` | schema-change | REJECTED | RATIFIED | 0 | Round-1 schema issues fixed. |
| 1 | `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` | schema-change | REJECTED | REJECTED | 2 | Companion migration uses removed `consrc`; PII retention still defaults indefinite. |
| 2 | `docs/architecture/tenancy-invariants.md` | architecture-decision | N/A | RATIFIED | 0 | T1-T12 clear; implementation gap surfaced separately. |
| 2 | `docs/architecture/architecture-cohesion-review.md` | architecture-decision | N/A | RATIFIED | 0 | Good coherent-system audit. |
| 2 | `docs/runbooks/tenant-lifecycle.md` | architecture-decision | N/A | RATIFIED | 0 | In Force runbook; open gaps tracked. |
| 2 | `scripts/run-tenancy-audit.sh` | architecture-decision | N/A | REJECTED | 2 | Audit row uses `SET LOCAL` outside transaction; T4 write probe is only SELECT. |
| 3 | `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` | architecture-decision | N/A | RATIFIED | 0 | Codex agrees with D5 softening. |
| 3 | `docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` | architecture-decision | N/A | REJECTED | 2 | Counter-argument plausible, but promised source-doc sharpening absent. |
| 3 | `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` | architecture-decision | N/A | RATIFIED | 0 | Correct founder-domain briefing; D1/D2/D3 still open. |
| 3 | `docs/decisions/autosend-approval-bridge-spec.md` | architecture-decision | N/A | REJECTED | 2 | Maps to nonexistent cortextOS approval categories; new table not integrated into tenancy audit. |
| 3 | `docs/runbooks/pii-purge-operational-pattern.md` | architecture-decision | N/A | REJECTED | 2 | Purge pattern conflicts with current NOT NULL schema; D3 not actually confirmed. |
| 3 | `scripts/ifos-pii-purge.sh` | architecture-decision | N/A | REJECTED | 2 | UPDATE cannot NULL `original_text`; audit row write unchecked/transactionless. |
| 3 | `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` | postgres-migration | N/A | REJECTED | 2 | Missing `DROP NOT NULL`; script/migration override story inconsistent. |
| 3 | `docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql` | postgres-migration | N/A | RATIFIED | 0 | Rollback is narrow; paired forward migration still rejected. |

## §3 — Disagreement-doc recursive verdicts

Item 19, D5 skill softening: **RATIFIED.** Codex agrees with Claude's counter-argument. The skill change is correct: Reference and In Force artefacts need Context and honest Status, but not forced ADR ceremony.

Item 20, Bullhorn Week-1 gate: **REJECTED.** Codex agrees that Claude's gate hierarchy could be correct, but rejects closure because the promised source-document remediation did not land. The disagreement doc says the line-95 sharpening shipped, while `bullhorn-integration-path.md` still contains the broad wording that triggered Round 1.

## §4 — Founder-attention items

1. **Autosend v1.0 orange-tier decision is still open.** The policy still says every action has a tier and orange needs approval, while v1.0 ships green/red only. This is founder-domain because it changes Concierge's product promise: draft-only, ad-hoc approval, or real approval bridge. Recommended path: pick D1-B or D1-C explicitly, then update `autosend-safety-policy.md` and bridge spec together.

2. **PII retention cannot close until D2/D3 are real decisions and the SQL is executable.** The current v0.3 purge path cannot NULL `recent_edit.original_text` because v0.2 made it NOT NULL. This is founder-domain on policy duration/legal posture, and Claude-fixable on SQL/script mechanics after the decision. Recommended path: get advisor input, record D3, then patch migration + script + runbook in one slice.

3. **Bullhorn gate hierarchy needs one source of truth.** The disagreement doc's proposed "Week-1 prereq code only" framing is not reflected in the Bullhorn decision. This is founder-domain because it controls whether Bullhorn connector/auth work is allowed before A+B commercial gates close. Recommended path: update line 95 and add a gate hierarchy subsection.

4. **Approval bridge spec must be reconciled with actual cortextOS category enums.** The spec currently names categories cortextOS rejects. Claude can fix this mechanically, but founder should first confirm D1-B timing/scope so the bridge belongs in v1.0.

5. **Live audit/write helpers need transaction discipline around `SET LOCAL`.** Round 2 found the same fragile pattern in scripts and helpers. Claude can fix it, but it affects runtime correctness across audit rows and potentially live helper writes.

## §5 — New gaps surfaced

1. **High — `SET LOCAL` without explicit transaction appears in multiple runtime paths.** `scripts/run-tenancy-audit.sh`, `scripts/ifos-pii-purge.sh`, `scripts/run-codex-ratification.sh`, `agents/_shared/hook-helpers.sh`, and `agents/_shared/voice-loader.sh` all use `SET LOCAL ifos.tenant_slug` in psql heredocs/strings without a visible `BEGIN/COMMIT`. Recommended owner: Claude Code. Fix before live tenancy audit is trusted as authoritative.

2. **High — PII purge v0.3 migration conflicts with v0.2 NOT NULL schema.** This is not in the existing architecture-cohesion or tenant-lifecycle queues. Recommended owner: Claude Code after founder D3 decision.

3. **Medium — Autosend approval bridge introduces a 10th tenant-data table without updating the invariant/audit inventory.** Recommended owner: Claude Code in the D1 bridge implementation slice.

4. **Medium — Bullhorn disagreement closure process allowed a claimed source-doc change that was absent.** Recommended owner: Claude Code; add a manifest/checklist rule that disagreement docs must verify the referenced artefact diff.

## §6 — Risk register additions

Add **Risk #11: Tenant-context guard failure due transactionless `SET LOCAL` usage.**  
Proposed severity: High.  
Tripwire: any live helper/audit write using `SET LOCAL ifos.tenant_slug` without `BEGIN/COMMIT`, or a successful operation whose decision_log row falls back to JSONL because RLS rejected the insert.  
Mitigation: centralise psql tenant wrappers and require `BEGIN; SET LOCAL; <tenant query>; COMMIT;` for every live DB read/write.

Add **Risk #12: PII purge remediation cannot execute against current schema.**  
Proposed severity: High until migration corrected.  
Tripwire: `v0.2-to-v0.3-pii-purge.sql` lacks `ALTER COLUMN original_text DROP NOT NULL` while purge cron sets `original_text=NULL`.  
Mitigation: correct migration/script/runbook bundle before D3 is marked mitigated.
