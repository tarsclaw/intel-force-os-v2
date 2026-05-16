import { auth } from '@clerk/nextjs/server';
import { db } from '@intelforce/db';

// SSE endpoint — streams new escalations to the Operations Control view
// Client connects via EventSource('/api/escalations/stream?tenantId=...')
// In production: use Redis pub/sub or Postgres NOTIFY for real events
// For v1: polls every 10s and sends deltas

export const dynamic = 'force-dynamic';

export async function GET(request: Request) {
  const { userId } = await auth();
  if (!userId) return new Response('Unauthorized', { status: 401 });

  const url = new URL(request.url);
  const tenantId = url.searchParams.get('tenantId');
  if (!tenantId) return new Response('Missing tenantId', { status: 400 });

  const encoder = new TextEncoder();
  let lastChecked = new Date();

  const stream = new ReadableStream({
    async start(controller) {
      // Send initial ping
      controller.enqueue(encoder.encode('event: connected\ndata: {}\n\n'));

      const poll = async () => {
        try {
          const newEscalations = await db.escalation.findMany({
            where: {
              tenantId,
              status: { in: ['OPEN', 'ACKNOWLEDGED'] },
              createdAt: { gt: lastChecked },
            },
            orderBy: { createdAt: 'desc' },
            take: 10,
          });

          if (newEscalations.length > 0) {
            lastChecked = new Date();
            const payload = JSON.stringify(newEscalations);
            controller.enqueue(encoder.encode(`event: escalations\ndata: ${payload}\n\n`));
          }
        } catch (err) {
          controller.enqueue(
            encoder.encode(`event: error\ndata: ${JSON.stringify({ message: 'Stream error' })}\n\n`),
          );
        }
      };

      // Poll every 10 seconds
      const interval = setInterval(poll, 10_000);

      // Heartbeat every 30s to keep connection alive
      const heartbeat = setInterval(() => {
        controller.enqueue(encoder.encode(': heartbeat\n\n'));
      }, 30_000);

      // Cleanup on close
      request.signal.addEventListener('abort', () => {
        clearInterval(interval);
        clearInterval(heartbeat);
        controller.close();
      });
    },
  });

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      Connection: 'keep-alive',
      'X-Accel-Buffering': 'no',
    },
  });
}
