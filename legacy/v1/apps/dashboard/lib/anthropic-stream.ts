// Minimal Anthropic Messages API client using raw fetch — no SDK dep.
// We only need streaming completions for "Ask the brain", and the SSE format
// is well-defined. See: https://docs.anthropic.com/en/api/messages-streaming

export interface StreamChunk {
  type: 'text' | 'usage' | 'done' | 'error';
  text?: string;
  inputTokens?: number;
  outputTokens?: number;
  error?: string;
}

export interface StreamOptions {
  apiKey: string;
  model: string;
  system: string;
  user: string;
  maxTokens?: number;
  signal?: AbortSignal;
}

/**
 * Stream a Claude completion. Yields chunks: text deltas, then a usage chunk,
 * then a done sentinel. Errors are yielded as `{ type: 'error' }` and the
 * generator terminates.
 */
export async function* streamAnthropic(
  opts: StreamOptions,
): AsyncGenerator<StreamChunk> {
  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': opts.apiKey,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      model: opts.model,
      max_tokens: opts.maxTokens ?? 1024,
      stream: true,
      system: opts.system,
      messages: [{ role: 'user', content: opts.user }],
    }),
    signal: opts.signal,
  });

  if (!response.ok) {
    const body = await response.text();
    yield {
      type: 'error',
      error: `Anthropic API ${response.status}: ${body.slice(0, 500)}`,
    };
    return;
  }

  if (!response.body) {
    yield { type: 'error', error: 'No response body from Anthropic' };
    return;
  }

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';
  let inputTokens = 0;
  let outputTokens = 0;

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    buffer += decoder.decode(value, { stream: true });

    // SSE events are separated by double-newlines. Within an event:
    //   event: <type>
    //   data: <json>
    let idx;
    while ((idx = buffer.indexOf('\n\n')) !== -1) {
      const rawEvent = buffer.slice(0, idx);
      buffer = buffer.slice(idx + 2);

      const dataLine = rawEvent
        .split('\n')
        .find((l) => l.startsWith('data: '));
      if (!dataLine) continue;

      const json = dataLine.slice(6).trim();
      if (!json || json === '[DONE]') continue;

      let parsed: Record<string, unknown>;
      try {
        parsed = JSON.parse(json);
      } catch {
        continue;
      }

      const eventType = parsed.type as string;

      if (eventType === 'content_block_delta') {
        const delta = parsed.delta as { type?: string; text?: string };
        if (delta?.type === 'text_delta' && delta.text) {
          yield { type: 'text', text: delta.text };
        }
      } else if (eventType === 'message_start') {
        const usage = (parsed.message as { usage?: { input_tokens?: number } } | undefined)?.usage;
        if (usage?.input_tokens) inputTokens = usage.input_tokens;
      } else if (eventType === 'message_delta') {
        const usage = (parsed as { usage?: { output_tokens?: number } }).usage;
        if (usage?.output_tokens) outputTokens = usage.output_tokens;
      } else if (eventType === 'message_stop') {
        yield { type: 'usage', inputTokens, outputTokens };
        yield { type: 'done' };
      }
    }
  }
}
