import type { AuditEntry } from '../storage/audit';

export interface StatusCardData {
  count: number;
  items: AuditEntry[];
}

export function buildStatusCard(data: StatusCardData): object {
  if (data.count === 0) {
    return {
      type: 'AdaptiveCard',
      $schema: 'http://adaptivecards.io/schemas/adaptive-card.json',
      version: '1.5',
      body: [
        {
          type: 'Container',
          style: 'good',
          bleed: true,
          items: [
            {
              type: 'TextBlock',
              text: '✅ **Nothing pending**',
              size: 'Large',
              weight: 'Bolder',
            },
          ],
        },
        {
          type: 'TextBlock',
          text: "You're all caught up. New queries will appear here as they come in.",
          wrap: true,
          spacing: 'Medium',
        },
      ],
    };
  }

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
            type: 'TextBlock',
            text: `⏳ **${data.count} pending ${data.count === 1 ? 'approval' : 'approvals'}**`,
            size: 'Large',
            weight: 'Bolder',
          },
        ],
      },
      ...data.items.slice(0, 5).map((item) => ({
        type: 'Container',
        spacing: 'Medium',
        style: 'emphasis',
        items: [
          {
            type: 'TextBlock',
            text: item.originalQuery.slice(0, 120) + (item.originalQuery.length > 120 ? '...' : ''),
            wrap: true,
            size: 'Small',
          },
          {
            type: 'TextBlock',
            text: `Audit #${item.id} · ${item.createdAt.slice(0, 16)}`,
            isSubtle: true,
            size: 'Small',
            spacing: 'None',
          },
        ],
      })),
      ...(data.count > 5
        ? [
            {
              type: 'TextBlock',
              text: `... and ${data.count - 5} more`,
              isSubtle: true,
              spacing: 'Small',
            },
          ]
        : []),
    ],
  };
}
