export interface ApprovalCardData {
  employeeName: string;
  channelName: string;
  originalMessage: string;
  draftReply: string;
  sensitivityLabel: string;
  sensitivityColor: string;
  confidencePercent: string;
  citations: Array<{ snippet: string; source: string }>;
  auditId: string;
  conversationId: string;
  submittedAt: string;
}

export function buildApprovalCard(data: ApprovalCardData): object {
  return {
    type: 'AdaptiveCard',
    $schema: 'http://adaptivecards.io/schemas/adaptive-card.json',
    version: '1.5',
    body: [
      {
        type: 'Container',
        style: 'emphasis',
        items: [
          {
            type: 'ColumnSet',
            columns: [
              {
                type: 'Column',
                width: 'auto',
                items: [{ type: 'TextBlock', text: '👋', size: 'Large' }],
              },
              {
                type: 'Column',
                width: 'stretch',
                items: [
                  {
                    type: 'TextBlock',
                    text: `**New query from ${data.employeeName}** in ${data.channelName}`,
                    wrap: true,
                    spacing: 'None',
                  },
                  {
                    type: 'TextBlock',
                    text: `${data.submittedAt} · awaiting your approval`,
                    isSubtle: true,
                    size: 'Small',
                    spacing: 'None',
                  },
                ],
              },
            ],
          },
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
        style: 'default',
        items: [{ type: 'TextBlock', text: data.originalMessage, wrap: true }],
      },
      {
        type: 'TextBlock',
        text: '**Intel Force OS draft**',
        weight: 'Bolder',
        spacing: 'Medium',
      },
      {
        type: 'Container',
        style: 'accent',
        items: [{ type: 'TextBlock', text: data.draftReply, wrap: true }],
      },
      {
        type: 'ColumnSet',
        spacing: 'Medium',
        columns: [
          {
            type: 'Column',
            width: 'auto',
            items: [
              { type: 'TextBlock', text: 'Sensitivity:', isSubtle: true, size: 'Small' },
            ],
          },
          {
            type: 'Column',
            width: 'auto',
            items: [
              {
                type: 'TextBlock',
                text: `● ${data.sensitivityLabel}`,
                color: data.sensitivityColor,
                size: 'Small',
                weight: 'Bolder',
              },
            ],
          },
          {
            type: 'Column',
            width: 'stretch',
            items: [
              {
                type: 'TextBlock',
                text: `Confidence ${data.confidencePercent}%`,
                isSubtle: true,
                size: 'Small',
                horizontalAlignment: 'Right',
              },
            ],
          },
        ],
      },
      ...(data.citations.length > 0
        ? [
            {
              type: 'Container',
              spacing: 'Small',
              items: [
                {
                  type: 'TextBlock',
                  text: '**Sources**',
                  size: 'Small',
                  weight: 'Bolder',
                  spacing: 'Small',
                },
                ...data.citations.map((c) => ({
                  type: 'TextBlock',
                  text: `• ${c.snippet} — ${c.source}`,
                  size: 'Small',
                  isSubtle: true,
                  wrap: true,
                  spacing: 'None',
                })),
              ],
            },
          ]
        : []),
    ],
    actions: [
      {
        type: 'Action.Submit',
        title: '✓ Approve',
        style: 'positive',
        data: { action: 'approve', auditId: data.auditId, conversationId: data.conversationId },
      },
      {
        type: 'Action.ShowCard',
        title: '✎ Edit',
        card: {
          type: 'AdaptiveCard',
          body: [
            {
              type: 'Input.Text',
              id: 'editedReply',
              placeholder: 'Edit the draft before sending...',
              value: data.draftReply,
              isMultiline: true,
            },
          ],
          actions: [
            {
              type: 'Action.Submit',
              title: 'Send edited version',
              style: 'positive',
              data: { action: 'edit', auditId: data.auditId, conversationId: data.conversationId },
            },
          ],
        },
      },
      {
        type: 'Action.Submit',
        title: '✗ Reject',
        style: 'destructive',
        data: { action: 'reject', auditId: data.auditId, conversationId: data.conversationId },
      },
    ],
  };
}
