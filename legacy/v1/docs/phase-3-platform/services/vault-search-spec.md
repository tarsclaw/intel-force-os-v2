# `vault-search` CLI Specification

**The retrieval helper that every agent's `context.sh` calls to fetch semantically-similar prior content from pgvector.**

> **Audience:** the engineer implementing CC9 (platform helpers — `vault-search`, `cost-report`, `hook-runner`, `tenant-supervisor`, `cc-invoke`).
>
> **Status:** v1.0. Small Node.js CLI. Baked into every tenant container image at `/tenant/.claude/bin/vault-search`.
>
> **Why this matters:** agents are only as good as the context injected into them. `vault-search` is the single point of retrieval — fix it once, every agent improves.

---

## 1. Interface

```
Usage: vault-search [options]

Required:
  --query <text>           The retrieval query (2–2000 chars)

Optional:
  --tag <tag>              Filter results by a frontmatter tag
  --top-k <n>              Number of results to return (default 3, max 10)
  --min-similarity <0-1>   Minimum cosine similarity (default 0.3)
  --exclude-path <glob>    Paths to exclude (can repeat)
  --format <text|json>     Output format (default json)
  --tenant-id <id>         Tenant ID (auto-detected from env in production)
  --agent <name>           Agent name for telemetry (auto-detected)
  --timeout-ms <n>         Abort after N ms (default 3000)
  --explain                Emit debug info alongside results
```

Exit codes:
- `0` — success (even if 0 results)
- `1` — recoverable error (DB unavailable, embedding provider down); caller retries or degrades
- `2` — bad input (malformed query, invalid tag)
- `3` — configuration error (can't find secret for Cohere, can't connect to DB)

---

## 2. Behaviour

### 2.1 Normal path

```
1. Read tenant config → get Cohere API key ref, Postgres DSN ref
2. Resolve secrets from Secrets Vault
3. Call Cohere /embed with input_type=search_query, get 1024-dim vector
4. Query pgvector:
   SELECT id, source_path, content, tags, frontmatter, embedding <=> $1 AS distance
   FROM tenant_{tid}.chunks
   WHERE (tag IS NULL OR $2 = ANY(tags))
     AND (path_exclude IS NULL OR NOT (source_path LIKE ANY ($3)))
     AND embedding <=> $1 < $min_dist
   ORDER BY distance
   LIMIT $k
5. Format output
6. Log telemetry to control.retrieval_queries
7. Exit 0 with JSON to stdout
```

### 2.2 Output format

`--format json` (default):
```json
{
  "query": "dental marketing agency proposal",
  "tenant_id": "tnt_01JKDY...",
  "top_k_requested": 3,
  "result_count": 3,
  "latency_ms": 182,
  "results": [
    {
      "chunk_id": 12345,
      "source_path": "/vault/clients/crescent-dental/proposals/2026-01-15-crescent-dental-v1.md",
      "content": "...full chunk text...",
      "tags": ["proposal", "dental", "winning-proposal"],
      "metadata": {
        "prospect": "Crescent Dental",
        "deal_value": "£16,200/month",
        "closed_at": "2026-01-20",
        "outcome": "won"
      },
      "distance": 0.18,
      "similarity": 0.82
    },
    ...
  ]
}
```

`--format text`:
```
### Past proposal — Crescent Dental (deal: £16,200/month, closed: 2026-01-20)

...full content...

---

### Past proposal — Willow Family Dentistry ...
```

This text format matches exactly what `hh_format_retrieved` in the shared hook library expects — the two are a matched pair.

### 2.3 Error path

On any failure, emit to stderr and exit with appropriate code. Stdout gets:

```json
{
  "error": "embedding_provider_failed",
  "error_detail": "Cohere API returned 503",
  "results": []
}
```

This shape lets `context.sh` degrade gracefully — `hh_format_retrieved` handles the `error` field and falls back to "*(Retrieval unavailable: ...)*".

