---
name: adaptive-cards
description: Design, build, test, and debug Microsoft Adaptive Cards for Intel Force OS Teams bot. Use this skill when creating any card (approval, escalation, report, config, welcome, error), modifying card JSON templates, wiring up button actions, implementing the adaptivecards-templating library, debugging why a card renders wrong, or testing cards across Teams desktop / web / mobile. Also triggers on: adaptive card, card template, Action.Submit, ShowCard, Action.OpenUrl, Input.Text, Input.ChoiceSet, card schema, card designer.
---

# Adaptive Cards — Domain Skill

Adaptive Cards are the primary UI primitive in Intel Force OS. Every meaningful user interaction — approval, escalation, reports, config — is a card. This skill covers design, implementation, and testing.

## Where the spec lives

- Card templates (all 6): `docs/teams-hr-agent/06-adaptive-card-examples.json`
- Component design: `docs/teams-hr-agent/02-component-design.md` §3
- Worker integration: `src/cards/*.ts`

## The six cards in Intel Force OS v1

| Card | File | Used when |
|---|---|---|
| `approval_card` | `src/cards/approval.ts` | Non-sensitive query requires HR Lead approval |
| `escalation_card` | `src/cards/escalation.ts` | Sensitive query requires human attention |
| `weekly_report_card` | `src/cards/report.ts` | Monday 09:00 BST automated report |
| `config_card` | `src/cards/config.ts` | HR Lead types `/config` |
| `welcome_card` | `src/cards/welcome.ts` | Bot added to HR Lead's 1:1 chat |
| `error_card` | `src/cards/error.ts` | System failure requiring user-facing message |

## The Adaptive Card schema

- **Version used:** 1.5 (supported in Teams desktop, web, iOS, Android)
- **Full schema:** https://adaptivecards.io/explorer/
- **Designer tool:** https://adaptivecards.io/designer/ (paste JSON, preview rendering)

Key element types:
- `TextBlock` — text with weight, size, color, spacing, wrap
- `Container` — groups with styles: default, emphasis, accent, good, warning, attention
- `ColumnSet` / `Column` — layout
- `FactSet` — label/value pairs
- `Image` — images (URL must be on manifest `validDomains`)
- `Input.Text` / `Input.ChoiceSet` / `Input.Toggle` — form inputs
- `ActionSet` — buttons

Action types:
- `Action.Submit` — posts data back to the bot (most common)
- `Action.ShowCard` — expand inline (used for Edit approval flow)
- `Action.OpenUrl` — external link

## The templating library

Adaptive Cards use `${variable}` syntax via `adaptivecards-templating`:

```typescript
import * as ACData from 'adaptivecards-templating';

const template = new ACData.Template(approvalCardJson);
const card = template.expand({
  $root: {
    employeeName: 'Sarah Chen',
    draftReply: '...',
    auditId: '12345',
    // ... all fields from _template_data_shape
  }
});
```

### Data shape must match exactly

Each card's `_template_data_shape` in `06-adaptive-card-examples.json` is the required input. Missing fields render as literal `${fieldName}` text — looks like a bug.

**Always define a TypeScript interface matching the shape:**

```typescript
interface ApprovalCardData {
  employeeName: string;
  channelName: string;
  originalMessage: string;
  draftReply: string;
  sensitivityLabel: 'Low' | 'Medium' | 'High';
  sensitivityColor: 'good' | 'warning' | 'attention';
  confidencePercent: string;
  citations: Array<{snippet: string; source: string}>;
  auditId: string;
  conversationId: string;
  submittedAt: string;
}
```

This catches missing fields at typecheck time, not at runtime.

## The approval card deep-dive

Most-used card. Structure:

1. **Header container** (`style: emphasis`) — "From Sarah in #hr"
2. **Original message** section — quoted employee text
3. **Draft reply** section (`style: accent`) — AI-drafted response
4. **Metadata row** — sensitivity indicator + confidence %
5. **Citations** — handbook sources (conditional on `count(citations) > 0`)
6. **Action buttons** — `[✓ Approve] [✎ Edit] [✗ Reject]`

### The Edit action pattern

Edit uses `Action.ShowCard` to expand an inline form:

```json
{
  "type": "Action.ShowCard",
  "title": "✎ Edit",
  "card": {
    "type": "AdaptiveCard",
    "body": [
      {
        "type": "Input.Text",
        "id": "editedReply",
        "value": "${draftReply}",
        "isMultiline": true
      }
    ],
    "actions": [
      {
        "type": "Action.Submit",
        "title": "Send edited version",
        "data": {
          "action": "edit",
          "auditId": "${auditId}"
        }
      }
    ]
  }
}
```

