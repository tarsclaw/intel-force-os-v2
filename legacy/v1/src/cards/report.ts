export interface WeeklyReportData {
  customerName: string;
  weekStartDate: string;
  weekEndDate: string;
  messagesHandled: number;
  approvedAsIs: number;
  approvedAsIsPercent: number;
  edited: number;
  editedPercent: number;
  rejected: number;
  escalated: number;
  avgConfidence: string;
  topPatterns: Array<{ pattern: string; percent: number }>;
  thisWeekPriority: string;
}

export function buildWeeklyReportCard(data: WeeklyReportData): object {
  return {
    type: 'AdaptiveCard',
    $schema: 'http://adaptivecards.io/schemas/adaptive-card.json',
    version: '1.5',
    body: [
      {
        type: 'Container',
        style: 'accent',
        bleed: true,
        items: [
          {
            type: 'TextBlock',
            text: '📊 **Your Intel Force OS week**',
            size: 'Large',
            weight: 'Bolder',
          },
          {
            type: 'TextBlock',
            text: `${data.weekStartDate} – ${data.weekEndDate} · ${data.customerName}`,
            isSubtle: true,
            spacing: 'None',
          },
        ],
      },
      {
        type: 'ColumnSet',
        spacing: 'Medium',
        columns: [
          statColumn(String(data.messagesHandled), 'messages handled'),
          statColumn(`${data.approvedAsIsPercent}%`, 'approved as-is', 'Good'),
          statColumn(data.avgConfidence, 'avg quality /5'),
        ],
      },
      { type: 'TextBlock', text: '**Breakdown**', weight: 'Bolder', spacing: 'Large' },
      {
        type: 'FactSet',
        facts: [
          { title: 'Approved as-is', value: `${data.approvedAsIs} (${data.approvedAsIsPercent}%)` },
          { title: 'Edited before send', value: `${data.edited} (${data.editedPercent}%)` },
          { title: 'Rejected', value: String(data.rejected) },
          { title: 'Escalated to you', value: String(data.escalated) },
        ],
      },
      ...(data.topPatterns.length > 0
        ? [
            {
              type: 'TextBlock',
              text: '**What people asked about**',
              weight: 'Bolder',
              spacing: 'Large',
            },
            ...data.topPatterns.map((p) => ({
              type: 'TextBlock',
              text: `• ${p.pattern} — ${p.percent}%`,
              wrap: true,
              spacing: 'None',
            })),
          ]
        : []),
      {
        type: 'Container',
        style: 'warning',
        spacing: 'Large',
        items: [
          { type: 'TextBlock', text: "**This week's priority**", weight: 'Bolder' },
          { type: 'TextBlock', text: data.thisWeekPriority, wrap: true },
        ],
      },
    ],
  };
}

function statColumn(value: string, label: string, color?: string) {
  return {
    type: 'Column',
    width: 'stretch',
    items: [
      {
        type: 'TextBlock',
        text: value,
        size: 'ExtraLarge',
        weight: 'Bolder',
        horizontalAlignment: 'Center',
        ...(color ? { color } : {}),
      },
      {
        type: 'TextBlock',
        text: label,
        isSubtle: true,
        size: 'Small',
        horizontalAlignment: 'Center',
        spacing: 'None',
      },
    ],
  };
}
