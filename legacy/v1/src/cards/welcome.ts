export interface WelcomeCardData {
  hrLeadFirstName: string;
}

export function buildWelcomeCard(data: WelcomeCardData): object {
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
            text: `👋 **Hi ${data.hrLeadFirstName} — I'm Intel Force OS.**`,
            size: 'Large',
            weight: 'Bolder',
            wrap: true,
          },
        ],
      },
      {
        type: 'TextBlock',
        text: "I'll watch the HR channel you point me at, draft every reply, and flag anything sensitive. **Nothing goes out without you approving it.**",
        wrap: true,
        spacing: 'Medium',
      },
      {
        type: 'TextBlock',
        text: "**Here's how I'll show up in your day**",
        weight: 'Bolder',
        spacing: 'Medium',
      },
      {
        type: 'TextBlock',
        text: "• When someone asks an HR question, you'll get a card here with my draft and **Approve / Edit / Reject** buttons.\n\n• Sensitive stuff (grievances, mental health, resignation) gets flagged **in red** so you can't miss it.\n\n• Every Monday at 9am you'll get a summary of last week.",
        wrap: true,
      },
      {
        type: 'TextBlock',
        text: '**Commands I respond to**',
        weight: 'Bolder',
        spacing: 'Medium',
      },
      {
        type: 'TextBlock',
        text: "• `/status` — what's pending your approval right now\n• `/report` — pull last week's summary on demand\n• `/help` — full command list",
        wrap: true,
      },
    ],
    actions: [
      {
        type: 'Action.OpenUrl',
        title: 'Read the quickstart',
        url: 'https://intelforce.ai/docs/quickstart',
      },
    ],
  };
}
