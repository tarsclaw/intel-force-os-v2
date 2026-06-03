# @ifos/reed

IFOS MCP connector for [Reed.co.uk](https://www.reed.co.uk) — a thin, typed wrapper over the Reed **Recruiter API** (candidate search + job postings). Used by Sourcing Scout (W9) as source #2 in the v1.0 3-source candidate pool (Bullhorn passive-match + Reed + CV-Library; LinkedIn deferred to v1.1+ per Proxycurl shutdown).

---

## Status

- **v0.1.0 SCAFFOLD** — landed W5 Day-34 Phase 8 of the marathon /goal. Built to anticipate Sourcing Scout W9 live wiring; package landing now means the W9 build slice has the consumer interface ready.
- **Auth verified 2026-06-03 via WebFetch** of `reed.co.uk/developers/jobseeker` — Reed uses HTTP Basic authentication with the API key as the username and an EMPTY password. The Recruiter API endpoints are inferred from the same auth scheme (Reed's two public APIs share architecture); live verification of exact endpoint paths deferred to the founder's Reed Recruiter API commercial signup per `docs/operations/founder-api-signups-2026-06-03.md` P2.
- **Live tests deferred** per the honest-signal pattern from cluster F OB R3 closure — the Reed Recruiter API account is not yet provisioned by the founder. The fixture-first test layer (scaffold + rate-limit + capabilities-via-fake-fetch) covers the protocol shape and surface; live network tests land when the API credentials arrive.

---

## Authentication

**Reed uses a long-lived API key with NO refresh dance.** This is the same shape as `@ifos/workos` (single-key bearer-style) and distinct from `@ifos/bullhorn` (two-step OAuth + REST login) or `@ifos/xero` (OAuth refresh-token rotation).

The model:

- One API key (provisioned in the Reed developer portal) lives in the IFOS deployment env, presented as `Authorization: Basic base64(API_KEY:)` on every request (note the trailing colon — Reed expects API key as username + empty password).
- The key rotates only when the founder rotates it manually in the Reed developer portal, in which case the env-var changes and the process restarts.
- A `401` from Reed means the key has been rotated/revoked. There is **NO retry path**; the client surfaces `ReedAuthError` immediately so the consumer can degrade gracefully (e.g. Sourcing Scout marks Reed source as degraded + continues with remaining sources).

This is reflected in the package shape: **there is no `src/auth.ts`**. The 7 source files are `types.ts`, `errors.ts`, `cache.ts`, `client.ts`, `rate-limit.ts`, `candidates.ts`, `jobs.ts`, `index.ts`.

### API key provisioning

The founder bootstraps the credential **once** per environment:

1. Sign in to the Reed developer portal (`https://www.reed.co.uk/developers`).
2. **Recruiter API** section → request API access (commercial signup per founder playbook P2; may require email to `api@reed.co.uk`).
3. Once issued: copy the API key.
4. Add to IFOS deployment env (e.g. `REED_API_KEY=<key>`).
5. Restart the IFOS process so the new env-var is picked up.

The IFOS process **never** writes this key to disk — it lives only in env memory plus `process.env`. The token-file pattern used by `@ifos/bullhorn` does NOT apply here.

---

## Capabilities (bus-routed)

The capability set below is **set-equal** with the `reed_*` declarations on `agents/recruitment/sourcing-scout/tools.yaml` (declared at Day-33 with `package_status:scaffold_pending_phase_8`; this package fulfills that scaffold).

| Function | Reed endpoint (inferred) | Purpose |
|---|---|---|
| `searchCandidates(client, options)` | `GET /api/{version}/candidates/search` | Sourcing Scout Step 5 — candidate search by keywords + location + salary band |
| `getCandidate(client, candidate_id)` | `GET /api/{version}/candidates/{id}` | Single-candidate hydrate for rationale generation context |
| `listJobs(client, options)` | `GET /api/{version}/jobs` | v1.0 read-only; v1.1+ adds POST/PUT for posting jobs |
| `getJob(client, job_id)` | `GET /api/{version}/jobs/{id}` | Single job posting fetch |

**4 capabilities.** All `get*` return null on 404; `list*` and `search*` throw `ReedNotFoundError` on 404 (endpoint itself missing, not the contents).

**TODO(W6-live)**: verify exact Recruiter API endpoint paths against Reed's Recruiter API docs (accessible to the founder once commercial access is granted; cannot WebFetch the recruiter docs page anonymously per 2026-06-03 attempt — page returned 403). Paths above are placeholders mirroring the Jobseeker API shape.

---

## Rate limits

Reed does NOT publish exact rate-limit numbers in the Jobseeker API docs (verified 2026-06-03 via WebFetch — "Rate Limits: Not specified"). The v0.1.0 default budget is conservative:

- **Per-`account_id` bucket** (multi-tenant safe).
- **Hard ceiling: 60/minute** per bucket (1/sec sustained — well above Sourcing Scout daily-poll cadence).
- **Soft backoff: 48/minute** (80%). At soft, `rateCheck()` reports `shouldBackoff: true` but `consume()` still succeeds.
- **Hard fail: 60/minute** (100%). `consume()` returns `false` and the client throws `ReedRateLimitError` pre-emptively.

TODO(W5-live): verify exact Reed Recruiter API rate-limit numbers during first commercial signup; tune `MINUTE_HARD` if upstream telemetry shows a different ceiling.

---

## Error hierarchy

| Class | When | Maps to ESC |
|---|---|---|
| `ReedError` | Base | (none — base; downstream picks the typed leaf) |
| `ReedAuthError` | 401 from any endpoint (API key invalid/revoked); NO retry | `ESC_REED_AUTH` (blocking per catalogue §2.7) |
| `ReedRateLimitError` | 429 from upstream OR local bucket exhausted | `ESC_RATE_LIMIT_HIT` (warn; payload.upstream='reed') |
| `ReedNotFoundError` | 404 from any endpoint; `get*` translates to null, `list*`/`search*` throws | (none — surface to consumer) |
| `ReedValidationError` | 400 from any endpoint (typically schema mismatch on POST/PUT) | `ESC_REED_VALIDATION_FAIL` (warn; QUEUED for catalogue at W6) |

Per `review-mcp-connector` §5: **error messages NEVER include the API key or any header value verbatim** — only status code, method, path, and safe metadata.

---

## Caching

Disk cache (`ReedCache`) with default 1-hour TTL — Reed job-market data churns hourly (new candidates apply; postings get filled; CVs update). The 1-hour TTL matches the Sourcing Scout cleanup.sh purge interval per the bundle's coordinated cache lifecycle.

Cache files live at `~/.ifos-cache/reed/` (mode 0600) keyed by SHA-256 of the cache namespace + identifier. Override via `IFOS_REED_CACHE_DIR` env.

---

## Reference implementation

This package mirrors `@ifos/workos` (Day-29 Phase 2; commit `6dc5a4a`) — same long-lived-key shape MINUS the OAuth refresh dance + WorkOS-specific scope handling. Key shape differences:

- **HTTP Basic auth** (`Basic base64(API_KEY:)`) vs WorkOS Bearer (`Bearer sk_...`)
- **Per-`account_id` rate-limit bucket** (vs WorkOS per-`org_id`)
- **1-hour cache TTL** (vs WorkOS 10-min — Reed job-market data churns faster than tenant SSO config)
- **No `base_url` override convention beyond test** — production always hits `www.reed.co.uk/api/{version}`
- **API version in URL path** (`/api/1.0/...`) — handled via `DEFAULT_API_VERSION` constant + config override

---

## Local development

```bash
cd packages/mcp-connectors/reed
pnpm install
pnpm typecheck   # must pass clean
pnpm test        # vitest run; ≥15 tests
pnpm build       # tsup ESM + DTS
```

All tests use fixture-first fakes; **no live network calls** at this version.

---

## v1.1+ scope (deferred)

- **POST/PUT job postings** (v1.0 is read-only for the listJobs surface; v1.1+ wires job creation + update)
- **Application retrieval** (candidates who applied to a posting — Sourcing Scout v1.1+ enrichment)
- **CV download URLs with session auth** (some Reed CV URLs require additional session token; verify at commercial signup)
- **`MCP_LIVE_TESTS=1` block** (lands once founder confirms Reed Recruiter API account + endpoints verified live)
