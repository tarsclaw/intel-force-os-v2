# @ifos/bullhorn

Bullhorn ATS REST API connector for IFOS Janitor + Scribe + Concierge agents. **Two-step OAuth** (OAuth 2.0 access_token THEN REST login → BhRestToken + per-corporation restUrl) + per-corporation rate-limit budget + typed error hierarchy. Fixture-first; live tests deferred to first commercial Bullhorn signup.

**Status:** Proposed (W5 Day-28 scaffold; awaits Codex ratification via `.codex/ratification/review-mcp-connector.md` cluster F-tris + first commercial Bullhorn dev-support reply ~2026-06-09).

**Reference pattern:** mirrors `@ifos/xero` (Day-25 RATIFIED scaffold) for structure; Bullhorn's two-step OAuth model is the load-bearing distinction (xero is single-step). Per `docs/decisions/bullhorn-integration-path.md` **Sub-decision A RESOLVED 2026-06-02**: direct API per-tenant OAuth = v1.0 path; marketplace partner programme deferred to v1.1+ (requires ≥2 live customers; cost ~$5-25k/yr; not justified at ≤3-pilot stage).

---

## Capabilities

Set-equal across three views per `review-mcp-connector.md` §1: the **capability ID** column matches `agents/recruitment/{janitor,scribe,concierge}/tools.yaml`; the **function** column matches `src/index.ts` exports; the **action_type** column matches `agents/_shared/autosend-policy.yaml`.

