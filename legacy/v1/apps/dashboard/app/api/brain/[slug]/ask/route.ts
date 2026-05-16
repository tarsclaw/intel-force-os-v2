import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { db } from '@intelforce/db';
import { requireTenantAccess } from '@/lib/tenant-access';
import {
  type GraphData,
  findStartingNodesSemantic,
  bfsSubgraph,
  renderSubgraph,
} from '@/lib/brain-query';
import { streamAnthropic } from '@/lib/anthropic-stream';

const Body = z.object({
  question: z.string().min(2).max(2000),
  stream: z.boolean().optional().default(false),
});

const SYSTEM_PROMPT = `You are an assistant that answers questions about a customer's company brain — a knowledge graph built from their handbook, decisions, and prior escalations.

Answer using ONLY the provided graph context. Do not use outside knowledge.

When you cite something, refer to the source file (e.g. "according to handbook §3.2") so the user can trace it. If the graph context doesn't contain enough information to answer, say so directly — don't speculate.

Keep answers tight: 2–4 sentences for simple questions, longer only when the user asks for detail.`;

const MODEL = process.env.ANTHROPIC_BRAIN_MODEL ?? 'claude-sonnet-4-6';

// POST /api/brain/[slug]/ask
//
// Body: { question: string, stream?: boolean }
//
// stream=false (default): JSON response with the full answer
// stream=true: text/event-stream with token deltas, then a JSON usage chunk,
//              then a [DONE] sentinel
//
// In both cases:
//   1. Auth + tenant access
//   2. Load tenant graph
//   3. BFS subgraph for grounding
//   4. Call Anthropic with subgraph as system context
//   5. Log invocation + cost to ops.invocations + ops.costs
export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ slug: string }> },
) {
  const { slug } = await params;
  const access = await requireTenantAccess(slug);
  if (!access.ok) return access.response;
  const { tenant, userId } = access;

  let body;
  try {
    body = Body.parse(await req.json());
  } catch {
    return NextResponse.json({ error: 'Invalid request body' }, { status: 400 });
  }

  const { question, stream: wantStream } = body;
  const apiKey = process.env.ANTHROPIC_API_KEY;

  // Load the tenant's graph
  const brain = await db.brainGraph.findUnique({
    where: { tenantId: tenant.id },
    select: { id: true, status: true, graphJson: true },
  });

  // ── Path A: no real brain — return canned answer fast (no Claude call)
  if (!brain || brain.status !== 'READY' || !brain.graphJson) {
    const answer = cannedAnswer(question);
    if (wantStream) {
      return makeSSEResponse(streamFromString(answer));
    }
    return NextResponse.json({
      answer,
      cited: [],
      tokens_used: 0,
      source: 'demo',
    });
  }

  const graph = brain.graphJson as unknown as GraphData;

  // Filter out edges the customer has explicitly rejected. The Surprises
  // tab writes these via /api/brain/[slug]/edges/review.
  const rejected = await db.brainEdgeReview.findMany({
    where: { brainGraphId: brain.id, decision: 'REJECTED' },
    select: { edgeKey: true },
  });
  if (rejected.length > 0) {
    const rejectedSet = new Set(rejected.map((r) => r.edgeKey));
    const filterEdgeKey = (a: string, b: string) => (a < b ? `${a}|${b}` : `${b}|${a}`);
    graph.edges = graph.edges.filter((e) => !rejectedSet.has(filterEdgeKey(e.s, e.t)));
  }

  const starts = await findStartingNodesSemantic(brain.id, graph, question, 3);

  if (starts.length === 0) {
    const answer =
      "I couldn't find a starting point in your brain for that. Try rephrasing — the brain matches on labels, source files, and concepts.";
    if (wantStream) {
      return makeSSEResponse(streamFromString(answer));
    }
    return NextResponse.json({ answer, cited: [], tokens_used: 0, source: 'tenant' });
  }

  const sub = bfsSubgraph(graph, starts, { depth: 2, maxNodes: 80 });
  const grounding = renderSubgraph(sub, 2000);
  const userPrompt = `# Question\n${question}\n\n# Brain context (subgraph rooted at: ${starts.map((s) => s.label).join(', ')})\n${grounding}`;

  const cited = sub.nodes.slice(0, 12).map((n) => n.id);

  // No API key configured — fall back to subgraph summary so dev still works
  if (!apiKey) {
    const answer = composeFallbackAnswer(starts[0].label, sub);
    await logBrainInvocation({
      tenantId: tenant.id,
      userId,
      question,
      durationMs: 50,
      inputTokens: 0,
      outputTokens: 0,
      status: 'SUCCESS',
      note: 'no-api-key',
    });
    if (wantStream) {
      return makeSSEResponse(streamFromString(answer, { cited }));
    }
    return NextResponse.json({
      answer,
      cited,
      tokens_used: 0,
      source: 'tenant',
      starts: starts.map((n) => ({ id: n.id, label: n.label })),
      warning: 'ANTHROPIC_API_KEY not set — returning subgraph summary',
    });
  }

  // ── Path B: real Claude streaming
  const start = Date.now();

  if (wantStream) {
    const encoder = new TextEncoder();
    const sseStream = new ReadableStream({
      async start(controller) {
        let inputTokens = 0;
        let outputTokens = 0;
        let assembled = '';

        // Send cited node IDs upfront so the canvas can highlight in real time
        controller.enqueue(
          encoder.encode(
            `event: cited\ndata: ${JSON.stringify({ cited })}\n\n`,
          ),
        );

        try {
          for await (const chunk of streamAnthropic({
            apiKey,
            model: MODEL,
            system: SYSTEM_PROMPT,
            user: userPrompt,
            maxTokens: 1024,
          })) {
            if (chunk.type === 'text' && chunk.text) {
              assembled += chunk.text;
              controller.enqueue(
                encoder.encode(
                  `event: token\ndata: ${JSON.stringify({ text: chunk.text })}\n\n`,
                ),
              );
            } else if (chunk.type === 'usage') {
              inputTokens = chunk.inputTokens ?? 0;
              outputTokens = chunk.outputTokens ?? 0;
            } else if (chunk.type === 'error') {
              controller.enqueue(
                encoder.encode(
                  `event: error\ndata: ${JSON.stringify({ error: chunk.error })}\n\n`,
                ),
              );
            }
          }

          await logBrainInvocation({
            tenantId: tenant.id,
            userId,
            question,
            durationMs: Date.now() - start,
            inputTokens,
            outputTokens,
            status: 'SUCCESS',
          });

          controller.enqueue(
            encoder.encode(
              `event: done\ndata: ${JSON.stringify({ inputTokens, outputTokens, length: assembled.length })}\n\n`,
            ),
          );
        } catch (err) {
          await logBrainInvocation({
            tenantId: tenant.id,
            userId,
            question,
            durationMs: Date.now() - start,
            inputTokens: 0,
            outputTokens: 0,
            status: 'FAILED',
            note: err instanceof Error ? err.message : String(err),
          });
          controller.enqueue(
            encoder.encode(
              `event: error\ndata: ${JSON.stringify({ error: 'stream-error' })}\n\n`,
            ),
          );
        } finally {
          controller.close();
        }
      },
    });

    return new Response(sseStream, {
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache, no-transform',
        Connection: 'keep-alive',
      },
    });
  }

  // ── Non-streaming: collect full answer then return JSON
  let answer = '';
  let inputTokens = 0;
  let outputTokens = 0;

  try {
    for await (const chunk of streamAnthropic({
      apiKey,
      model: MODEL,
      system: SYSTEM_PROMPT,
      user: userPrompt,
      maxTokens: 1024,
    })) {
      if (chunk.type === 'text' && chunk.text) answer += chunk.text;
      else if (chunk.type === 'usage') {
        inputTokens = chunk.inputTokens ?? 0;
        outputTokens = chunk.outputTokens ?? 0;
      } else if (chunk.type === 'error') {
        await logBrainInvocation({
          tenantId: tenant.id,
          userId,
          question,
          durationMs: Date.now() - start,
          inputTokens: 0,
          outputTokens: 0,
          status: 'FAILED',
          note: chunk.error,
        });
        return NextResponse.json(
          { error: chunk.error ?? 'stream-error' },
          { status: 502 },
        );
      }
    }
  } catch (err) {
    await logBrainInvocation({
      tenantId: tenant.id,
      userId,
      question,
      durationMs: Date.now() - start,
      inputTokens: 0,
      outputTokens: 0,
      status: 'FAILED',
      note: err instanceof Error ? err.message : String(err),
    });
    return NextResponse.json({ error: 'fetch-error' }, { status: 502 });
  }

  await logBrainInvocation({
    tenantId: tenant.id,
    userId,
    question,
    durationMs: Date.now() - start,
    inputTokens,
    outputTokens,
    status: 'SUCCESS',
  });

  return NextResponse.json({
    answer,
    cited,
    tokens_used: inputTokens + outputTokens,
    source: 'tenant',
    starts: starts.map((n) => ({ id: n.id, label: n.label })),
  });
}

