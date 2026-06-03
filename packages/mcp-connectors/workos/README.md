# @ifos/workos

IFOS MCP connector for [WorkOS](https://workos.com) — a thin, typed wrapper over the WorkOS Organizations / Connections / Directory Sync **read** surface that v1.0 IFOS admin and tenant-provisioning flows consume.

WorkOS AuthKit is the IFOS v1.0 auth substrate per `docs/build-brief/00-MASTER-BRIEF.md` §5.3 line 401 ("don't add a second auth system"). This package exposes the org/connection/directory-sync READ surface needed by the admin UI and the tenant-onboarding dance; **SCIM write-back, audit-log streaming, and user-event webhooks are deferred to v1.1+**.

---

## Status

- **v0.1.0 SCAFFOLD** — landed W5 Day-29 (this commit). Built to be Bullhorn-independent; uses the gold-standard `@ifos/bullhorn` mirror MINUS the auth.ts refresh dance (see "Authentication" below).
- **Live tests deferred** — the WorkOS account is not yet provisioned by the founder. The fixture-first test layer (scaffold + rate-limit + capabilities-via-fake-fetch) covers the protocol shape and surface; live network tests will land when the WorkOS dashboard signup completes (founder gate; see plan doc §4).
- **Per the honest-signal pattern from cluster F OB R3 closure**: this README will NOT claim "live integration verified" until it actually is. The `MCP_LIVE_TESTS=1` block from peer connectors is intentionally absent in v0.1.0.

---

## Authentication

**WorkOS uses a long-lived secret key with NO refresh dance.** This is fundamentally different from `@ifos/bullhorn` (two-step OAuth + REST login + 10-minute token TTL) and from `@ifos/xero` / `@ifos/quickbooks` (OAuth refresh-token rotation).

The model:

- One secret key (`sk_test_…` or `sk_live_…`) lives in the IFOS deployment env, presented as `Authorization: Bearer sk_…` on every request.
- The key rotates only when the founder rotates it manually in the WorkOS dashboard, in which case the env-var changes and the process restarts.
- A `401` from WorkOS means the key has been rotated/revoked. There is **NO retry path**; the client surfaces `WorkosAuthError` immediately so the consumer can degrade gracefully (e.g. admin UI banner: "WorkOS credentials need re-rotation").

This is reflected in the package shape: **there is no `src/auth.ts`**. The 8 source files are `types.ts`, `errors.ts`, `cache.ts`, `client.ts`, `rate-limit.ts`, `organizations.ts`, `connections.ts`, `directory_sync.ts`, `index.ts`.

### Secret-key provisioning

The founder bootstraps the credential **once** per environment (test + live):

1. Sign in to the WorkOS dashboard (`https://dashboard.workos.com`).
2. **API Keys** tab → **Create key** → copy the `sk_…` value.
3. Add to IFOS deployment env (e.g. `WORKOS_SECRET_KEY=sk_live_…`).
4. Restart the IFOS process so the new env-var is picked up.

The IFOS process **never** writes this key to disk — it lives only in env memory plus `process.env`. The token-file pattern used by `@ifos/bullhorn` (atomic `.tmp + rename` writes to `~/.ifos-local-vault/…`) does NOT apply here.

To rotate (e.g. suspected leak):

1. WorkOS dashboard → API Keys → revoke the old key.
2. Create a new key, update the IFOS env-var, restart.
3. Any in-flight requests using the old key fail with `WorkosAuthError(401)`; the next request after restart uses the new key.

---

## Capabilities (bus-routed)

The capability set below is **set-equal** with the future `workos` MCP tools.yaml on the v1.1+ admin/onboarding agent (no v1.0 agent consumes WorkOS directly — the admin UI calls it). Adding a new capability here REQUIRES a corresponding tools.yaml edit at the consumer side when the consumer attaches.

| Function | WorkOS endpoint | Purpose |
|---|---|---|
| `getOrganization(client, org_id)` | `GET /organizations/{id}` | Resolve tenant → workos_org_id (v0.4 supplement landing per goal-week-5-execution-plan.md Phase 4) |
| `listOrganizations(client, options)` | `GET /organizations` | Admin platform view (org list with domain filter) |
| `getConnection(client, conn_id)` | `GET /connections/{id}` | Inspect a single SSO link before routing a login |
| `listConnections(client, options)` | `GET /connections` | Admin SSO view; filter by `organization_id` + `connection_type` |
| `getDirectory(client, dir_id)` | `GET /directories/{id}` | Inspect a SCIM directory link |
| `listDirectories(client, options)` | `GET /directories` | Admin SCIM view; filter by `organization_id` |
| `getDirectoryUser(client, user_id)` | `GET /directory_users/{id}` | Single user mirror inspection |
| `listDirectoryUsers(client, options)` | `GET /directory_users` | Bulk mirror; filter by `directory` + `group` |
| `getDirectoryGroup(client, group_id)` | `GET /directory_groups/{id}` | Single group mirror |
| `listDirectoryGroups(client, options)` | `GET /directory_groups` | Bulk groups; filter by `directory` |

**10 read capabilities.** All return null on 404 from single-resource `get*` paths; `list*` endpoints throw `WorkosNotFoundError` on 404 (the endpoint itself doesn't exist, not the contents).

---

## Rate limits

WorkOS publishes a per-account rate limit of ~100 RPS (community-corroborated; the public API reference page returns 404 to anonymous fetches, so this is verified against community + SDK source rather than scraped docs). The v0.1.0 default budget is conservative:

- **Per-`org_id` bucket** (multi-tenant safe). Top-level endpoints (`/organizations` list with no filter) bucket under `"global"`.
- **Hard ceiling: 6000/minute** per bucket (10/sec sustained — matches the per-tenant slice of the platform-wide 100 RPS).
- **Soft backoff: 4800/minute** (80%). At soft, `rateCheck()` reports `shouldBackoff: true` but `consume()` still succeeds.
- **Hard fail: 6000/minute** (100%). `consume()` returns `false` and the client throws `WorkosRateLimitError` pre-emptively.

**Note**: the per-org bucket is a fair-use slice, not the upstream ceiling. The true platform-wide gate is 100 RPS × N concurrent orgs = upstream-enforced 429. The local budget protects against burst behaviour from a single tenant; the upstream protects against aggregate.

TODO(W5-live): verify exact WorkOS rate-limit numbers during first commercial signup; tune `MINUTE_HARD` if upstream telemetry shows a different ceiling.

---

## Error hierarchy

| Class | When | Maps to ESC |
|---|---|---|
| `WorkosError` | Base | (none — base; downstream picks the typed leaf) |
| `WorkosAuthError` | 401 from any endpoint (secret key invalid/revoked); NO retry | `ESC_WORKOS_AUTH` (pending W5 Phase 4 addition) |
| `WorkosRateLimitError` | 429 from upstream OR local bucket exhausted | `ESC_RATE_LIMIT_HIT` (warn; payload.upstream='workos') |
| `WorkosNotFoundError` | 404 from any endpoint; `get*` translates to null, `list*` throws | (none — surface to consumer) |
| `WorkosValidationError` | 422 or 400 from any endpoint (v1.1+ writes; v1.0 read surface should never fire this) | `ESC_WORKOS_VALIDATION_FAIL` (pending W5 Phase 4 addition) |

Per `review-mcp-connector` §5: **error messages NEVER include the secret key or any header value verbatim** — only status code, method, path, and safe metadata.

---

## Caching

Disk cache (`WorkosCache`) with default 10-minute TTL — org/connection/directory metadata changes at admin cadence (hours-to-days), and the dominant access pattern is repeated lookups for the same org_id during a single user session.

Cache files live at `~/.ifos-cache/workos/` (mode 0600) keyed by SHA-256 of the cache namespace + identifier. Override via `IFOS_WORKOS_CACHE_DIR` env.

---

## Reference implementation

This package mirrors `@ifos/bullhorn` (Day-28 scaffold; commit `ff0f7b6`) with these deltas:

- **No `auth.ts`** — long-lived secret key; no refresh dance; 401 surfaces immediately.
- **Per-`org_id` rate-limit bucket** (vs Bullhorn's per-`corporation_id`).
- **Higher rate budget** (6000/min vs 600/min — WorkOS published quota is ~10×).
- **No 401-force-refresh path in `client.ts`** — distinct from cluster F R4 `didForceRefresh` flag (which was Bullhorn/QB/OB specific).
- **`base_url` override on the config** — supports test-server fixtures; defaults to `https://api.workos.com`.

---

## Local development

```bash
cd packages/mcp-connectors/workos
pnpm install
pnpm typecheck   # must pass clean
pnpm test        # vitest run; ≥15 tests
pnpm build       # tsup ESM + DTS
```

All tests use fixture-first fakes; **no live network calls** at this version.

---

## v1.1+ scope (deferred)

- **SCIM write-back** (push provisioning changes from IFOS into the tenant IdP)
- **Audit log streaming** (consume WorkOS events for the IFOS audit trail)
- **User-event webhooks** (real-time user-created/-removed handling)
- **AuthKit session management** (the IFOS web layer handles sessions via `@workos-inc/node` directly; this MCP wrapper covers only the admin/onboarding READ surface)
- **`MCP_LIVE_TESTS=1` block** (lands once founder confirms WorkOS account; live integration tests gate on credential availability per honest-signal pattern)