| Capability ID (consumer tools.yaml) | Function (src/index.ts) | Purpose | Consumer agent | action_type | Tier |
|---|---|---|---|---|---|
| `bullhorn_oauth` | `refreshTokens(config, current, fetchFn?)` | Two-step OAuth refresh — Step A (OAuth at auth-{region}.bullhornstaffing.com) + Step B (REST login → BhRestToken + per-corp restUrl); concurrent-safe dedup per corporation_id; atomic-file-write persistence | Janitor / Scribe / Concierge cycle.sh Step 1 | `bullhorn_oauth` | green (registration QUEUED until consumer tools.yaml lands W5 Phase 5) |
| `bullhorn_get_candidate` | `getCandidate(client, id, options?)` | Single-entity Candidate fetch by Bullhorn id | Janitor (dedup) | n/a (read-only) | n/a |
| `bullhorn_list_candidates` | `listCandidates(client, options?)` | Search Candidate via /search/Candidate with Lucene-style query | Janitor (dedup + field backfill) | n/a (read-only) | n/a |
| `bullhorn_update_candidate` | `updateCandidate(client, id, patch)` | Mutate Candidate fields | Janitor (dedup merge + field backfill) | `bullhorn_candidate_dedupe` OR `bullhorn_field_backfill` (yellow tier; consumer cycle.sh selects by mutation type) | yellow |
| `bullhorn_get_placement` | `getPlacement(client, id, options?)` | Single-entity Placement fetch | Concierge (lifecycle state) + Cash Conductor (addressee resolution) | n/a (read-only) | n/a |
| `bullhorn_list_placements` | `listPlacements(client, options?)` | Search Placement | Concierge (poll-since-last-state-change) | n/a (read-only) | n/a |
| `bullhorn_get_client` | `getClient(client, id, options?)` | Single-entity ClientCorporation fetch (Bullhorn's "corporate client") | Concierge + Cash Conductor | n/a (read-only) | n/a |
| `bullhorn_list_clients` | `listClients(client, options?)` | Search ClientCorporation | Janitor (enrichment) | n/a (read-only) | n/a |
| `bullhorn_get_contact` | `getContact(client, id, options?)` | Single-entity ClientContact fetch (Bullhorn's "person at a client") | Concierge (recipient resolution) | n/a (read-only) | n/a |
| `bullhorn_list_contacts` | `listContacts(client, options?)` | Search ClientContact | Concierge | n/a (read-only) | n/a |
| `bullhorn_create_note` | `createNote(client, note)` | Create Note entity (action/comments/personReference) | Scribe (post-call tacit knowledge) | `bullhorn_note_attach` (yellow) OR `bullhorn_note_customer_visible` (orange when isExternal=true) per consumer | yellow / orange |
| `bullhorn_activity_log_write` | `createActivityLogEntry(client, candidate_id, comments)` | Convenience wrapper for Concierge's post-send activity-log pattern | Concierge §4 Step 13 | `bullhorn_activity_log_write` | green (REGISTERED 2026-06-02 per Concierge cluster Fbis-R1 closure commit `e32344e`) |

### Internal helpers (NOT bus-routed capabilities)

| Function | Purpose |
|---|---|
| `BullhornClient` (class) | Transport — per-corporation; constructed once by cycle.sh Step 1; carries capabilities through rate-limit + retry + two-step OAuth attach path |
| `loadTokens(config)` / `saveTokens(config, t)` | Token-file I/O — includes BOTH OAuth tokens AND BhRestToken/restUrl bundle; surfaced for test setup + operator consent-bootstrap |
| `shouldRefresh(tokens, now?, window?)` | Pure predicate — `true` when EITHER OAuth access_token OR BhRestToken expires within `safety_window_ms` (default 90s — both Bullhorn tokens have ~10min TTL) |
| `rateCheck(corporation_id, now?)` | Returns `RateState` — exposes soft-backoff signal at 80% (480/min) of the conservative 600/min ceiling; consumer responsible for honouring it |
| `rateConsume(corporation_id, now?)` | Consumes a slot; returns false at the hard 100% gate |
| `resetRateLimit(corporation_id?)` | Test/diagnostic reset |
| `_resetInflightForTest()` | Clears in-flight OAuth-refresh dedup map; for tests only |
| `BullhornCache` (class) | Disk cache — 5-15min TTL per entity-type churn (Candidate 5min; ClientCorporation 15min; ClientContact 10min) |
| `BULLHORN_REST_LOGIN_URL` | Constant — `https://rest.bullhornstaffing.com/rest-services/login` (Step B URL; region-independent; the REST host returns a per-corp restUrl from this call) |

---

## OAuth bootstrap (one-time per Bullhorn corporation)

The connector handles **refresh** (both Step A and Step B). The **initial consent dance** is a one-time human-in-the-loop flow:

1. Register the IFOS app via Bullhorn support ticket (per `bullhorn-integration-path.md` §3 — Bullhorn does NOT self-serve developer signup; the support-ticket gate exists even for developer-tier API access).
2. Receive `client_id` + `client_secret` from Bullhorn support.
3. Construct the authorise URL: `https://auth-{region}.bullhornstaffing.com/oauth/authorize?client_id={id}&response_type=code&action=Login`.
4. User logs into their Bullhorn tenant → consents → Bullhorn redirects to your `redirect_uri?code=<auth_code>`.
5. Exchange code for tokens: `POST https://auth-{region}.bullhornstaffing.com/oauth/token` with `grant_type=authorization_code` + `code=<auth_code>` → receive `{access_token, refresh_token, expires_in}`.
6. Run REST login: `GET https://rest.bullhornstaffing.com/rest-services/login?version=2.0&access_token={access_token}` → returns `{BhRestToken, restUrl}` (per-corporation).
7. Compute `oauth_expires_at_ms` + `bh_rest_token_expires_at_ms` (~10min each).
8. Write the token bundle to `token_file_path` as JSON (mode 0600) — both OAuth tokens AND BhRestToken/restUrl in one file.

After bootstrap, `refreshTokens()` handles all subsequent rotations (full Step A + Step B re-run).

**Region selection (TODO(W5-live)):** v1.0 default is `'east'` (US-East — most-deployed region per community sources). UK-region tenants override per onboarding. If you don't know the region, leave it `'east'` and surface the first OAuth failure for region resolution — Bullhorn's public docs are thin on exact regional endpoint variance; verify during first commercial signup.

---

## Rate limits

**Bullhorn does NOT publish exact per-corporation rate limits.** The docs reference an "API Fair Use Policy" without numbers; community sources (Bullhorn support forums + integration partner notes) suggest ~10 calls/second sustained per corporation_id is the safe band.

v1.0 conservative default per `src/rate-limit.ts`: **600 calls/min per corporation_id** (10/sec sustained × 60). **Hard gate at 100%** (`consume()` returns false → `BullhornRateLimitError`). **Soft signal at 80%** (480/min) is read-only and exposed via `rateCheck()` — `RateState.shouldBackoff === true` with `reason: "minute-soft"`. The consuming agent layer is responsible for honouring the soft signal (e.g. pausing batch operations); the connector does not silently throttle.

State is in-process and per-corporation_id — a multi-tenant runtime that holds many `BullhornClient` instances in one process still gets correct isolation.

**ESC contract on bucket exhaustion** (consumer-emitted via `agents/_shared/hook-helpers.sh`):

| Failure | Surfaces as | ESC code (escalation-codes.md) | Payload contract |
|---|---|---|---|
| Local hard-gate (100%) reached | `BullhornRateLimitError` thrown by `consume()`/client | `ESC_RATE_LIMIT_HIT` (warn; operator) | `{upstream: "bullhorn", retry_after_seconds: null, consecutive_429s: 0}` |
| Upstream 429 from Bullhorn API | `BullhornRateLimitError` thrown with `retry_after_seconds` from `Retry-After` header | `ESC_RATE_LIMIT_HIT` | `{upstream: "bullhorn", retry_after_seconds: <N>, consecutive_429s: <N>}` |

---

## Retry policy

| Capability | Method | Max retries | Backoff | On exhaustion |
|---|---|---|---|---|
| `getCandidate` / `listCandidates` / `getPlacement` / `listPlacements` / `getClient` / `listClients` / `getContact` / `listContacts` / `getNote` | GET | 2 | Full-jitter exponential (`Math.random() * 250 * 2^attempt`); with max_retries=2 the backoff fires on attempt 0 (range 0-249ms) and attempt 1 (range 0-499ms) | `BullhornError` (catalogue note: `ESC_PROVIDER_FETCH_FAIL` explicitly EXCLUDES Bullhorn — see "Catalogue gap" below) |
| `updateCandidate` / `createNote` / `createActivityLogEntry` | POST/PUT | **0** | n/a (writes never auto-retry) | `BullhornValidationError` (400) / `BullhornError` (5xx) → `ESC_BULLHORN_WRITE_FAIL` (warn; operator; consumer-emitted) |
| `refreshTokens` (Step A or Step B fail) | POST/GET | **0** | n/a | `BullhornAuthError` → `ESC_BULLHORN_AUTH` (blocking; operator + ifos_oncall; agent enters degraded mode per consumer agent.md §6) |
| 401 from any GET | — | force-refresh (Step A + B) ONCE, retry once | — | `BullhornAuthError` on second 401 (didForceRefresh flag prevents double-rotation per cluster F R4 lesson) |
| 429 from any GET | — | honour `Retry-After` header, retry | jittered backoff if no header | `BullhornRateLimitError` → `ESC_RATE_LIMIT_HIT` |

**Catalogue gap (acknowledged honest signal):** `ESC_PROVIDER_FETCH_FAIL` in `agents/_shared/escalation-codes.md` explicitly scopes to "any non-Bullhorn-non-Accounting GET" — Bullhorn GET 5xx failures after retries therefore surface as the base `BullhornError` without a dedicated catalogue code. The consumer cycle.sh decides escalation by context. **W6 catalogue addition recommended**: `ESC_BULLHORN_FETCH_FAIL` (warn; operator) for symmetry with `ESC_BULLHORN_WRITE_FAIL` + `ESC_BULLHORN_AUTH`. Deferred — not blocking v1.0 because Bullhorn 5xx GETs are rare.

The connector does NOT write `decision_log` rows (vault/Postgres split per ADR-002); the consuming `cycle.sh` catches the typed errors above and emits the right ESC via `hh_decision_action`/`hh_decision_output` from `agents/_shared/hook-helpers.sh`.

---

## Error hierarchy

```
BullhornError                    // base
├── BullhornAuthError            // Step A OR Step B failure (4xx on token/login)
├── BullhornRateLimitError       // 429 OR local bucket exhausted
├── BullhornNotFoundError        // 404 (returned as null from getters; thrown only for explicit-fail callers)
└── BullhornValidationError      // 400 (typically schema/business-rule on a write)
```

Errors NEVER include credential values in their `.message` — only key NAMES, status codes, and safe metadata. Per `review-mcp-connector.md` §5. The auth.ts Step-A failure path explicitly omits the response body verbatim because Bullhorn may echo the (now-invalid) refresh_token in error responses.

---

## Tests

```bash
# Unit + fixture tests (fast; no network)
pnpm test
```

**Fixture-first** per `review-mcp-connector.md` §6. The unit suite uses fixture responses constructed inline in tests; no live network calls.

**Live tests are deferred** to the first commercial Bullhorn signup — no `MCP_LIVE_TESTS`-gated `describe.skipIf(!LIVE)` block exists yet (honest-signal per review-mcp-connector §10 "Pre-build connector with `MCP_LIVE_TESTS` not yet wired: acceptable IF README marks the live tests as 'wired at first commercial signup'"). The live-test scaffold lands in the same commit as the first sandbox credentials per the W5 Phase 1 plan + the founder's Bullhorn dev-support enquiry sent 2026-06-02 (reply expected ~2026-06-09).

Test counts:
- `tests/scaffold.test.ts`: 5 (public surface + exports + error hierarchy)
- `tests/rate-limit.test.ts`: 5 (initial / soft-480 / hard-600 / per-corporation isolation / reset)
- `tests/auth.test.ts`: 7 (load-missing / round-trip / shouldRefresh for both tokens / Step-A+B happy-path / Step-A failure no-leak / Step-B failure / concurrent-dedup-per-corporation)
- `tests/capabilities.test.ts`: 12 (happy + error path per capability — candidates / placements / clients / contacts / notes — including the cluster F R4 401-forces-refresh-then-retry + 401-after-forced-refresh-throws-without-second-rotation pair)

**Total: 29 vitest** (target was ≥15 per `review-mcp-connector.md` §6 + W5 plan §1.A).

---

## Build

```bash
pnpm build       # tsup → dist/index.{js,d.ts}
pnpm typecheck   # tsc --noEmit
```

ESM-only; node 20+; target ES2022. Same toolchain as @ifos/xero.

---

## Where this fits in the IFOS architecture

```
agents/recruitment/{janitor,scribe,concierge}/cycle.sh
   │
   ├── Janitor Step 1 (auth refresh)           ──┐
   ├── Janitor Step 3 (candidate ingest)       ──┤
   ├── Janitor Step 5 (dedup merge write)      ──┤
   ├── Scribe Step 3 (post-call note write)    ──┼─→ @ifos/bullhorn (this package)
   ├── Concierge Step 3 (Bullhorn context)     ──┤    │
   ├── Concierge Step 12 (transport via Note)  ──┤    │
   └── Concierge Step 13 (activity-log write)  ──┘    │
                                                      ↓
                                                 Bullhorn REST API
                                                 https://rest.bullhornstaffing.com/rest-services/<corpToken>/
                                                      ↓
                                                 BhRestToken header (NOT OAuth access_token)
                                                 per-corporation_id rate-limit budget
```

---

## Boundary checks

Per `review-mcp-connector.md` §8:
- ✓ No Composio / AgentMail references in src/ or tests/
- ✓ No imports from `packages/harness/cortextos/` (submodule boundary)
- ✓ No direct writes to `decision_log` (vault/Postgres split — cycle.sh handles persistence via `_shared/hook-helpers.sh`)
- ✓ No hardcoded tenant slugs in `src/` (test fixtures only use `fixture-corp-*` / `test-corporation-*` patterns)

---

*v0.1.0 — scaffold landed 2026-06-02 W5 Day-28 per `docs/operations/goal-week-5-execution-plan.md` Phase 1.*
