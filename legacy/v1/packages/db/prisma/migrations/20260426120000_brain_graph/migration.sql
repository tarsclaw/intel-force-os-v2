-- Brain feature: per-tenant knowledge graphs
-- Apply with: pnpm --filter @intelforce/db prisma db push  (development)
--          or pnpm --filter @intelforce/db prisma migrate deploy  (production)

-- CreateEnum: BrainGraphStatus
CREATE TYPE "ops"."BrainGraphStatus" AS ENUM (
  'PENDING',
  'BUILDING',
  'READY',
  'FAILED',
  'STALE'
);

-- CreateEnum: EdgeDecision
CREATE TYPE "ops"."EdgeDecision" AS ENUM (
  'APPROVED',
  'REJECTED',
  'UNCERTAIN'
);

-- CreateTable: brain_graphs
CREATE TABLE "ops"."brain_graphs" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "tenant_id" UUID NOT NULL,
  "status" "ops"."BrainGraphStatus" NOT NULL DEFAULT 'PENDING',
  "graph_json" JSONB,
  "node_count" INTEGER,
  "edge_count" INTEGER,
  "community_count" INTEGER,
  "source_files" JSONB,
  "version" INTEGER NOT NULL DEFAULT 1,
  "generated_at" TIMESTAMP(3),
  "duration_ms" INTEGER,
  "input_tokens" INTEGER,
  "output_tokens" INTEGER,
  "cost_gbp" DECIMAL(10, 6),
  "last_error" TEXT,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "brain_graphs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "brain_graphs_tenant_id_key" ON "ops"."brain_graphs"("tenant_id");
CREATE INDEX "brain_graphs_tenant_id_idx" ON "ops"."brain_graphs"("tenant_id");
CREATE INDEX "brain_graphs_status_idx" ON "ops"."brain_graphs"("status");

-- AddForeignKey: brain_graphs → tenants (control schema)
ALTER TABLE "ops"."brain_graphs"
  ADD CONSTRAINT "brain_graphs_tenant_id_fkey"
  FOREIGN KEY ("tenant_id") REFERENCES "control"."tenants"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- CreateTable: brain_edge_reviews
CREATE TABLE "ops"."brain_edge_reviews" (
  "id" UUID NOT NULL DEFAULT gen_random_uuid(),
  "brain_graph_id" UUID NOT NULL,
  "edge_key" TEXT NOT NULL,
  "source_node_id" TEXT NOT NULL,
  "target_node_id" TEXT NOT NULL,
  "relation" TEXT NOT NULL,
  "decision" "ops"."EdgeDecision" NOT NULL,
  "reviewer_id" UUID,
  "reviewer_note" TEXT,
  "reviewed_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "brain_edge_reviews_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "brain_edge_reviews_brain_graph_id_edge_key_key"
  ON "ops"."brain_edge_reviews"("brain_graph_id", "edge_key");
CREATE INDEX "brain_edge_reviews_brain_graph_id_decision_idx"
  ON "ops"."brain_edge_reviews"("brain_graph_id", "decision");

-- AddForeignKey: brain_edge_reviews → brain_graphs (cascade delete)
ALTER TABLE "ops"."brain_edge_reviews"
  ADD CONSTRAINT "brain_edge_reviews_brain_graph_id_fkey"
  FOREIGN KEY ("brain_graph_id") REFERENCES "ops"."brain_graphs"("id")
  ON DELETE CASCADE ON UPDATE CASCADE;
