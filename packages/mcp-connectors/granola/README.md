# @ifos/granola

IFOS MCP wrapper for [Granola](https://granola.ai) — a typed surface over the official Granola MCP server at `https://mcp.granola.ai/mcp` with IFOS-specific rate-limit, plan-tier guard, ESC mapping, and audit-trail wiring.

The Scribe agent (W6+) is the primary consumer; it polls `list_meetings` every 5 minutes per tenant and pulls transcripts on-demand for new meetings.

---

## Status

- **v0.1.0 SCAFFOLD** — landed W5 Day-29 Phase 3 (this commit). Built to be Bullhorn-independent and to mirror `@ifos/bullhorn` (commit `ff0f7b6`) + `@ifos/workos` (commit `6dc5a4a`) with Granola-specific deltas (PKCE, plan-tier guard, transport abstraction).
- **Live tests deferred** per the honest-signal pattern from cluster F OB R3 closure — the Granola account + browser-OAuth dance is a founder gate (see plan doc §4). The fixture-first test layer covers protocol shape and surface; live network tests land when the workspace is provisioned.
- **The `@modelcontextprotocol/sdk` transport binding is W5-live work.** v0.1.0 ships a `GranolaTransport` interface that tests inject fakes into; live wiring plugs `StreamableHTTPClientTransport` from the MCP SDK at first commercial signup.

---

## Capabilities (bus-routed)

The capability set is **set-equal** with the 6 official Granola MCP tools verified 2026-06-03 via WebFetch of `docs.granola.ai/help-center/sharing/integrations/integrations-with-granola` + the linked MCP setup guide:

| IFOS function | Official MCP tool | Plan tier | Purpose |
|---|---|---|---|
| `listMeetings(client, options)` | `list_meetings` | All | Scribe primary 5-min poll; date-range + folder filter |
| `getMeeting(client, id)` | `get_meetings` | All | Single-meeting hydrate (note: Granola's tool is plural "get_meetings" — wire-level naming honoured) |
| `queryMeetings(client, options)` | `query_granola_meetings` | All | Semantic search across notes (Free is capped to last 30d) |
| `listFolders(client, options)` | `list_meeting_folders` | **Paid** | Folder listing for the workspace |
| `getTranscript(client, id)` | `get_meeting_transcript` | **Paid** | Per-meeting transcript with speaker segments |
| `getAccountInfo(client)` | `get_account_info` | All | Workspace + plan-tier introspection (used by Scribe to pre-cache `plan_tier` and short-circuit the per-call guard) |

The **`PAID_PLAN_TOOLS` constant** lists the two Paid-only tools; the `GranolaClient` enforces a pre-emptive guard when `plan_tier_hint` or cached account info indicates Free, AND maps a live 403 surface to the same typed error. Free workspaces never hit the wire on a Paid-only call.

### Deviation from /goal plan-doc text

The goal-week-5-execution-plan.md §2 Phase 3 text named **4 capabilities** with a **`'basic'|'business'|'enterprise'`** plan-tier triple. The ACTUAL Granola MCP surface (verified via docs WebFetch 2026-06-03) is:

- **6 tools**, not 4 (the plan grouped meetings into one capability; the real API has three meeting tools + 1 folder + 1 transcript + 1 account)
- **`'free'|'paid'`** plan tiers, not `'basic'|'business'|'enterprise'` (Granola's docs gate features simply as "All plans" vs "Paid plans only")

This package honours the **actual API** rather than the plan-doc approximation; the EOD report flags this for fix-forward on the plan doc.

---

## Authentication

Granola uses **OAuth 2.0 + Dynamic Client Registration + PKCE (S256)** per the official docs ("credentials are handled automatically. You don't need to generate or enter any client ID or client secret"). The flow:

1. **Founder dance (per workspace, one-time):**
   - IFOS generates a PKCE pair via `generatePkcePair()` — returns `{code_verifier, code_challenge}`.
   - IFOS sends the founder to `https://api.granola.ai/oauth/authorize?client_id=…&code_challenge=…&code_challenge_method=S256&state=…&redirect_uri=…` (browser).
   - Founder grants consent; Granola redirects with `?code=…&state=…`.
   - IFOS calls `exchangeAuthCode(config, code, code_verifier, redirect_uri)` — exchanges for `{access_token, refresh_token, expires_in}` and persists atomically to `~/.ifos-local-vault/<tenant>/granola-tokens-<workspace_id>.json` (mode 0600).
2. **Steady state (per API call):**
   - `GranolaClient.getValidToken()` loads the token from disk; refreshes eagerly if within 2-min safety window.
   - Refresh: POST `/oauth/token` with `grant_type=refresh_token`; rotated tokens are persisted atomically; concurrent refresh calls converge on ONE rotation per workspace_id (Promise dedup).
   - 401 surfaces force one refresh per request lifecycle (per cluster F R4 `didForceRefresh` lesson) before throwing `GranolaAuthError`.

**Secrets discipline (per `review-mcp-connector` §5):** the `access_token` and `refresh_token` are NEVER interpolated into error messages or logs. Errors carry status codes + workspace_id + tool name + safe metadata only.

TODO(W5-live): verify the exact `/oauth/token` + `/oauth/register` endpoint paths during first commercial signup. The public Granola docs reference "browser OAuth" but do not publish the raw endpoint URLs; the package holds placeholders at `https://api.granola.ai/oauth/{token,register}` pending verification.

---

## Scribe consumption pattern

**Granola does NOT publish a webhook surface** for new-meeting events. The Scribe agent ingestion pattern is therefore **polling-based** rather than push-based:

```
EVERY 5 MIN (cron):
  for each tenant T:
    accountInfo = getAccountInfo(client[T])    # 1h cached
    meetings = listMeetings(client[T], {       # 5min cached
      start_date: T.last_polled_at,
      end_date: now()
    })
    for each meeting M in meetings:
      if M.has_transcript AND accountInfo.transcripts_enabled:
        transcript = getTranscript(client[T], M.id, {plan_tier_hint: 'paid'})
        scribe.ingest(M, transcript)
      else:
        scribe.ingest(M, null)    # notes-only ingest
    T.last_polled_at = now()
```

The 5-minute poll cadence × per-tenant rate-limit 60/min (1/sec sustained) gives ~300 polls/tenant/hour of headroom while the steady state is ~12 polls/tenant/hour. Backfill operations (initial ingest for a new tenant) burn into the headroom; the soft 80% backoff at 48/min signals when to throttle.

---

## Rate limits

Granola does NOT publish a per-workspace rate-limit number in the MCP docs (the docs are user-facing rather than developer-facing). v1.0 conservative default:

- **Per-`workspace_id` bucket** (multi-tenant safe).
- **Hard ceiling: 60/minute** per bucket (1/sec sustained — well above Scribe's 5-min poll cadence; covers transcript backfills).
- **Soft backoff: 48/minute** (80%). At soft, `rateCheck()` reports `shouldBackoff: true` but `consume()` still succeeds.
- **Hard fail: 60/minute** (100%). `consume()` returns `false` and the client throws `GranolaRateLimitError` pre-emptively.

TODO(W5-live): verify exact Granola rate-limit numbers during first commercial signup; tune `MINUTE_HARD` if the upstream telemetry shows headroom for higher throughput.

---

## Error hierarchy

| Class | When | Maps to ESC |
|---|---|---|
| `GranolaError` | Base | (none — base; downstream picks the typed leaf) |
| `GranolaAuthError` | 401 OR no-tokens-on-disk OR refresh-rejected | `ESC_GRANOLA_AUTH` (pending W6 escalation-codes.md addition) |
| `GranolaRateLimitError` | 429 from upstream OR local bucket exhausted | `ESC_RATE_LIMIT_HIT` (warn; payload.upstream='granola') |
| `GranolaNotFoundError` | 404 from any tool; `get*` translates to null, `list*` throws | (none — surface to consumer) |
| `GranolaPlanTierInsufficientError` | Pre-guard (free plan + Paid-only tool) OR upstream 403 | `ESC_GRANOLA_PLAN_TIER` (pending W6; consumer degrades to notes-only ingest + operator surface) |

Per `review-mcp-connector` §5: **error messages NEVER include token values verbatim** — only status code, tool name, workspace_id, and safe metadata.

---

## Caching

`GranolaCache` (disk; mode 0600):

- **Transcripts**: 10-min TTL — transcripts are immutable once generated, so longer TTLs would also be safe; 10min keeps disk usage bounded.
- **Meetings (list + get)**: 5-min TTL — matches Scribe's poll cadence.
- **Folders**: 10-min TTL.
- **Account info**: 1-hour TTL — plan tier rarely changes.

Cache files at `~/.ifos-cache/granola/` keyed by SHA-256 of the cache namespace + identifier. Override via `IFOS_GRANOLA_CACHE_DIR` env.

---

## Reference implementation

This package mirrors `@ifos/bullhorn` (commit `ff0f7b6`) + `@ifos/workos` (commit `6dc5a4a`) with these Granola-specific additions:

- **OAuth 2.1 PKCE + DCR** (vs Bullhorn's two-step refresh, WorkOS's long-lived bearer).
- **Plan-tier guard** (`PAID_PLAN_TOOLS` + `plan_tier_hint` option + cached account info short-circuit).
- **MCP transport abstraction** (`GranolaTransport` interface; default HTTP wire is W5-live work via @modelcontextprotocol/sdk).
- **Wire-shape parsers** (`parsers.ts`) — Granola MCP returns each tool's result as `{type:"text",text:JSON.stringify(...)}` content blocks; the parsers extract + validate strictly (any wire-shape break throws `GranolaError` rather than silently coercing).

---

## Local development

```bash
cd packages/mcp-connectors/granola
pnpm install
pnpm typecheck   # must pass clean
pnpm test        # vitest run; ≥18 tests across scaffold + rate-limit + auth + capabilities
pnpm build       # tsup ESM + DTS
```

All tests use fixture-first fakes (in-process `GranolaTransport` stubs); **no live network calls** at this version.

---

## v1.1+ scope (deferred)

- **Live MCP transport binding** via `@modelcontextprotocol/sdk` (W5-live; first commercial signup)
- **Webhook surface** when Granola publishes one (currently polling-only)
- **Speaker identification beyond Granola's labels** (consumer-side LLM enrichment)
- **Bullhorn write-back of transcripts** as Notes (Scribe-side, not this package)
- **`MCP_LIVE_TESTS=1` block** (lands once founder confirms Granola workspace + completes browser OAuth dance)
