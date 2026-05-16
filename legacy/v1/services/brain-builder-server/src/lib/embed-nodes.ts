import { db } from './db';

interface GraphNode {
  id: string;
  label: string;
  source_file?: string | null;
}

const COHERE_ENDPOINT = 'https://api.cohere.com/v2/embed';
const COHERE_MODEL = process.env.COHERE_EMBED_MODEL ?? 'embed-english-v3.0';
const BATCH = 96;

/**
 * Embed every node in the freshly-built graph and write to ops.brain_node_embeddings.
 *
 * The text we embed is `<label> · <source_file>` — short enough to stay cheap,
 * long enough that searching for "handbook grievance" finds nodes whose source
 * is the handbook even if the label doesn't say "handbook".
 *
 * Idempotent: deletes prior embeddings for this brain graph before inserting,
 * so re-running this on a rebuilt graph is safe.
 */
export async function embedNodes(brainGraphId: string, graph: unknown): Promise<void> {
  const apiKey = process.env.COHERE_API_KEY;
  if (!apiKey) {
    throw new Error('COHERE_API_KEY not set');
  }

  const g = graph as { nodes?: GraphNode[] };
  const nodes = g.nodes ?? [];
  if (nodes.length === 0) return;

  // Wipe prior embeddings so we don't duplicate or leak stale vectors
  await db.brainNodeEmbedding.deleteMany({ where: { brainGraphId } });

  // Embed in batches of 96 (Cohere max)
  for (let i = 0; i < nodes.length; i += BATCH) {
    const batch = nodes.slice(i, i + BATCH);
    const texts = batch.map(
      (n) => `${n.label}${n.source_file ? ` · ${n.source_file}` : ''}`,
    );

    const response = await fetch(COHERE_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: COHERE_MODEL,
        input_type: 'search_document',
        embedding_types: ['float'],
        texts,
      }),
    });

    if (!response.ok) {
      const body = await response.text();
      throw new Error(`Cohere embed ${response.status}: ${body.slice(0, 300)}`);
    }

    const data = (await response.json()) as {
      embeddings: { float: number[][] };
    };

    // Insert via $executeRaw because Prisma doesn't speak `vector` natively.
    // We build a single multi-row INSERT for efficiency.
    const values = batch
      .map((n, idx) => {
        const v = data.embeddings.float[idx];
        const literal = '[' + v.map((x) => x.toFixed(6)).join(',') + ']';
        // Inline the vector literal directly because $queryRawUnsafe doesn't
        // accept an array as a vector parameter. Other fields use parameterised
        // values to prevent SQL injection.
        return `(gen_random_uuid(), $1, $${idx * 3 + 2}, $${idx * 3 + 3}, $${idx * 3 + 4}, '${literal}'::vector, NOW())`;
      })
      .join(',');

    const params: unknown[] = [brainGraphId];
    for (const n of batch) {
      params.push(n.id, n.label, n.source_file ?? null);
    }

    const sql = `
      INSERT INTO "ops"."brain_node_embeddings"
        ("id", "brain_graph_id", "node_id", "label", "source_file", "embedding", "created_at")
      VALUES ${values}
      ON CONFLICT ("brain_graph_id", "node_id") DO UPDATE
        SET "embedding" = EXCLUDED."embedding",
            "label" = EXCLUDED."label",
            "source_file" = EXCLUDED."source_file"
    `;

    await db.$executeRawUnsafe(sql, ...params);
  }
}
