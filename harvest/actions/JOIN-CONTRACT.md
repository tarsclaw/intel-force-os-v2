# Policy-layer join contract

The two files in this directory are the CortexOS policy layer. They move to the new repo **verbatim** — only the
code that reads them changes (today `_shared/hook-helpers.sh::autosend_policy_lookup()` in shell; in the new repo
`packages/authoriser` in TypeScript).

## The invariant

`autosend-policy.yaml` and `action-class-registry.yaml` key off the same `action_type` namespace, and the key sets
must be **set-equal**. A key present in one and absent from the other is a defect: the registry's own header says
the resolver must fail safe to the single-operator fallback and log `routing_fallback`.

**Verified 2026-08-21:** 53 keys each, set equality holds, zero duplicates in either file.

> Note: `autosend-policy.yaml`'s header comment still claims "47 v1.0 action_types: 19 green + 10 yellow +
> 10 orange + 8 red". That figure is **stale** — it predates four MCP OAuth rows plus `bullhorn_activity_log_write`
> and `concierge_approval_routed`. The registry header already records this. Actual: **53 = 25 green + 10 yellow +
> 10 orange + 8 red**. Correct the comment when the file lands in the new repo.

## Measured distribution

| Property | Distribution |
|---|---|
| `tier` | 25 green · 10 yellow · 10 orange · 8 red |
| `trust_bucket` | 25 bucket-1 (never asks) · 13 bucket-2 (asks once, then graduates) · 15 bucket-3 (always asks) |
| `on_expiry` | 51 `hold` · 2 `safe_default` · **0 `auto_execute`** |
| `routing_rule` | 21 `record_owner` · 11 `function_role:finance` · 9 `admin` · 6 `ops_data` · 6 `business_development` |

All 53 keys carry all four properties. No gaps.

`auto_execute` appearing zero times confirms the registry's stated design rule: it is reachable only at runtime for
a class that has already passed the graduation gate, never as a seeded value. **Preserve that property** — a seeded
`auto_execute` in the new repo would let an action self-approve without ever earning it.

## Why this maps onto the new harness

| New harness concept | Already present as |
|---|---|
| Action ontology | the 53 keys |
| Authoriser risk tiers | `tier` |
| Approval routing | `routing_rule` → record owner or named function role |
| Escalation chain | `escalation_after_minutes` (chain itself in `function-roles.yaml`) |
| Approval TTL and expiry behaviour | `ttl_minutes`, `on_expiry` |
| **Autonomy ladder** | **`trust_bucket` 1/2/3**, graduation gated at <2% override over 30 days, firm-admin only |
| Morning brief batching | `digest_eligible`, `breaks_quiet_hours` |

## Contract test to write in the new repo

1. Parse both files; assert set equality of `action_type` keys. (Today: 53.)
2. Assert no duplicate keys in either file.
3. Assert every key carries all of `tier`, `trust_bucket`, `routing_rule`, `on_expiry`.
4. Assert `tier ∈ {green,yellow,orange,red}` and `trust_bucket ∈ {1,2,3}`.
5. **Assert no seeded `on_expiry: auto_execute`.**
6. Assert every `routing_rule` of form `function_role:X` names a role defined in the tenant's `function-roles.yaml`.

## What does NOT travel

Per-tenant variation. The registry header is explicit: tenants never edit these files. Per-tenant state lives in
the vault (`/vault/{tenant_slug}/routing/function-roles.yaml` — who holds each role) and in Postgres
`decision_log` GRANT/REVOKE rows (which bucket-2 classes have graduated). Both are runtime state, not policy, and
both stay on the existing database.

## Status carried forward

`action-class-registry.yaml` is marked **Proposed** — Codex ratification was in flight and it flips to Accepted on
ratification plus founder sign-off. It arrives in the new repo at that status, not as ratified fact.
