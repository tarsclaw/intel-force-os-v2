export interface ErrorCardData {
  errorTitle: string;
  errorExplanation: string;
  whatNext: string;
  referenceId: string;
}

export function buildErrorCard(data: ErrorCardData): object {
  return {
    type: 'AdaptiveCard',
    $schema: 'http://adaptivecards.io/schemas/adaptive-card.json',
    version: '1.5',
    body: [
      {
        type: 'Container',
        style: 'warning',
        bleed: true,
        items: [
          {
            type: 'ColumnSet',
            columns: [
              {
                type: 'Column',
                width: 'auto',
                items: [{ type: 'TextBlock', text: '⚠', size: 'Large' }],
              },
              {
                type: 'Column',
                width: 'stretch',
                items: [
                  { type: 'TextBlock', text: data.errorTitle, weight: 'Bolder', wrap: true },
                ],
              },
            ],
          },
        ],
      },
      { type: 'TextBlock', text: data.errorExplanation, wrap: true, spacing: 'Medium' },
      { type: 'TextBlock', text: '**What happens next**', weight: 'Bolder', spacing: 'Medium' },
      { type: 'TextBlock', text: data.whatNext, wrap: true },
      {
        type: 'TextBlock',
        text: `Reference: ${data.referenceId}`,
        isSubtle: true,
        size: 'Small',
        spacing: 'Medium',
      },
    ],
    actions: [
      {
        type: 'Action.OpenUrl',
        title: 'Contact support',
        url: `https://intelforce.ai/support?ref=${encodeURIComponent(data.referenceId)}`,
      },
    ],
  };
}
