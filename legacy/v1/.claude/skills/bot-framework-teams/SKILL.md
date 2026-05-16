---
name: bot-framework-teams
description: Microsoft Bot Framework protocol, Teams activity shapes, JWT authentication, conversation references, proactive messaging, card actions, and Teams-specific bot quirks. Use this skill when debugging bot auth issues, handling activity types, implementing proactive messages (bot DMing users without being prompted), adding new message or conversationUpdate handlers, working with the Teams messaging endpoint, or diagnosing why a message/card isn't being delivered. Also triggers on: Bot Framework, Teams bot, JWT, messagingEndpoint, conversationUpdate, serviceUrl, conversationReference, tenantId, AAD object ID.
---

# Bot Framework / Teams — Domain Skill

Microsoft's Bot Framework is the protocol between Teams and Intel Force OS. This skill covers the quirks, auth, and patterns for working with it correctly.

## Where the spec lives

- Component design §2: `docs/teams-hr-agent/02-component-design.md`
- Auth specifics: `docs/teams-hr-agent/02-component-design.md` §2.2, §11
- Proactive messaging: `docs/teams-hr-agent/02-component-design.md` §7
- External: Microsoft Bot Framework docs, Bot Framework SDK for Node.js

## The messaging endpoint

Every bot has one endpoint: `POST /api/messages` on your Worker.

Teams sends activities (events) to this endpoint. Your bot processes them and optionally responds.

### Activity types you handle

| Activity type | When sent | What to do |
|---|---|---|
| `message` | Employee sends a message in a channel/DM the bot is in | Route through Relevance AI, send approval card to HR Lead |
| `conversationUpdate` with member added = bot | Bot added to a DM or channel | Store conversation reference; send welcome card |
| `conversationUpdate` with member added = user | User added to a channel where bot exists | Ignore |
| `invoke` | Card action submitted | Handle the action (approve/edit/reject) |
| `installationUpdate` with action = "add" | App installed for a user | Store install record |
| `installationUpdate` with action = "remove" | App uninstalled | Cleanup |

### Activity types you ignore (for now)

- `typing` — someone's typing
- `messageReaction` — thumbs up/down
- `messageUpdate` — edited message
- `messageDelete` — deleted message

## JWT authentication — the gotcha

Every activity arrives with a JWT in the `Authorization` header. You MUST verify it before processing.

### Verification requirements

1. Signature verified against Microsoft's public keys (rotated; fetch from JWKS endpoint with caching)
2. `audience` claim equals `env.MICROSOFT_APP_ID`
3. `issuer` is `https://api.botframework.com`
4. Token not expired

### The audience trap

The audience claim is NOT `https://api.botframework.com`. It's YOUR `MICROSOFT_APP_ID` (the UUID of your Entra ID app). If you use the wrong audience check, everything passes auth that shouldn't.

### Implementation

```typescript
import { createRemoteJWKSet, jwtVerify } from 'jose';

const jwks = createRemoteJWKSet(
  new URL('https://login.botframework.com/v1/.well-known/keys')
);

export async function verifyJWT(authHeader: string, appId: string) {
  const token = authHeader.replace(/^Bearer\s+/i, '');
  const { payload } = await jwtVerify(token, jwks, {
    audience: appId,  // MUST be your app ID, not a generic value
    issuer: 'https://api.botframework.com',
  });
  return payload;
}
```

## Conversation references — the key to proactive messaging

A "conversation reference" is a JSON object that uniquely identifies a Teams conversation. You need it to send messages without being prompted (proactive messaging).

### Shape

```typescript
interface ConversationReference {
  channelId: 'msteams';
  serviceUrl: string;  // e.g. 'https://smba.trafficmanager.net/uk/'
  conversation: {
    id: string;
    tenantId: string;
    conversationType: 'personal' | 'channel' | 'groupChat';
  };
  bot: { id: string; name: string };
  user: { id: string; aadObjectId: string };
}
```

### When to capture

- Bot added to a conversation (`conversationUpdate` with bot in members added)
- Any message sent in that conversation (extract reference from incoming activity)

### Where to store

- `hr_lead_conversation:{tenantId}:{aadObjectId}` in KV — for sending approval cards to HR Lead
- `channel_conversation:{tenantId}:{channelId}` in KV — for posting replies to source channel
- `user_conversation:{tenantId}:{aadObjectId}` in KV — for reply-back to employees (if ever needed)

### Sending a proactive message

