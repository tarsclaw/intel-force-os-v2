import type Anthropic from '@anthropic-ai/sdk';

export const HR_AGENT_TOOLS: Anthropic.Tool[] = [
  {
    name: 'submit_draft_for_approval',
    description:
      'Submit the drafted HR reply and classification. You MUST call this exactly once at the end of every response. This is how your output is delivered to the HR Lead for review.',
    input_schema: {
      type: 'object' as const,
      required: [
        'draft_reply',
        'sensitivity_score',
        'escalation_recommended',
        'confidence',
      ],
      properties: {
        draft_reply: {
          type: 'string',
          description:
            'The complete reply to send to the employee after HR Lead approval. If escalating (sensitivity >= 0.7), this must be a gentle holding message only — never an attempt to resolve the underlying issue.',
        },
        sensitivity_score: {
          type: 'number',
          description:
            '0.0 = entirely routine (policy question, leave request). 1.0 = highly sensitive (grievance, resignation, mental health crisis). Use 0.7 as the escalation threshold.',
        },
        sensitivity_category: {
          type: 'string',
          enum: [
            'grievance',
            'resignation',
            'mental_health',
            'harassment',
            'health',
            'low_confidence',
            'other',
          ],
          description:
            'Required when sensitivity_score >= 0.7. The category that best describes the sensitive nature of this query.',
        },
        escalation_recommended: {
          type: 'boolean',
          description:
            'Set true if sensitivity_score >= 0.7 OR confidence < 0.5. When true, the HR Lead will receive an escalation card, not an approval card.',
        },
        confidence: {
          type: 'number',
          description:
            '0.0-1.0. How confident you are in the draft. If the handbook does not clearly cover this topic, set < 0.5, which will trigger escalation.',
        },
        handbook_citations: {
          type: 'array',
          description: 'Handbook passages that ground this reply.',
          items: {
            type: 'object',
            properties: {
              snippet: { type: 'string' },
              page: { type: 'number' },
              source: { type: 'string' },
            },
          },
        },
        reasoning: {
          type: 'string',
          description:
            'Internal reasoning note — not shown to the employee. Used for audit and debugging.',
        },
      },
    },
  },

  {
    name: 'lookup_handbook_policy',
    description:
      'Search the company HR handbook for relevant policies, procedures, or guidance. Call this before drafting any policy-related answer. If no relevant content is found, lower your confidence score.',
    input_schema: {
      type: 'object' as const,
      required: ['query'],
      properties: {
        query: {
          type: 'string',
          description:
            'The topic or policy to search for. Be specific — e.g. "holiday carry-over policy" rather than "holiday".',
        },
      },
    },
  },

  {
    name: 'get_employee_info',
    description:
      'Retrieve basic employee information from Breathe HR: leave balance, department, start date, line manager. Call when the query requires knowledge of the specific employee\'s record.',
    input_schema: {
      type: 'object' as const,
      required: ['employee_name'],
      properties: {
        employee_name: {
          type: 'string',
          description: 'The employee\'s full name as provided in context.',
        },
      },
    },
  },
];
