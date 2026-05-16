export interface EscalationCardData {
  employeeName: string;
  channelName: string;
  originalMessage: string;
  category: string;
  categoryEmoji: string;
  holdingReplySent: boolean;
  holdingReplyText: string;
  auditId: string;
  conversationId: string;
  submittedAt: string;
}

export function buildEscalationCard(data: EscalationCardData): object {
  return {
    type: 'AdaptiveCard',
    $schema: 'http://adaptivecards.io/schemas/adaptive-card.json',
    version: '1.5',
    body: [
      {
        type: 'Container',
        style: 'attention',
        bleed: true,
        items: [
          {
            type: 'ColumnSet',
            columns: [
              {
                type: 'Column',
                width: 'auto',
                items: [{ type: 'TextBlock', text: '🔔', size: 'ExtraLarge' }],
              },
              {
                type: 'Column',
                width: 'stretch',
                items: [
                  {
                    type: 'TextBlock',
                    text: '**Requires your attention**',
                    size: 'Large',
                    weight: 'Bolder',
                    color: 'Attention',
                  },
                  {
                    type: 'TextBlock',
                    text: 'Intel Force OS has flagged this for human handling.',
                    wrap: true,
                    isSubtle: true,
                    spacing: 'None',
                  },
                ],
              },
            ],
          },
        ],
      },
      {
        type: 'FactSet',
        spacing: 'Medium',
        facts: [
          { title: 'From', value: data.employeeName },
          { title: 'Channel', value: data.channelName },
          { title: 'Time', value: data.submittedAt },
          { title: 'Category', value: `${data.categoryEmoji} ${data.category}` },
        ],
      },
      {
        type: 'TextBlock',
        text: '**Original message**',
        weight: 'Bolder',
        spacing: 'Medium',
      },
      {
        type: 'Container',
        style: 'emphasis',
        items: [{ type: 'TextBlock', text: data.originalMessage, wrap: true }],
      },
      ...(data.holdingReplySent
        ? [
            {
              type: 'Container',
              spacing: 'Medium',
              items: [
                { type: 'TextBlock', text: '**What Intel Force OS already did**', weight: 'Bolder' },
                {
                  type: 'TextBlock',
                  text: `Sent a gentle holding reply to ${data.employeeName} so they're not left waiting:`,
                  wrap: true,
                  isSubtle: true,
                  size: 'Small',
                },
                {
                  type: 'Container',
                  style: 'default',
                  items: [
                    {
                      type: 'TextBlock',
                      text: `_"${data.holdingReplyText}"_`,
                      wrap: true,
                      size: 'Small',
                    },
                  ],
                },
              ],
            },
          ]
        : []),
    ],
    actions: [
      {
        type: 'Action.Submit',
        title: "I'll handle this",
        style: 'positive',
        data: { action: 'acknowledge', auditId: data.auditId, conversationId: data.conversationId },
      },
      {
        type: 'Action.Submit',
        title: 'Request backup',
        data: { action: 'request_backup', auditId: data.auditId, conversationId: data.conversationId },
      },
    ],
  };
}
