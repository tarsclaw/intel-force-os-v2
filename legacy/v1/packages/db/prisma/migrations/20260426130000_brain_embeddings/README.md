# Migration: brain_embeddings

Adds per-node vector embeddings for semantic search.

## What it creates

- `ops.brain_node_embeddings` — one row per (graph, node) holding a 1024-dim
  Cohere embedding plus the node label + source file for fast preview without
  joining `brain_graphs`.
- HNSW index on the embedding column for sub-second cosine-distance queries.

## How to apply

**Development:**
```bash
pnpm --filter @intelforce/db prisma db push
```

**Production:**
```bash
pnpm --filter @intelforce/db prisma migrate deploy
```

## Reversibility

```sql
DROP TABLE "ops"."brain_node_embeddings";
```

The `vector` extension is left in place — it's harmless, and removing it would
break other unrelated future use.

## Pre-requisites

The `vector` extension must be installed:
```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

Most managed Postgres providers (Neon, Supabase, RDS, Cloud SQL with
`extensionsupgradesfrom`, Postgres ≥ 14) support pgvector. If yours doesn't,
swap to a separate vector store (Qdrant, Weaviate) and adapt
`lib/embeddings.ts` accordingly.
