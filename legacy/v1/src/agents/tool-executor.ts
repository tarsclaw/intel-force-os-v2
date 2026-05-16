import type Anthropic from '@anthropic-ai/sdk';
import { getEmployeeSummary, formatEmployeeSummary } from './breathe-hr';

export async function executeTools(
  content: Anthropic.ContentBlock[],
  handbookText: string,
  breatheHrApiKey?: string,
): Promise<Anthropic.ToolResultBlockParam[]> {
  const toolCalls = content.filter(
    (b): b is Anthropic.ToolUseBlock => b.type === 'tool_use',
  );

  return Promise.all(
    toolCalls.map(async (block) => {
      const result = await runTool(block.name, block.input as Record<string, unknown>, handbookText, breatheHrApiKey);
      return {
        type: 'tool_result' as const,
        tool_use_id: block.id,
        content: result,
      };
    }),
  );
}

async function runTool(
  name: string,
  input: Record<string, unknown>,
  handbookText: string,
  breatheHrApiKey?: string,
): Promise<string> {
  switch (name) {
    case 'lookup_handbook_policy': {
      const query = String(input['query'] ?? '');
      return searchHandbook(handbookText, query);
    }

    case 'get_employee_info': {
      const employeeName = String(input['employee_name'] ?? '');

      if (!breatheHrApiKey) {
        return `Breathe HR integration not configured for this tenant. Proceeding from handbook only. Note: could not verify ${employeeName}'s specific leave balance or department.`;
      }

      try {
        const summary = await getEmployeeSummary(breatheHrApiKey, employeeName);
        if (!summary) {
          return `Employee "${employeeName}" not found in Breathe HR. They may be using a different name or have not yet been added to the system.`;
        }
        return formatEmployeeSummary(summary);
      } catch (err) {
        const msg = err instanceof Error ? err.message : 'unknown error';
        console.warn('breathe_hr_lookup_failed', { employeeName, error: msg });
        return `Breathe HR lookup temporarily unavailable (${msg}). Proceeding from handbook only.`;
      }
    }

    case 'submit_draft_for_approval':
      // This tool is handled upstream — should not reach executeTools
      return 'Draft submitted.';

    default:
      return `Unknown tool: ${name}. Proceed without this information.`;
  }
}

function searchHandbook(handbookText: string, query: string): string {
  if (!handbookText.trim()) {
    return 'No handbook has been uploaded for this tenant. Set confidence below 0.5 and recommend escalation.';
  }

  const queryWords = query
    .toLowerCase()
    .split(/\s+/)
    .filter((w) => w.length > 2);

  const paragraphs = handbookText
    .split(/\n{2,}/)
    .map((p) => p.trim())
    .filter((p) => p.length > 30);

  const scored = paragraphs
    .map((text) => {
      const lower = text.toLowerCase();
      const score = queryWords.reduce(
        (acc, word) => acc + (lower.includes(word) ? 1 : 0),
        0,
      );
      return { text, score };
    })
    .filter((p) => p.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, 4);

  if (scored.length === 0) {
    return `No relevant content found in the handbook for: "${query}". Set confidence below 0.5 for any answer about this topic.`;
  }

  const results = scored.map((p) => p.text).join('\n\n---\n\n');
  return `Relevant handbook content for "${query}":\n\n${results}`;
}