```typescript
import { BotFrameworkAdapter } from 'botbuilder';

const adapter = new BotFrameworkAdapter({
  appId: env.MICROSOFT_APP_ID,
  appPassword: env.MICROSOFT_APP_PASSWORD,
});

await adapter.continueConversation(
  conversationReference,  // retrieved from KV
  async (turnContext) => {
    await turnContext.sendActivity({
      type: 'message',
      attachments: [{
        contentType: 'application/vnd.microsoft.card.adaptive',
        content: approvalCardJson,
      }],
    });
  }
);
```

## Handling card actions

When user clicks a button in an Adaptive Card with `Action.Submit`, Teams sends an `invoke` activity to your endpoint.

### The shape

```json
{
  "type": "invoke",
  "name": "adaptiveCard/action",
  "value": {
    "action": {
      "type": "Action.Submit",
      "data": {
        "action": "approve",
        "auditId": "12345",
        "conversationId": "..."
      }
    }
  }
}
```

### Responding

Invoke activities expect an HTTP 200 response within 5 seconds. If your handler takes longer (e.g. updating D1, posting to channel), either:

1. Fast-ack pattern: return 200 immediately, process async (Workers supports `ctx.waitUntil()`)
2. Or respond inline if you can be certain it's < 5s

### Updating the card after action

After approval, the card should visually update ("✓ Approved by Sarah at 14:23"). Two options:

1. **Replace the card** via `updateActivity` with a new card showing the outcome
2. **Add a note** via separate message in the same conversation

Pattern 1 is cleaner. See `docs/teams-hr-agent/02-component-design.md` §3.4.

## Tenant context in every activity

Every incoming activity has:
- `channelData.tenant.id` — the customer's M365 tenant ID
- `conversation.tenantId` — redundantly the same
- `from.aadObjectId` — the user's AAD object ID (stable across sessions)

**Use tenant ID for everything** — KV keys, D1 queries, agent routing. Never mix tenants.

## Common pitfalls

### Bot messages but can't reply
Symptom: Bot receives messages, logs look fine, no reply appears.  
Cause: JWT audience wrong; bot can't authenticate its outbound calls to `serviceUrl`.  
Fix: Verify `MICROSOFT_APP_ID` matches your Entra ID app registration. Not the bot's internal GUID; the Entra ID app.

### Bot added but welcome card doesn't appear
Symptom: User installs app, nothing happens.  
Cause: You handle `conversationUpdate` but not with the right filter on `membersAdded`.  
Fix: Check `activity.membersAdded?.some(m => m.id === env.MICROSOFT_APP_ID)` — bot being added means sending welcome.

### Proactive message fails with 401
Symptom: Bot tries to send proactive card, gets 401.  
Cause: Token for outbound call to `serviceUrl` is wrong; `serviceUrl` not trusted.  
Fix: `MicrosoftAppCredentials.trustServiceUrl(serviceUrl)` before `continueConversation`. Or use the latest SDK patterns which handle this automatically.

### Activities arrive with invalid signatures
Symptom: JWT verification fails on activities Teams "clearly sent."  
Cause: JWKS keys rotated; your cache is stale.  
Fix: `jose`'s `createRemoteJWKSet` handles this automatically. If doing manual fetching, respect `Cache-Control` headers.

### Card action works in dev, fails in prod
Symptom: Card button responds correctly in dev tenant, silently fails in customer tenant.  
Cause: customer's IT admin didn't grant admin consent for all required scopes.  
Fix: Admin consent URL during onboarding — see `docs/teams-hr-agent/04-deployment-guide.md` §4.

## Service URLs — tenant-specific

Different M365 tenants land on different `serviceUrl` values (`smba.trafficmanager.net/uk/`, `/eu/`, `/amer/`, etc.). Always store and use the `serviceUrl` from the incoming activity; never hardcode.

UK customers typically land on `/uk/` — good for data residency.

## Teams manifest integration

The bot's behaviour is configured in two places:
1. **Entra ID app registration** — identity, secrets, permissions
2. **Teams app manifest** — UX, scopes (personal, team, groupchat), commands

Keep `teams-app/manifest.json` in sync with what the bot actually supports. If the manifest says `scopes: ["personal", "team"]` but your bot crashes on team messages, you've got a mismatch.

## Cross-references

- Worker implementation: `teams-hr-agent` skill
- Cards sent via Bot Framework: `adaptive-cards` skill
- Cloudflare-specific integration: `cloudflare-intel-force` skill

## When NOT to use this skill

- For business decisions about bot scope: `teams-hr-agent` or `phase-0-strategic`
- For card content/design: `adaptive-cards`
- For the HR agent brain: `relevance-ai`

## One-sentence summary

Bot Framework is Teams's messaging protocol; the tricky bits are JWT audience validation, conversation references for proactive messages, and keeping tenant context straight.
