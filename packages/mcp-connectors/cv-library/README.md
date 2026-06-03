# @ifos/cv-library

IFOS MCP connector for [CV-Library](https://www.cv-library.co.uk) — a thin, typed wrapper over the CV-Library Recruiter API candidate-search surface. Used by Sourcing Scout (W9) as source #3 in the v1.0 3-source candidate pool (Bullhorn passive-match + Reed + CV-Library; LinkedIn deferred to v1.1+).

---

## Status

- **v0.1.0 SCAFFOLD** — landed W5 Day-34 Phase 8 of the marathon /goal. Sibling commit to `@ifos/reed`; same long-lived-key pattern.
- **Auth model PLACEHOLDER pending W6-live verification.** CV-Library recruiter docs are accessible post-signup only (2026-06-03 WebFetch attempt of `cv-library.co.uk/recruiter` returned 403). v0.1.0 supports BOTH HTTP Basic (mirror Reed) AND Bearer (mirror WorkOS) via the `CVLibraryConfig.auth_mode` field to avoid commit churn when the actual answer lands. Founder commercial signup per `docs/operations/founder-api-signups-2026-06-03.md` P3 unblocks the verification.
- **Live tests deferred** per honest-signal pattern from cluster F OB R3 closure.

---

## Authentication

**Dual-mode placeholder.** v0.1.0 supports either:
- **`auth_mode: 'basic'`** with `api_key` field — `Authorization: Basic base64(api_key:)` (mirrors Reed verified pattern)
- **`auth_mode: 'bearer'`** with `access_token` field — `Authorization: Bearer <token>` (mirrors WorkOS verified pattern)

At W6-live verification, whichever the CV-Library Recruiter API actually uses becomes the production default; the unused mode stays available as a fallback. Same long-lived-key shape as Reed + WorkOS — NO refresh dance; 401 surfaces immediately as `CVLibraryAuthError`.

### Credential provisioning

The founder bootstraps the credential **once** per environment:

1. Sign in to the CV-Library recruiter portal (`https://www.cv-library.co.uk`).
2. Navigate **Recruiters** → look for API access (commercial signup per founder playbook P3; may require email to CV-Library account manager).
3. Once issued: copy the API key or access token.
4. Add to IFOS deployment env:
   - For Basic mode: `CVLIBRARY_API_KEY=<key>` + `CVLIBRARY_AUTH_MODE=basic`
   - For Bearer mode: `CVLIBRARY_ACCESS_TOKEN=<token>` + `CVLIBRARY_AUTH_MODE=bearer`
5. Restart the IFOS process so the new env-var is picked up.

---

## Capabilities (bus-routed)

| Function | Endpoint (placeholder) | Purpose |
|---|---|---|
| `searchCandidates(client, options)` | `GET /v1/candidates/search` | Sourcing Scout Step 6 — candidate search |
| `getCandidate(client, candidate_id)` | `GET /v1/candidates/{id}` | Single-candidate hydrate |

**2 capabilities** at v0.1.0. TODO(W6-live) markers throughout for exact endpoint paths + query param names verified at commercial signup.

---

## Rate limits

CV-Library does NOT publish rate-limit numbers anonymously (recruiter docs post-signup only). v0.1.0 conservative default:

- Per-`account_id` bucket; **60/minute hard**; soft backoff at 48/minute (80%)

TODO(W6-live): verify exact rate-limit numbers at commercial signup; tune `MINUTE_HARD` accordingly.

---

## Error hierarchy

| Class | When | Maps to ESC |
|---|---|---|
| `CVLibraryError` | Base | (none) |
| `CVLibraryAuthError` | 401; NO retry | `ESC_CVLIBRARY_AUTH` (blocking per catalogue §2.7) |
| `CVLibraryRateLimitError` | 429 OR local bucket exhausted | `ESC_RATE_LIMIT_HIT` (warn; payload.upstream='cv-library') |
| `CVLibraryNotFoundError` | 404; `get*` translates to null | (none) |
| `CVLibraryValidationError` | 400 | `ESC_CVLIBRARY_VALIDATION_FAIL` (warn; QUEUED for catalogue at W6) |

Per `review-mcp-connector` §5: error messages NEVER include credential values verbatim.

---

## Caching

`CVLibraryCache` — disk; mode 0600; 1-hour TTL (matches job-market churn). Cache files at `~/.ifos-cache/cv-library/`. Override via `IFOS_CVLIBRARY_CACHE_DIR`.

---

## Reference implementation

Mirrors `@ifos/reed` (Day-34 Phase 8 sibling commit) with these deltas:
- **Dual auth_mode field** (Basic OR Bearer) vs Reed's Basic-only — CV-Library auth unverified at v0.1.0
- **Single salary_expectation** field on Candidate vs Reed's min+max band
- **offset+limit pagination** vs Reed's resultsToTake+resultsToSkip
- **`api.cv-library.co.uk` base URL** (placeholder; verify at W6-live)

---

## Local development

```bash
cd packages/mcp-connectors/cv-library
pnpm install
pnpm typecheck
pnpm test
pnpm build
```

All tests fixture-first; no live network.

---

## v1.1+ scope (deferred)

- Endpoint path + auth mode + rate-limit verification at commercial signup
- POST/PUT job postings (v1.0 read-only)
- Application retrieval per posting
- `MCP_LIVE_TESTS=1` block (post-signup)
