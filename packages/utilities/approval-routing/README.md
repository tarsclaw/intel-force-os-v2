# @ifos/approval-routing

Resolver core for approval routing (W1 slice of `docs/features/approval-routing/PLAN.md`;
spec: `docs/specs/approval-routing-architecture.md`).

**One idea:** approvals are *resolved from data the firm already maintains*
(Bullhorn record ownership + M365 identity), never configured. The §4 ladder:

1. **Record owner** — entities-cache owner → identity-map → person_ref
2. **Function role** — `routing/function-roles.yaml` (§6.3, schema_version 1)
3. **Firm default** — catch-all; nothing falls through

## Surface

- `resolveApprover(input, deps)` — the ladder as a pure function over injected
  `(ownerLookup, functionRoles, identityMap, registry)`. Every result carries
  `ladder_step` + `reason` (routing is auditable). §4.2 gap: unowned record →
  firm default + `unowned_record: true` (caller emits the Janitor finding).
- `loadFunctionRoles` / `loadIdentityMap` / `loadRegistry` — strict validators;
  violations throw typed `RoutingConfigError` (caller falls back to the
  single-operator path — PLAN.md decision 2 backwards-compat invariant).
- `createPostgresOwnerLookup` — RLS-scoped (`SET LOCAL app.current_tenant`)
  psql reader over `entities.data`; injectable `RunPsql` keeps tests offline.
  Verified owner-field mapping is documented in `src/owner-lookup.ts`.
- CLIs (`node dist/bin/...` after `pnpm build`):
  - `resolve-approver.js --tenant --action-type [--entity-type --entity-id]
    [--vault-root] [--registry]` → single-line JSON ResolveResult.
    Exit 0 resolved · 3 config absent (fallback) · 1 real error.
    `IFOS_ROUTING_FAKE='{...}'` fixture mode echoes the injected result.
  - `seed-identity-map.js --tenant (--csv <path> | --add --bullhorn-user-id ...
    | --render-confirmation)` — identity-map seeding + the §10.6
    Diagnostic-style confirmation render.

Zero npm runtime deps (bridge precedent) — includes a scoped YAML-subset
parser/emitter (`src/yaml-lite.ts`) for the two vault artefacts.

## Test

```
pnpm -s typecheck && pnpm -s test   # offline; no DB, no network
```