// ============================================================================
// Helpers
// ============================================================================

async function logBrainInvocation(args: {
  tenantId: string;
  userId: string;
  question: string;
  durationMs: number;
  inputTokens: number;
  outputTokens: number;
  status: 'SUCCESS' | 'FAILED';
  note?: string;
}) {
  // Compute GBP cost. Sonnet 4.6 pricing as default reference:
  //   $3 / 1M input, $15 / 1M output. USD → GBP at ~0.79.
  const usdInput = (args.inputTokens / 1_000_000) * 3;
  const usdOutput = (args.outputTokens / 1_000_000) * 15;
  const costGbp = (usdInput + usdOutput) * 0.79;

  try {
    const inv = await db.invocation.create({
      data: {
        tenantId: args.tenantId,
        agent: 'brain-ask',
        trigger: args.question.slice(0, 200),
        status: args.status === 'SUCCESS' ? 'SUCCESS' : 'FAILED',
        startedAt: new Date(Date.now() - args.durationMs),
        completedAt: new Date(),
        durationMs: args.durationMs,
        inputTokens: args.inputTokens,
        outputTokens: args.outputTokens,
        costGbp,
        model: MODEL,
        provider: 'anthropic',
        errorMessage: args.note ?? null,
      },
      select: { id: true },
    });

    if (costGbp > 0) {
      await db.cost.create({
        data: {
          tenantId: args.tenantId,
          invocationId: inv.id,
          provider: 'anthropic',
          model: MODEL,
          inputTokens: args.inputTokens,
          outputTokens: args.outputTokens,
          costGbp,
        },
      });
    }
  } catch (err) {
    // Cost logging shouldn't break the user flow
    console.error('[brain-ask] cost logging failed:', err);
  }
}