---

## 3. Authentication

### 3.1 Cohere

API key loaded from Secrets Vault via service-to-service auth:
```
GET {SECRETS_VAULT_URL}/v1/secrets/secrets://{tenant_id}/cohere/api_key
Authorization: Bearer {service_token}
```

Cached in-memory for 60 seconds to avoid per-call overhead. Re-fetched on expiry.

### 3.2 Postgres

Tenant-specific role. Connection string:
```
postgres://tenant_{tid}:{password}@{pg_host}/intelforce?sslmode=require
```

Password is loaded from Secrets Vault too. Connection pooled (pool size 2 per `vault-search` invocation — the CLI is short-lived, pool is essentially unused, but keeps PgBouncer happy).

### 3.3 RLS session

Before any query:
```sql
SET LOCAL app.current_tenant_id = 'tnt_01JKDY...';
```

Enforces that even if the tenant's DB credentials leaked, queries can only see that tenant's RLS-scoped rows — belt-and-braces over the schema-level isolation.

---

## 4. Query embedding

### 4.1 Model

`cohere-embed-v3` with `input_type=search_query` (different from `search_document` used by Librarian for indexing — this is important: Cohere's asymmetric retrieval model requires it).

### 4.2 Region

`api.eu.cohere.com` for EU tenants. Enforced at the API-call level, not at the configuration level — the CLI refuses to call non-EU endpoints even if config says otherwise.

### 4.3 Caching

Queries are NOT cached. Even identical query text gets re-embedded. Reasons:
- Query cost is negligible (~£0.0002 per query)
- Cache invalidation is hard (when does the underlying corpus change?)
- Debugging is easier when every query takes the same path

If we ever exceed 100 queries/minute per tenant, revisit — but at that point, something's wrong upstream (no agent legitimately needs that rate).

---

## 5. pgvector query

### 5.1 Distance metric

Cosine distance (`<=>` operator in pgvector). Most appropriate for Cohere's unit-normalised embeddings.

### 5.2 Default threshold

`similarity >= 0.3` (equivalent to `distance <= 0.7`). Empirically, below 0.3 the results are noise — better to return fewer high-quality results than pad with irrelevant ones.

### 5.3 Performance

With HNSW index (`m=16, ef_construction=64`), we measure:
- 1k chunks per tenant → <10ms p95
- 10k chunks per tenant → <30ms p95
- 100k chunks per tenant → <150ms p95

Target is `<200ms p95 end-to-end including Cohere embedding` — easy to hit under 10k chunks, requires index tuning beyond that.

### 5.4 Tag filtering

If `--tag` provided, pgvector combines the ANN search with a tag filter. HNSW doesn't directly support filtered search — we use a post-filter:

```sql
SELECT ... WHERE tags @> ARRAY[$tag]::text[] AND embedding <=> $query_vec < $threshold
ORDER BY embedding <=> $query_vec
LIMIT $k;
```

Post-filter means we may need to scan more than `$k` candidates internally to find `$k` matching the tag. pgvector tuning parameter `hnsw.ef_search` controls this — default 40, we set to 100 for better recall under filters.

### 5.5 Path exclusion

Used by some agents to exclude draft/archived content. `--exclude-path /vault/archive/**` → translated to SQL `NOT LIKE '/vault/archive/%'` — can chain multiple.

---

## 6. Telemetry

Every invocation writes to `control.retrieval_queries`:

```sql
INSERT INTO control.retrieval_queries
  (tenant_id, invocation_id, agent, query_text, tag_filter, top_k, result_count, result_chunk_ids, latency_ms)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9);
```

- `invocation_id` sourced from `CLAUDE_SESSION_ID` env var mapping (the supervisor sets this)
- Query text is NOT redacted — it's not user input, it's agent-generated from context
- `result_chunk_ids` is the array of chunk IDs returned, used by Librarian for orphan detection

Separate from the query telemetry, the CLI also emits a structured log line for Vector to ship:

```json
{
  "ts": "2026-04-22T15:50:12.456Z",
  "service": "vault-search",
  "tenant_id": "tnt_01JKDY...",
  "invocation_id": 12345,
  "agent": "proposal-builder",
  "event": "retrieval_completed",
  "query_length": 1823,
  "tag_filter": "winning-proposal",
  "top_k": 3,
  "result_count": 3,
  "latency_ms": 182,
  "embedding_latency_ms": 95,
  "db_latency_ms": 42,
  "min_similarity": 0.71,
  "max_similarity": 0.89
}
```

---

## 7. Testing

### 7.1 Unit tests

- Arg parsing (required, optional, validation)
- Output format for various result counts
- Error path emits proper exit codes
- Tag filter SQL generation

### 7.2 Integration tests

Against a staging Postgres with seeded chunks:
- Query returns expected nearest neighbours
- Tag filter works
- Path exclusion works
- Min-similarity threshold works

### 7.3 Load test

A single tenant's `vault-search` should handle 100 queries/minute without degradation. We don't expect this volume in practice (agents are one-shot), but it's a good resilience floor.

---

## 8. Packaging

- Single-binary via `pkg` or Node's native `--experimental-sea-config` (single-executable application)
- Baked into tenant image at `/tenant/.claude/bin/vault-search`
- Also shipped as a standalone CLI for operator debugging: `intelforce vault-search --tenant tnt_xxx --query "..."` (admin-only, connects via the platform's read-only role)

---

## 9. Operator commands

Operators can invoke `vault-search` for any tenant from a jump host:

```bash
# What does a query look like for Meadow Lane Dental today?
intelforce vault-search \
  --tenant tnt_01JKDY... \
  --query "dental marketing proposal Manchester" \
  --tag winning-proposal \
  --explain

# Returns full result + timing breakdown + the embedding vector (redacted to first 5 dims)
```

Useful for:
- Debugging "why did the agent retrieve that weird piece?"
- Validating a newly-indexed vault has searchable content
- Checking retrieval quality after a voice profile change

---

## 10. Implementation checklist (for CC9, partial — vault-search only)

- [ ] Node.js TypeScript project
- [ ] Commander or yargs for arg parsing
- [ ] Cohere client (officially supported SDK or raw fetch)
- [ ] `pg` Postgres client
- [ ] Secrets Vault client (mTLS)
- [ ] Structured logger (pino)
- [ ] Single-binary build via pkg/SEA
- [ ] Unit tests
- [ ] Integration tests against staging
- [ ] Packaged into tenant image
- [ ] Documented in runbooks

---

## 11. What this CLI does NOT do

- **Doesn't index content** — that's Librarian's job. `vault-search` only reads.
- **Doesn't handle filesystem paths directly** — it queries pgvector and returns chunk metadata. The caller is responsible for reading full files if needed (rare — the chunks typically have enough context).
- **Doesn't support non-Cohere embeddings in v1** — pluggable model support is v1.2 work. For now, tenant must use Cohere.
- **Doesn't return embeddings** — only content and metadata. If you need embeddings, query pgvector directly with the operator role.

---

## 12. Related helpers in the same `/tenant/.claude/bin/` package

These are part of CC9 but specified elsewhere:

- `cost-report` — aggregates `control.costs` for a tenant; used by dashboard (spec in Phase 4)
- `hook-runner` — wrapper that invokes agent hooks with proper timeout + logging (spec in Phase 6 ops)
- `tenant-supervisor` — the long-lived supervisor process itself (spec in `phase-1-poc-stack/platform-specs/tenant-container-spec.md` §7)
- `cc-invoke` — the wrapper around the Claude Code CLI (spec in `phase-1-poc-stack/platform-specs/tenant-container-spec.md` §6)

Together these four binaries are "platform helpers" — shipped into every tenant image, maintained as one package, released with the image.
