// Minimal graph operations for the Ask-the-brain endpoint.
// Operates on the JSON shape that BrainGraph.graphJson holds:
//   { nodes: [{ id, label, community, source_file, file_type, d }],
//     edges: [{ s, t, r, c }],
//     communities: { [cid]: label } }
import { db } from '@intelforce/db';
import { embedBatch, vectorLiteral } from './embeddings';

export type GraphNode = {
  id: string;
  label: string;
  community: number;
  source_file?: string;
  file_type?: string;
  d?: number;
};

export type GraphEdge = {
  s: string;
  t: string;
  r: string;
  c: 'EXTRACTED' | 'INFERRED' | 'AMBIGUOUS';
};

export type GraphData = {
  nodes: GraphNode[];
  edges: GraphEdge[];
  communities?: Record<string, string>;
};

// Adjacency map for BFS
export function buildAdjacency(g: GraphData) {
  const adj: Record<string, { id: string; r: string; c: string }[]> = {};
  for (const e of g.edges) {
    (adj[e.s] = adj[e.s] || []).push({ id: e.t, r: e.r, c: e.c });
    (adj[e.t] = adj[e.t] || []).push({ id: e.s, r: e.r, c: e.c });
  }
  return adj;
}

/**
 * Semantic search: embed the query, find top-K nearest nodes via pgvector.
 * Falls back to substring matching when embeddings aren't present (no Cohere
 * key, or graph was built without embeddings).
 */
export async function findStartingNodesSemantic(
  brainGraphId: string,
  g: GraphData,
  question: string,
  max = 3,
): Promise<GraphNode[]> {
  if (!process.env.COHERE_API_KEY) {
    return findStartingNodes(g, question, max);
  }

  // Check if this graph has embeddings; skip the Cohere call if not
  const count = await db.brainNodeEmbedding.count({
    where: { brainGraphId },
  });
  if (count === 0) {
    return findStartingNodes(g, question, max);
  }

  try {
    const { embeddings } = await embedBatch([question], 'search_query');
    const queryVec = embeddings[0];
    if (!queryVec) return findStartingNodes(g, question, max);

    const literal = vectorLiteral(queryVec);

    // pgvector cosine-distance order. Smaller = closer. The HNSW index makes
    // this sub-millisecond for thousands of rows.
    const rows = await db.$queryRawUnsafe<{ node_id: string }[]>(
      `SELECT "node_id"
       FROM "ops"."brain_node_embeddings"
       WHERE "brain_graph_id" = $1::uuid
       ORDER BY "embedding" <=> $2::vector
       LIMIT $3`,
      brainGraphId,
      literal,
      max,
    );

    const byId = new Map(g.nodes.map((n) => [n.id, n]));
    return rows
      .map((r) => byId.get(r.node_id))
      .filter((n): n is GraphNode => Boolean(n));
  } catch (err) {
    console.warn('[brain-query] semantic search failed, falling back to substring:', err);
    return findStartingNodes(g, question, max);
  }
}

// Find starting nodes by token-overlap with the question. Used as the
// fallback when no embeddings exist or the Cohere call fails.
export function findStartingNodes(g: GraphData, question: string, max = 3): GraphNode[] {
  const tokens = question
    .toLowerCase()
    .split(/\W+/)
    .filter((t) => t.length > 2)
    // drop common stop words
    .filter((t) => !STOPWORDS.has(t));

  if (tokens.length === 0) return [];

  const scored: { node: GraphNode; score: number }[] = [];
  for (const n of g.nodes) {
    const label = (n.label || '').toLowerCase();
    let score = 0;
    for (const t of tokens) {
      if (label.includes(t)) {
        score += t.length; // longer matches outweigh short ones
      }
    }
    if (score > 0) scored.push({ node: n, score });
  }

  scored.sort((a, b) => b.score - a.score);
  return scored.slice(0, max).map((s) => s.node);
}

// BFS expansion from start nodes, capped at depth and total node budget.
// Returns the subgraph nodes and edges, plus a "trail" for citation.
export function bfsSubgraph(
  g: GraphData,
  starts: GraphNode[],
  opts: { depth?: number; maxNodes?: number } = {},
) {
  const depth = opts.depth ?? 2;
  const maxNodes = opts.maxNodes ?? 80;
  const adj = buildAdjacency(g);
  const byId: Record<string, GraphNode> = {};
  for (const n of g.nodes) byId[n.id] = n;

  const visited = new Set<string>(starts.map((n) => n.id));
  let frontier = new Set<string>(starts.map((n) => n.id));

  for (let d = 0; d < depth && visited.size < maxNodes; d++) {
    const next = new Set<string>();
    for (const id of frontier) {
      for (const a of adj[id] || []) {
        if (!visited.has(a.id) && visited.size < maxNodes) {
          visited.add(a.id);
          next.add(a.id);
        }
      }
    }
    frontier = next;
    if (next.size === 0) break;
  }

  const nodes = Array.from(visited)
    .map((id) => byId[id])
    .filter(Boolean);

  const subEdges = g.edges.filter((e) => visited.has(e.s) && visited.has(e.t));

  return { nodes, edges: subEdges, starts };
}

// Token-budget-aware textual rendering of the subgraph for grounding.
// Format roughly matches the /graphify query output so the Claude prompt
// stays consistent across CLI and dashboard usage.
export function renderSubgraph(
  sub: { nodes: GraphNode[]; edges: GraphEdge[]; starts: GraphNode[] },
  budget = 2000,
): string {
  const charBudget = budget * 4;
  const lines: string[] = [];
  lines.push(
    `Starting from: ${sub.starts.map((s) => s.label).join(' | ')} (${sub.nodes.length} nodes in subgraph)`,
  );
  lines.push('');

  for (const n of sub.nodes) {
    const meta = n.source_file ? `[src=${n.source_file}]` : '';
    lines.push(`NODE ${n.label} ${meta}`);
  }
  lines.push('');

  for (const e of sub.edges) {
    const s = sub.nodes.find((n) => n.id === e.s);
    const t = sub.nodes.find((n) => n.id === e.t);
    if (!s || !t) continue;
    lines.push(`EDGE ${s.label} --${e.r} [${e.c}]--> ${t.label}`);
  }

  let out = lines.join('\n');
  if (out.length > charBudget) {
    out = out.slice(0, charBudget) + `\n... (truncated at ~${budget} token budget)`;
  }
  return out;
}

const STOPWORDS = new Set([
  'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'her',
  'was', 'one', 'our', 'out', 'his', 'has', 'have', 'this', 'that', 'with',
  'from', 'they', 'will', 'would', 'there', 'their', 'what', 'when', 'where',
  'which', 'who', 'why', 'how', 'how does', 'does', 'about', 'into', 'than',
  'then', 'them', 'these', 'those', 'such', 'some',
]);
