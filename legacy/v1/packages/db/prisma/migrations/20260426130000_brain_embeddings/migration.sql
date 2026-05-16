-- Per-node embeddings for semantic search.
-- Apply with: pnpm --filter @intelforce/db prisma db push  (development)
--          or pnpm --filter @intelforce/db prisma migrate deploy  (production)

-- pgvector extension is already declared in schema.prisma but if you applied
-- the previous migration without it, this is a no-op safety net.
CREATE EXTENSION IF NOT EXISTS vector;

-- CreateTable: brain_node_embeddings
CREATE TABLE "ops"."brain_node_embeddings" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "brain_graph_id" UUID NOT NULL,
  "node_id" TEXT NOT NULL,
  "label" TEXT NOT NULL,
  "source_file" TEXT,
  "embedding" vector(1024) NOT NULL,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "brain_node_embeddings_pkey" PRIMARY KEY ("id")
);

-- Uniqueness: one embedding per (graph, nodeId)
CREATE UNIQUE INDEX "brain_node_embeddings_brain_graph_id_node_id_key"
  ON "ops"."brain_node_embeddings"("brain_graph_id", "node_id");

CREATE INDEX "brain_node_embeddings_brain_graph_id_idx"
  ON "ops"."brain_node_embeddings"("brain_graph_id");

-- HNSW index on the embedding column for fast cosine-distance nearest-neighbour
-- queries. Used by the `/api/brain/[slug]/ask` semantic-find logic.
CREATE INDEX "brain_node_embeddings_embedding_hnsw_idx"
  ON "ops"."brain_node_embeddings"
  USING hnsw ("embedding" vector_cosine_ops);

-- FK to brain_graphs (cascade — embeddings die with the graph)
ALTER TABLE "ops"."brain_node_embeddings"
  ADD CONSTRAINT "brain_node_embeddings_brain_graph_id_fkey"
  FOREIGN KEY ("brain_graph_id") REFERENCES "ops"."brain_graphs"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
