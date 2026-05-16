import { readFile } from 'node:fs/promises';
import type { SourceFile } from './source-collector';

export interface GraphifyResult {
  graph: unknown;
  nodeCount: number;
  edgeCount: number;
  communityCount: number;
  inputTokens: number;
  outputTokens: number;
  costGbp: number;
}

/**
 * Run graphify against a set of source files via the HTTP graphify-service.
 *
 * The service runs as a separate Docker container (services/graphify-service).
 * In dev, set GRAPHIFY_USE_STUB=true to skip the network call and return an
 * empty graph for end-to-end UI testing.
 *
 * Required env:
 *   GRAPHIFY_SERVICE_URL — base URL (e.g. http://graphify:8080 in compose,
 *                          https://graphify.intelforce.ai in prod)
 *
 * Optional env:
 *   GRAPHIFY_SERVICE_TOKEN — bearer token if the service is auth-gated
 *   GRAPHIFY_TIMEOUT_MS    — override the 10-minute default timeout
 */
export async function runGraphify(
  sources: SourceFile[],
  opts: { tenantSlug: string; mode?: 'default' | 'deep' } = { tenantSlug: 'unknown' },
): Promise<GraphifyResult> {
  if (process.env.GRAPHIFY_USE_STUB === 'true') {
    return {
      graph: { nodes: [], edges: [], communities: {} },
      nodeCount: 0,
      edgeCount: 0,
      communityCount: 0,
      inputTokens: 0,
      outputTokens: 0,
      costGbp: 0,
    };
  }

  const baseUrl = process.env.GRAPHIFY_SERVICE_URL;
  if (!baseUrl) {
    throw new Error(
      'GRAPHIFY_SERVICE_URL not set. Set it to the graphify-service URL or set GRAPHIFY_USE_STUB=true for dev.',
    );
  }

  const token = process.env.GRAPHIFY_SERVICE_TOKEN;
  const timeoutMs = Number(process.env.GRAPHIFY_TIMEOUT_MS ?? 600_000);

  const form = new FormData();
  form.append('tenant_slug', opts.tenantSlug);
  form.append('mode', opts.mode ?? 'default');

  for (const f of sources) {
    const buf = await readFile(f.fullPath);
    // Node 18+ has a global FormData / Blob via undici
    form.append('files', new Blob([buf]), f.name);
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  let response: Response;
  try {
    response = await fetch(`${baseUrl}/build`, {
      method: 'POST',
      body: form,
      headers: token ? { Authorization: `Bearer ${token}` } : {},
      signal: controller.signal,
    });
  } finally {
    clearTimeout(timer);
  }

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(
      `graphify-service returned ${response.status}: ${errorBody.slice(0, 500)}`,
    );
  }

  const data = (await response.json()) as {
    graph: unknown;
    node_count: number;
    edge_count: number;
    community_count: number;
    input_tokens: number;
    output_tokens: number;
    duration_ms: number;
  };

  // Cost estimate. graphify drives Claude 4.x extraction. Use Anthropic
  // pricing (Sonnet rates as a reasonable default; $3 / 1M input,
  // $15 / 1M output). Convert USD → GBP at ~0.79.
  const usdInput = (data.input_tokens / 1_000_000) * 3;
  const usdOutput = (data.output_tokens / 1_000_000) * 15;
  const costGbp = (usdInput + usdOutput) * 0.79;

  return {
    graph: data.graph,
    nodeCount: data.node_count,
    edgeCount: data.edge_count,
    communityCount: data.community_count,
    inputTokens: data.input_tokens,
    outputTokens: data.output_tokens,
    costGbp,
  };
}
