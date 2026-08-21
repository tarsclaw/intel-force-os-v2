# Codex Cluster F — Round-1 REJECT closure, Round-2 ready

**Session:** `20260601T144038Z-55009` (Round 1) — REJECTED 3/3.
**Authored:** 2026-06-01 18:18 BST (autonomous evening goal continuation; founder away).
**Next:** founder re-runs `bash scripts/run-codex-ratification.sh --cluster F` for Round 2.

## What changed since Round 1

5 commits closing all 14 Codex-cited issues across the 3 packages:

| Commit | What |
|---|---|
| `b7d1c77` | **Harness fix** — `run-codex-ratification.sh` directory-aware artefact handling (R1 invocation was assembling empty prompts because the file-only `-f` check failed on package directories; fixed to `-e` + structured digest concatenation). |
| `f414492` | `autosend-policy.yaml` — registered 4 missing MCP-connector OAuth action_types as green tier (`xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`). Closes R1 issue-class A on all 3 packages simultaneously. |
| `5228fa2` | `@ifos/xero` — 4 R1 issues closed: capability surface set-equality (README + src/index.ts grouped); explicit ESC contract table (ESC_RATE_LIMIT_HIT + ESC_ACCOUNTING_WRITE_FAIL + ESC_ACCOUNTING_AUTH); hard-gate vs soft-signal contract documented; 2 new error-path tests (listOpenInvoices 429, listPayments 500). 25/25 vitest (was 23). |
| `dad4dea` | `@ifos/quickbooks` — 5 R1 issues closed: same capability-surface restructure + ESC contract + retry-policy ESC mapping + 2 new error-path tests. 25/25 vitest (was 23). |
| `47dbce1` | `@ifos/open-banking` — 5 R1 issues closed: capability surface set-equality (incl. Plaid UK stub added to cash-conductor/tools.yaml for set-equality); provider rate-limit URLs (TrueLayer + Plaid UK) cited; ESC_RATE_LIMIT_HIT + ESC_OPEN_BANKING_AUTH contract tables; honest-signal fix on live-tests claim (README now explicitly states "Live tests are deferred to first TrueLayer dev signup"). 28/28 vitest unchanged. |

## Per-package quality gates (all green)

| Package | typecheck | vitest | boundary |
|---|---|---|---|
| `@ifos/xero` | ✓ CLEAN | ✓ 25/25 | ✓ 0 violations |
| `@ifos/quickbooks` | ✓ CLEAN | ✓ 25/25 | ✓ 0 violations |
| `@ifos/open-banking` | ✓ CLEAN | ✓ 28/28 | ✓ 0 violations |

## Round-2 instructions

```bash
cd ~/code/CortexOS
bash scripts/run-codex-ratification.sh --cluster F
```

Expected outcome: `RATIFIED: 3   REJECTED: 0` per the Codex round-trip ≤2 ceiling (per `.agents/learnings/01-codex-roundtrip-discipline.md`).

If any artefact still rejects on Round 2:
- We are at the ≤2 ceiling. Per learning 01, do NOT immediately run a Round 3.
- Inspect the new reject reasons + decide per-issue: (a) incorporate (founder/Claude code change) or (b) counter-argue via `docs/decisions/codex-disagreement-2026-06-01-<slug>.md`.
- Founder + Claude jointly determine whether to escalate to ULTRAPLAN / mark Codex as overruled with rationale.

## After RATIFIED ×3

Trigger Cluster Fbis (Cash Conductor + Concierge agent-bundle ratifications — both 100% present at scaffold layer):

```bash
bash scripts/run-codex-ratification.sh --cluster Fbis
```

Then Cluster G (D1-B decision-doc):

```bash
bash scripts/run-codex-ratification.sh --cluster G
```

## What this run does NOT touch

- Production credentials (none entered chat; none required for ratification).
- Live API calls (all tests are fixture-backed).
- Ratified artefacts outside the explicit scope (agent.md files at cluster-E layer untouched).
- Codex round-trip count for clusters E, A-D, or any other cluster (this fix bundle is cluster-F-scoped).

— end of handoff —