When user clicks "Send edited version," Teams POSTs to the bot with:
```json
{
  "action": "edit",
  "auditId": "12345",
  "editedReply": "the text they typed"
}
```

## The escalation card

Distinct visual treatment from approval:
- `style: attention` container (red accent)
- 🔔 emoji, not 👋
- No AI-drafted response (only a "here's what I already did" note about the holding reply)
- Action buttons: `[I'll handle this] [Request backup]` not `[Approve] [Edit] [Reject]`

Critical: the escalation card is sent AFTER the holding reply has already gone to the employee. Don't let the HR Lead think they're still "first" to respond. The note in the card ("I sent this holding reply to Sarah...") explicitly tells them.

## The weekly report card

Sent every Monday 09:00 BST via Worker cron (`wrangler.toml` crons: `"0 8 * * 1"`).

Structure:
- Week date range header
- 3-column metrics grid (messages, approval rate, quality score)
- Breakdown fact set (approved / edited / rejected / escalated)
- Top patterns list
- "This week's priority" container (warning style)

The "priority" field is rule-based text (not AI-generated):
- If `edited > approved`: "Review prompts — edits outpacing approvals"
- If `escalated > 20%`: "Lots of escalations — scope may have shifted"
- Else: "All steady. Quality holding at {score}/5."

## Rendering and styling rules

- **No custom CSS** — Teams strips it
- **Styling via properties only** — `style`, `weight`, `color`, `spacing`, `size`
- **Max card size** — ~28KB after JSON serialisation (plenty for HR content)
- **Dark mode is automatic** — design for light, test both
- **Emoji reliable** — render correctly across all Teams clients
- **Image URLs** — must be on manifest `validDomains`

## Client-specific quirks

| Quirk | Impact | Mitigation |
|---|---|---|
| Mobile Teams truncates long TextBlocks | Cramped rendering | Keep drafts under ~500 chars |
| Dark mode text visibility | Hard-coded colors fail | Use semantic `color` values (default, accent, good, warning, attention) |
| ShowCard not in message extensions | Edit flow only works in bot DMs | We only use it in bot DMs; good |
| Action.Submit payload size limits | ~10KB practical max | Don't put large data in action payloads; reference auditId instead |

## Testing strategy

### Step 1: Designer tool
Before writing the card to TypeScript, paste the JSON into https://adaptivecards.io/designer/ and preview. Make sure it renders as intended.

### Step 2: Data shape unit test
```typescript
test('approval card renders with all required data', () => {
  const data: ApprovalCardData = {
    employeeName: 'Sarah Chen',
    // ... all fields
  };
  const card = buildApprovalCard(data);
  expect(card).toBeDefined();
  // Assert no unexpanded ${...} markers
  expect(JSON.stringify(card)).not.toContain('${');
});
```

### Step 3: Teams dev tenant render test
Sideload the Teams app into your M365 Developer tenant, trigger the card, visually verify.

### Step 4: Multi-client check
- Desktop Teams (primary)
- Teams web (teams.microsoft.com)
- Teams iOS / Android (if you have them)

## Common pitfalls

### Unexpanded template variables
Symptom: user sees `${draftReply}` literal text.  
Cause: data field missing in the `expand()` call.  
Fix: TypeScript interface prevents this at build time.

### Card fails to render entirely
Symptom: nothing appears, or error message.  
Cause: schema violation (invalid element type, wrong property name).  
Fix: paste JSON into designer; it'll tell you exactly what's wrong.

### Buttons don't trigger bot
Symptom: user taps button, nothing happens.  
Cause: `Action.Submit` data payload missing or endpoint unreachable.  
Fix: check `wrangler tail` — is the POST arriving? Check JWT verification — is it rejecting?

### ShowCard doesn't work
Symptom: user taps Edit, no inline form appears.  
Cause: `Action.ShowCard` nested incorrectly, or card version mismatch.  
Fix: review schema; ShowCard must be inside `actions` array.

## Cross-references

- Worker handler: `teams-hr-agent` skill
- Bot Framework activity shape: `bot-framework-teams` skill
- Cards are sent proactively: see §7 of component design for conversation reference pattern

## When NOT to use this skill

- For non-Adaptive-Card UI (HTML emails, web dashboard): wrong skill
- For Bot Framework protocol questions: `bot-framework-teams`
- For the underlying HR agent logic: `relevance-ai`

## One-sentence summary

Adaptive Cards are Intel Force OS's UI surface — schema-driven, templatable JSON that renders natively in Teams across all clients.
