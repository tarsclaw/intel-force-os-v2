// Cohere embed-v3 client via raw fetch.
// Chosen for UK/EU residency (aligns with the DPA in docs/phase-5-business-legal/).
//
// Endpoint: https://api.cohere.com/v2/embed
// Docs:     https://docs.cohere.com/reference/embed
//
// Cohere returns 1024-dim float vectors for embed-v3. We use cosine distance
// against the pgvector index — see ops.brain_node_embeddings.

export interface EmbeddingResult {
  embeddings: number[][];
  inputTokens: number;
}

const ENDPOINT = 'https://api.cohere.com/v2/embed';
const MODEL = process.env.COHERE_EMBED_MODEL ?? 'embed-english-v3.0';

/**
 * Embed a batch of texts. Cohere accepts up to 96 inputs per call.
 *
 * inputType:
 *   - "search_document" — when indexing nodes (during brain build)
 *   - "search_query"    — when running a user search at runtime
 */
export async function embedBatch(
  texts: string[],
  inputType: 'search_document' | 'search_query',
  apiKey?: string,
): Promise<EmbeddingResult> {
  const key = apiKey ?? process.env.COHERE_API_KEY;
  if (!key) {
    throw new Error(
      'COHERE_API_KEY not set. Embedding generation requires a Cohere API key.',
    );
  }
  if (texts.length === 0) {
    return { embeddings: [], inputTokens: 0 };
  }
  if (texts.length > 96) {
    throw new Error(`Cohere embed accepts max 96 inputs per call (got ${texts.length}). Chunk before calling.`);
  }

  const response = await fetch(ENDPOINT, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: MODEL,
      input_type: inputType,
      embedding_types: ['float'],
      texts,
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Cohere embed ${response.status}: ${body.slice(0, 500)}`);
  }

  const data = (await response.json()) as {
    embeddings: { float: number[][] };
    meta?: { billed_units?: { input_tokens?: number } };
  };

  return {
    embeddings: data.embeddings.float,
    inputTokens: data.meta?.billed_units?.input_tokens ?? 0,
  };
}

/**
 * Embed many texts in batches of 96.
 */
export async function embedAll(
  texts: string[],
  inputType: 'search_document' | 'search_query',
  apiKey?: string,
): Promise<EmbeddingResult> {
  const out: number[][] = [];
  let totalTokens = 0;
  for (let i = 0; i < texts.length; i += 96) {
    const slice = texts.slice(i, i + 96);
    const r = await embedBatch(slice, inputType, apiKey);
    out.push(...r.embeddings);
    totalTokens += r.inputTokens;
  }
  return { embeddings: out, inputTokens: totalTokens };
}

/**
 * Format the SQL-side vector literal: '[0.1,0.2,...]'.
 * Used when raw-querying via $queryRaw because Prisma doesn't speak vector natively.
 */
export function vectorLiteral(v: number[]): string {
  return '[' + v.map((n) => n.toFixed(6)).join(',') + ']';
}