function makeSSEResponse(stream: ReadableStream): Response {
  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-transform',
      Connection: 'keep-alive',
    },
  });
}

// Build an SSE stream from a static string (for canned/fallback responses)
function streamFromString(text: string, extra?: { cited?: string[] }): ReadableStream {
  const encoder = new TextEncoder();
  return new ReadableStream({
    start(controller) {
      if (extra?.cited) {
        controller.enqueue(
          encoder.encode(
            `event: cited\ndata: ${JSON.stringify({ cited: extra.cited })}\n\n`,
          ),
        );
      }
      // Token-stream the static text in small chunks for UX consistency
      const chunkSize = 6;
      for (let i = 0; i < text.length; i += chunkSize) {
        controller.enqueue(
          encoder.encode(
            `event: token\ndata: ${JSON.stringify({ text: text.slice(i, i + chunkSize) })}\n\n`,
          ),
        );
      }
      controller.enqueue(
        encoder.encode(
          `event: done\ndata: ${JSON.stringify({ inputTokens: 0, outputTokens: 0, length: text.length })}\n\n`,
        ),
      );
      controller.close();
    },
  });
}

function cannedAnswer(question: string): string {
  const canned: Record<string, string> = {
    'how does hr agent connect to breathe hr':
      "The HR Agent calls Breathe HR via the breatheFetch helper. Path: HR Agent → handleMessage → callClaudeAgent → get_employee_info tool → breatheFetch → Breathe HR REST API. Findings are cached in KV for 4 hours.",
    'why was cloudflare workers chosen':
      "Three reasons: free-tier headroom for the entire first cohort, edge runtime keeps Teams webhook latency under 100ms, and a single wrangler deploy replaces an entire Azure App Service.",
  };
  const key = question.toLowerCase().replace(/[^a-z\s]/g, '').trim();
  for (const [k, v] of Object.entries(canned)) {
    if (key.includes(k.split(' ').slice(0, 3).join(' '))) return v;
  }
  return "(Demo mode — your tenant brain hasn't been built yet. Once the wizard finishes, this answer will be grounded in your handbook + decisions.)";
}

function composeFallbackAnswer(
  startLabel: string,
  sub: { nodes: import('@/lib/brain-query').GraphNode[]; edges: import('@/lib/brain-query').GraphEdge[]; starts: import('@/lib/brain-query').GraphNode[] },
): string {
  const sources = Array.from(
    new Set(sub.nodes.map((n) => n.source_file).filter(Boolean) as string[]),
  ).slice(0, 4);
  return `Starting from "${startLabel}" — found ${sub.nodes.length} connected concepts across ${sources.length} sources.\n\nSources: ${sources.join(', ')}.\n\n(ANTHROPIC_API_KEY isn't set, so this is the BFS subgraph summary instead of a Claude completion.)`;
}
