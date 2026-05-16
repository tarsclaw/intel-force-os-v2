# 02 — Component Design

**Every component of the Teams HR Agent, in implementation detail. Code sketches, data contracts, configuration schemas, error handling.**

This file is the reference you return to when building. Organised by component so you can jump to the piece you're working on.

---

## Component overview

| # | Component | Runs on | Responsibility |
|---|---|---|---|
| 1 | **Teams app manifest** | Customer M365 tenant | Declares the app, bot, and required permissions |
| 2 | **Cloudflare Worker — bot endpoint** | Cloudflare (global edge) | Receives Bot Framework messages, orchestrates response |
| 3 | **Adaptive Cards** | Rendered in Teams client | User interface for approval, escalation, reports |
| 4 | **Relevance AI integration** | Called from Worker | The agent brain (HR reasoning, draft generation, sensitivity classification) |
| 5 | **Tenant configuration (KV)** | Cloudflare KV | Per-customer settings: HR Lead identity, approval mode, handbook KB ID, etc. |
| 6 | **Audit log (D1)** | Cloudflare D1 (SQLite at edge) | Every message + decision recorded for compliance and reporting |
| 7 | **Proactive messaging** | Worker → Bot Framework → Teams | Sending unprompted messages to HR Lead (escalations, reports) |
| 8 | **Secrets management** | Cloudflare Worker secrets | Microsoft app credentials, Relevance AI key, per-tenant overrides |

---

## 1. Teams app manifest

The manifest is a JSON file that tells Teams what the app is, what it can do, and what permissions it needs. Packaged into a `.zip` with icons and uploaded per customer (v1) or published to Teams App Store (v2).

### 1.1 Where it lives
`/teams-app/manifest.json` in your repo. Built into a zip at deploy time.

### 1.2 Structure (the essential parts)

```json
{
  "$schema": "https://developer.microsoft.com/en-us/json-schemas/teams/v1.19/MicrosoftTeams.schema.json",
  "manifestVersion": "1.19",
  "version": "1.0.0",
  "id": "{GENERATED_APP_UUID}",
  "packageName": "ai.intelforce.os",
  "developer": {
    "name": "Intel Force Ltd",
    "websiteUrl": "https://intelforce.ai",
    "privacyUrl": "https://intelforce.ai/privacy",
    "termsOfUseUrl": "https://intelforce.ai/terms",
    "mpnId": ""
  },
  "icons": {
    "color": "color.png",
    "outline": "outline.png"
  },
  "name": {
    "short": "Intel Force OS",
    "full": "Intel Force OS — AI for your HR inbox"
  },
  "description": {
    "short": "AI-assisted HR. Drafts every reply. Sends nothing without you.",
    "full": "Intel Force OS reads every HR message, drafts every reply, and flags what needs your judgement. Built for UK SMEs. Everything is a draft — nothing sends without you approving it."
  },
  "accentColor": "#10b981",
  "bots": [
    {
      "botId": "{GENERATED_BOT_UUID}",
      "scopes": ["personal", "team", "groupchat"],
      "supportsFiles": false,
      "isNotificationOnly": false,
      "commandLists": [
        {
          "scopes": ["personal", "team", "groupchat"],
          "commands": [
            {
              "title": "help",
              "description": "Show what I can do"
            },
            {
              "title": "status",
              "description": "See what's pending approval"
            },
            {
              "title": "report",
              "description": "Get this week's summary"
            }
          ]
        }
      ]
    }
  ],
  "validDomains": [
    "intelforce.ai",
    "bot.intelforce.ai"
  ],
  "permissions": [
    "identity",
    "messageTeamMembers"
  ]
}
```

### 1.3 Key fields explained

- **`bots[0].botId`** — the UUID created when you register the bot via Teams Developer Portal. Claude Code captures this from the registration step and writes it into the manifest.
- **`scopes`** — `personal` (1:1 chats), `team` (channels), `groupchat` (group DMs). We want all three for v1.
- **`commandLists`** — shows up as a `/` menu in Teams. Makes the bot discoverable: when HR Lead types `/`, they see "status", "report", etc.
- **`validDomains`** — required if any Adaptive Card action opens a URL. Must include your domains.
- **`permissions`** — Teams-level; not to be confused with Entra ID API permissions.

### 1.4 Icons

Two PNG files required:
- `color.png` — 192×192px, full-colour, appears in app catalogue
- `outline.png` — 32×32px, monochrome on transparent background, appears in taskbar

Design principle: emerald-green "IF" mark on transparent background for outline. Claude Code doesn't design icons; get Jack to make these in Figma.

### 1.5 Packaging

```bash
# From teams-app/ directory
zip -r intel-force-os-v1.0.0.zip manifest.json color.png outline.png
```

This zip is what you hand to customer IT admins to sideload, or upload to Teams App Store when the time comes.

---

## 2. Cloudflare Worker — the bot endpoint

### 2.1 Project structure

```
intel-force-os/
├── wrangler.toml              # Cloudflare config
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts               # Worker entry; routes requests
│   ├── bot/
│   │   ├── handler.ts         # Bot Framework turn handler
│   │   ├── auth.ts            # JWT verification
│   │   └── proactive.ts       # Proactive messaging (to HR Lead)
│   ├── cards/
│   │   ├── approval.ts        # Build approval Adaptive Card
│   │   ├── escalation.ts      # Build escalation card
│   │   └── report.ts          # Build weekly report card
│   ├── agents/
│   │   └── relevance.ts       # Relevance AI HTTP client
│   ├── storage/
│   │   ├── config.ts          # Tenant config (KV)
│   │   └── audit.ts           # Audit log (D1)
│   └── utils/
│       ├── redact.ts          # PII redaction
│       └── errors.ts          # Error types
├── teams-app/
│   ├── manifest.json
│   ├── color.png
│   └── outline.png
├── migrations/                # D1 schema migrations
│   └── 0001_initial.sql
└── tests/
    └── integration/
```

### 2.2 `wrangler.toml` (the Cloudflare deployment config)

```toml
name = "intel-force-os-bot"
main = "src/index.ts"
compatibility_date = "2026-04-01"
compatibility_flags = ["nodejs_compat"]

# UK/EU data residency
placement = { mode = "smart" }

[[kv_namespaces]]
binding = "TENANT_CONFIG"
id = "{KV_ID}"

[[d1_databases]]
binding = "AUDIT_DB"
database_name = "intel-force-audit"
database_id = "{D1_ID}"

[vars]
ENVIRONMENT = "production"
RELEVANCE_BASE_URL = "https://api-d7b62b.stack.tryrelevance.com/latest"

# Secrets set via: wrangler secret put <NAME>
# MICROSOFT_APP_ID
# MICROSOFT_APP_PASSWORD
# RELEVANCE_API_KEY
# CLAUDE_API_KEY  (fallback/future)
```

### 2.3 The entry point — `src/index.ts`

```typescript
import { Router } from 'itty-router';
import { handleBotMessage } from './bot/handler';
import { handleCardAction } from './bot/handler';
import { sendWeeklyReport } from './bot/proactive';

export interface Env {
  TENANT_CONFIG: KVNamespace;
  AUDIT_DB: D1Database;
  MICROSOFT_APP_ID: string;
  MICROSOFT_APP_PASSWORD: string;
  RELEVANCE_API_KEY: string;
  RELEVANCE_BASE_URL: string;
}

const router = Router();

// Bot messaging endpoint — Teams POSTs here
router.post('/api/messages', handleBotMessage);

// Card action handler — Teams POSTs here when a button is clicked
router.post('/api/card-action', handleCardAction);

// Health check
router.get('/health', () => new Response('OK'));

// Catchall
router.all('*', () => new Response('Not Found', { status: 404 }));

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext) {
    return router.handle(request, env, ctx);
  },
  
  // Scheduled triggers — for weekly reports (cron)
  async scheduled(controller: ScheduledController, env: Env, ctx: ExecutionContext) {
    await sendWeeklyReport(env, ctx);
  },
};
```

### 2.4 The bot message handler — `src/bot/handler.ts` (sketch)

```typescript
import { BotFrameworkAdapter, TurnContext, Activity } from 'botbuilder';
import { verifyJWT } from './auth';
import { callRelevanceAgent } from '../agents/relevance';
import { buildApprovalCard } from '../cards/approval';
import { buildEscalationCard } from '../cards/escalation';
import { getTenantConfig } from '../storage/config';
import { logMessage, logApproval } from '../storage/audit';

export async function handleBotMessage(request: Request, env: Env) {
  // 1. Verify the request came from Teams
  const authResult = await verifyJWT(request, env);
  if (!authResult.valid) {
    return new Response('Unauthorized', { status: 401 });
  }

  // 2. Parse the activity
  const activity: Activity = await request.json();
  const tenantId = activity.channelData?.tenant?.id ?? activity.conversation?.tenantId;
  if (!tenantId) {
    return new Response('Missing tenant ID', { status: 400 });
  }

  // 3. Load tenant config from KV
  const config = await getTenantConfig(env.TENANT_CONFIG, tenantId);
  if (!config) {
    // Tenant not provisioned — polite reply
    return sendReply(activity, 
      "Intel Force OS isn't configured for this tenant yet. Please contact your IT admin.");
  }

  // 4. Only handle messages addressed to the bot
  if (activity.type !== 'message') {
    return new Response('OK');  // ignore events like conversationUpdate
  }

  // 5. Extract the actual query text (strip @-mentions)
  const query = TurnContext.removeRecipientMention(activity);

  // 6. Slash commands
  if (query.startsWith('/help')) {
    return sendReply(activity, getHelpText());
  }
  if (query.startsWith('/status')) {
    return sendStatusReply(activity, env, tenantId);
  }

  // 7. Call the agent (Relevance AI)
  const agentResponse = await callRelevanceAgent(env, config, {
    message: query,
    context: {
      employee_name: activity.from.name,
      employee_aad_id: activity.from.aadObjectId,
      channel: activity.conversation.conversationType,
      timestamp: activity.timestamp,
    },
  });

  // 8. Log the incoming message + draft
  const auditId = await logMessage(env.AUDIT_DB, {
    tenantId,
    conversationId: activity.conversation.id,
    employeeAadId: activity.from.aadObjectId,
    originalQuery: query,
    draftReply: agentResponse.draft_reply,
    sensitivity: agentResponse.sensitivity_score,
    escalationRecommended: agentResponse.escalation_recommended,
    status: 'pending_approval',
  });

  // 9. Branch: escalation vs approval
  if (agentResponse.escalation_recommended) {
    // Send holding reply immediately to employee
    await sendReply(activity, agentResponse.draft_reply);

    // Send escalation card to HR Lead
    const card = buildEscalationCard({
      originalMessage: query,
      employeeName: activity.from.name,
      category: agentResponse.escalation_category,
      auditId,
    });
    await sendProactiveCard(env, config.hrLeadConversationId, card);

    // Update audit log
    await logApproval(env.AUDIT_DB, auditId, 'escalated', 'auto');

  } else {
    // Send approval card to HR Lead
    const card = buildApprovalCard({
      originalMessage: query,
      employeeName: activity.from.name,
      draftReply: agentResponse.draft_reply,
      sensitivityScore: agentResponse.sensitivity_score,
      confidence: agentResponse.confidence,
      citations: agentResponse.handbook_citations,
      auditId,
      conversationId: activity.conversation.id,
    });
    await sendProactiveCard(env, config.hrLeadConversationId, card);
  }

  return new Response('OK');
}

export async function handleCardAction(request: Request, env: Env) {
  // Card actions have a different auth pattern (invoke activity)
  const authResult = await verifyJWT(request, env);
  if (!authResult.valid) return new Response('Unauthorized', { status: 401 });

  const activity: Activity = await request.json();
  const action = activity.value.action;   // "approve" | "edit" | "reject" | "acknowledge"
  const auditId = activity.value.auditId;
  const tenantId = activity.channelData.tenant.id;

  const config = await getTenantConfig(env.TENANT_CONFIG, tenantId);
  const auditRecord = await getAuditRecord(env.AUDIT_DB, auditId);

  switch (action) {
    case 'approve':
      await postReplyInOriginalThread(env, config, auditRecord);
      await logApproval(env.AUDIT_DB, auditId, 'approved', activity.from.aadObjectId);
      return ackCard(activity, "✅ Sent.");

    case 'edit':
      const editedReply = activity.value.editedText;
      await postReplyInOriginalThread(env, config, { ...auditRecord, draftReply: editedReply });
      await logApproval(env.AUDIT_DB, auditId, 'edited_and_approved', activity.from.aadObjectId, { editedReply });
      return ackCard(activity, "✅ Edited and sent.");

    case 'reject':
      await postHoldingMessage(env, config, auditRecord);
      await logApproval(env.AUDIT_DB, auditId, 'rejected', activity.from.aadObjectId);
      return ackCard(activity, "Rejected. Holding message sent.");

    case 'acknowledge':
      await logApproval(env.AUDIT_DB, auditId, 'acknowledged', activity.from.aadObjectId);
      return ackCard(activity, "👁 Acknowledged. You'll handle from here.");
  }
}
```

### 2.5 Why this structure works

- **Stateless request handlers** — Worker functions start fresh every invocation; all state is in KV/D1
- **Auth in one place** — JWT verification happens once per request
- **Agent call abstracted** — swap Relevance AI for direct Claude later by replacing `callRelevanceAgent`
- **Card composition separated** — each card type is its own module, easy to test and iterate
- **Audit-first** — every message gets an audit record before any user-facing action

---

## 3. Adaptive Cards

Three primary cards in v1: **approval**, **escalation**, **weekly report**. A fourth (**config**) is added in v1.1 for HR Lead self-service.

See `06-adaptive-card-examples.json` for complete card JSON. This section covers the design intent.

### 3.1 Approval card — the core UX

Sent to HR Lead's 1:1 DM with the bot every time a non-escalation query comes in.

**Content:**
- Header: 👋 "From: Sarah Chen in #hr"
- Section 1: quoted employee message
- Section 2: draft reply (highlighted block)
- Section 3: metadata row — sensitivity indicator (green dot / amber / red), confidence %, handbook citation links
- Section 4: three action buttons: **[✓ Approve]** **[✎ Edit]** **[✗ Reject]**

**Behaviours:**
- Tap Approve → card collapses to "✅ Sent at 14:23" (confirmation)
- Tap Edit → card expands with an Input.Text field pre-filled with draft → Submit button
- Tap Reject → confirmation dialog → holding reply sent to employee, card updates

**Critical design points:**
- Buttons are large and finger-friendly (HR Lead is often on mobile)
- Sensitivity indicator is visual first, numeric second — a green dot says "safe" faster than "0.1/1.0"
- Citations are tappable and open handbook in browser (if customer has public handbook URL, otherwise static text)
- Nothing auto-refreshes — the card state reflects the last user action clearly

### 3.2 Escalation card — urgent attention

Sent to HR Lead's DM when the agent classified a message as requiring human attention (grievance, mental health, resignation, etc.).

**Content:**
- Header: 🔔 **Requires your attention** (red/amber accent)
- Section 1: employee name, timestamp, channel
- Section 2: full unredacted original message
- Section 3: category (e.g. "Interpersonal conflict", "Resignation intent", "Mental health")
- Section 4: what the agent already did — "Sent a gentle holding reply. Employee is waiting."
- Section 5: two buttons: **[I'll handle this]** **[Request Jack as backup]**

**Behaviours:**
- Tap "I'll handle" → card marks as acknowledged, audit log updated, no further action from bot
- Tap "Request backup" → card updates, sends DM to Jack (configured backup person), updates audit

**Critical design points:**
- Visual distinction from approval cards (red/amber stripe)
- No auto-resolution — escalation stays pending until HR Lead acknowledges
- After 2 hours of no acknowledgement during business hours, bot pings HR Lead again

### 3.3 Weekly report card

Sent Monday 09:00 UK time to HR Lead's DM, automatically via Worker cron.

**Content:**
- Header: 📊 "Your Intel Force OS week — 6–12 May"
- Metrics grid:
  - Messages handled: **47**
  - Approved as-is: **32 (68%)**
  - Edited before approval: **10 (21%)**
  - Rejected: **2**
  - Escalations: **3**
- Quality: avg correctness **4.7/5**
- Top patterns: handbook questions dominated (63%); sickness questions rising
- Optional: expandable "what Maddox did this week" section for founder-phase transparency

### 3.4 Rendering and styling constraints

- Adaptive Cards have a strict schema; deviations render as unstyled text
- No custom CSS; styling is via `style`, `weight`, `color`, `spacing` properties on elements
- Max card size is ~28KB after JSON serialisation — fits any realistic HR message
- Dark mode is automatic (Teams handles it); design in light mode, test in dark

### 3.5 Claude Code workflow for cards

1. Generate card JSON using `06-adaptive-card-examples.json` as template
2. Test in Teams Developer Portal card designer (`dev.teams.microsoft.com` → Tools → Adaptive Cards preview)
3. Parameterise with template variables (handlebars-style `{{employeeName}}`)
4. Render via `adaptivecards-templating` library in Worker

---

## 4. Relevance AI integration

### 4.1 The HTTP contract

Your existing Relevance AI agent exposes an HTTP trigger. Worker calls it as:

```typescript
// POST https://api-d7b62b.stack.tryrelevance.com/latest/agents/{agent_id}/trigger
// Headers:
//   Authorization: Bearer {RELEVANCE_API_KEY}
//   Content-Type: application/json

{
  "message": "what's the holiday carry-over policy?",
  "context": {
    "tenant_id": "abc-123",
    "employee_name": "Sarah Chen",
    "employee_aad_id": "aad-object-id",
    "channel": "channel",
    "channel_name": "#hr",
    "timestamp": "2026-04-23T14:23:00Z",
    "company_name": "Acme Consulting Ltd",
    "handbook_kb_id": "kb_abc123"
  }
}
```

### 4.2 Expected response

```typescript
{
  "draft_reply": "Our carry-over policy allows up to 5 days to roll over...",
  "sensitivity_score": 0.1,              // 0.0 = safe, 1.0 = highly sensitive
  "sensitivity_category": null,          // or "grievance" | "resignation" | "mental_health" | "harassment" | "health" | "other"
  "confidence": 0.92,                    // 0.0-1.0, how confident is the draft
  "handbook_citations": [
    { "snippet": "Holiday carry-over", "page": 23, "url": null }
  ],
  "escalation_recommended": false,
  "reasoning": "Simple policy lookup; handbook has clear answer."
}
```

### 4.3 The agent prompt (high-level, in Relevance AI)

The Relevance AI agent's system prompt must enforce:

1. **Always draft, never commit** — output is structured draft + metadata
2. **Sensitivity classification** — categorise BEFORE drafting; if sensitivity ≥ 0.7, mark `escalation_recommended: true` and set `draft_reply` to a gentle holding message, NOT an attempt to resolve
3. **Handbook grounding** — use Relevance AI's knowledge-base retrieval; citations in response
4. **Tone matching** — configurable per tenant via prompt variables
5. **Escape hatch** — if confidence < 0.5, mark `escalation_recommended: true` with category "low_confidence"

Your existing prompt probably covers most of this. The new structured output format needs to be added.

### 4.4 Fallback if Relevance AI is down

```typescript
try {
  return await callRelevanceAgent(...);
} catch (error) {
  if (error.status === 503 || error.timeout) {
    // Relevance AI unavailable — log, return graceful degradation
    await logError(env, 'relevance_unavailable', error);
    return {
      draft_reply: null,
      sensitivity_score: 1.0,   // treat as escalation (safer)
      escalation_recommended: true,
      escalation_category: "system_unavailable",
      reasoning: "Agent backend temporarily unavailable"
    };
  }
  throw error;  // other errors bubble up, logged separately
}
```

When the agent is unavailable, every query becomes an escalation → HR Lead sees the original message → handles manually. Ugly but safe.

### 4.5 Swapping to direct Claude (future)

When Relevance AI becomes cost-prohibitive or you want more control:

```typescript
// Swap this one file
import { callClaudeAgent } from './agents/claude';  // instead of relevance

// Same interface, different backend
const response = await callClaudeAgent(env, config, input);
```

The rest of the Worker code doesn't change.

---

## 5. Tenant configuration (Cloudflare KV)

### 5.1 KV key schema

```
tenant_config:{tenantId} → JSON blob (below)
hr_lead_conversation:{tenantId}:{aadObjectId} → conversation reference for proactive messaging
tenant_agents:{tenantId} → list of enabled agents (future: ["hr", "sales", "recruit"])
```

### 5.2 Tenant config shape

```typescript
interface TenantConfig {
  tenantId: string;               // M365 tenant ID
  customerName: string;           // e.g. "Acme Consulting Ltd"
  customerDomain: string;         // e.g. "acme.com"
  
  // Agent routing
  relevanceAgentId: string;       // Relevance AI agent ID for this tenant
  handbookKbId: string;           // Relevance AI knowledge base ID
  
  // Approval flow
  hrLeadAadId: string;            // HR Lead's Entra ID object ID
  hrLeadEmail: string;            // For fallback email if Teams unavailable
  hrLeadConversationId: string;   // Conversation reference for proactive messaging
  backupHrLeadAadId?: string;     // Optional: backup if primary unavailable
  
  // Behaviour
  approvalMode: 'all' | 'sensitive_only' | 'none';
  // all: every reply requires approval
  // sensitive_only: only sensitivity > threshold requires approval
  // none: auto-send all replies (not recommended)
  
  sensitivityThreshold: number;   // 0.0-1.0 (default 0.5)
  
  channels: string[];             // Teams channel IDs the bot listens to (e.g. ["#hr"])
  
  // Escalation routing
  escalationChannels: {
    interpersonal_conflict: 'hr_lead' | 'backup' | 'both';
    resignation: 'hr_lead';
    mental_health: 'hr_lead' | 'both';
    harassment: 'both';
    // ... more categories
  };
  
  // Reporting
  weeklyReportEnabled: boolean;
  weeklyReportTime: string;       // "monday_09:00_BST"
  
  // Tone
  companyTone: string;            // free text description, passed to Relevance AI
  
  // Compliance
  auditRetentionDays: number;     // default 2555 (7 years per Phase 5 SLA)
  piiRedactionEnabled: boolean;   // default true
  
  // Subscription
  subscriptionTier: 'founding' | 'starter' | 'growth';
  subscriptionStatus: 'active' | 'suspended' | 'cancelled';
  
  // Metadata
  createdAt: string;
  updatedAt: string;
  version: number;
}
```

### 5.3 Reading config in Worker

```typescript
export async function getTenantConfig(kv: KVNamespace, tenantId: string): Promise<TenantConfig | null> {
  const json = await kv.get(`tenant_config:${tenantId}`);
  if (!json) return null;
  return JSON.parse(json) as TenantConfig;
}

export async function setTenantConfig(kv: KVNamespace, tenantId: string, config: TenantConfig) {
  config.updatedAt = new Date().toISOString();
  await kv.put(`tenant_config:${tenantId}`, JSON.stringify(config));
}
```

### 5.4 Provisioning a new tenant

Per-customer install (manual v1):

```typescript
// Run locally during onboarding with a CLI tool
await provisionTenant({
  tenantId: "acme-m365-tenant-id",
  customerName: "Acme Consulting Ltd",
  customerDomain: "acme.com",
  hrLeadAadId: "sarah-aad-object-id",
  hrLeadEmail: "sarah@acme.com",
  relevanceAgentId: "agent_acme_hr",   // created per customer
  handbookKbId: "kb_acme",              // indexed from their handbook PDF
  // ... other config
});
```

This is called by a script Claude Code writes for you. Runs during the onboarding session. See `04-deployment-guide.md` §4.

---

## 6. Audit log (Cloudflare D1)

### 6.1 Schema

```sql
-- migrations/0001_initial.sql

CREATE TABLE audit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tenant_id TEXT NOT NULL,
  conversation_id TEXT NOT NULL,
  message_id TEXT,
  
  employee_aad_id TEXT,
  employee_name_redacted TEXT,       -- e.g. "S.C." not "Sarah Chen" by default
  
  original_query TEXT NOT NULL,
  query_embedding BLOB,              -- optional: for semantic search over past queries
  
  draft_reply TEXT,
  sensitivity_score REAL,
  sensitivity_category TEXT,
  confidence REAL,
  escalation_recommended INTEGER,    -- boolean as 0/1
  
  status TEXT NOT NULL,              -- pending_approval | approved | edited_and_approved | rejected | escalated | acknowledged
  actor_aad_id TEXT,                 -- who approved/rejected/etc
  action_timestamp TEXT,
  edited_reply TEXT,                 -- if status = edited_and_approved
  
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT,
  
  metadata TEXT                      -- JSON blob for flexibility
);

CREATE INDEX idx_audit_tenant ON audit_log(tenant_id, created_at DESC);
CREATE INDEX idx_audit_employee ON audit_log(tenant_id, employee_aad_id);
CREATE INDEX idx_audit_pending ON audit_log(tenant_id, status) WHERE status = 'pending_approval';
CREATE INDEX idx_audit_escalations ON audit_log(tenant_id, status) WHERE status = 'escalated';

CREATE TABLE tenant_stats_daily (
  tenant_id TEXT NOT NULL,
  date TEXT NOT NULL,
  messages_handled INTEGER DEFAULT 0,
  approved_asis INTEGER DEFAULT 0,
  edited INTEGER DEFAULT 0,
  rejected INTEGER DEFAULT 0,
  escalated INTEGER DEFAULT 0,
  avg_confidence REAL,
  avg_sensitivity REAL,
  PRIMARY KEY (tenant_id, date)
);

CREATE INDEX idx_stats_tenant_date ON tenant_stats_daily(tenant_id, date DESC);
```

### 6.2 Writing to audit log

```typescript
export async function logMessage(db: D1Database, entry: {
  tenantId: string;
  conversationId: string;
  employeeAadId?: string;
  originalQuery: string;
  draftReply: string | null;
  sensitivity: number;
  sensitivityCategory?: string;
  confidence: number;
  escalationRecommended: boolean;
  status: string;
}): Promise<number> {
  
  const result = await db.prepare(`
    INSERT INTO audit_log (
      tenant_id, conversation_id, employee_aad_id,
      employee_name_redacted, original_query, draft_reply,
      sensitivity_score, sensitivity_category, confidence,
      escalation_recommended, status
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).bind(
    entry.tenantId,
    entry.conversationId,
    entry.employeeAadId ?? null,
    redactName(entry.employeeAadId),  // implement in utils/redact.ts
    entry.originalQuery,
    entry.draftReply,
    entry.sensitivity,
    entry.sensitivityCategory ?? null,
    entry.confidence,
    entry.escalationRecommended ? 1 : 0,
    entry.status
  ).run();
  
  return result.meta.last_row_id;
}

export async function logApproval(
  db: D1Database, 
  auditId: number, 
  newStatus: string, 
  actorAadId: string,
  extras?: { editedReply?: string }
) {
  await db.prepare(`
    UPDATE audit_log 
    SET status = ?, actor_aad_id = ?, action_timestamp = datetime('now'),
        edited_reply = COALESCE(?, edited_reply), updated_at = datetime('now')
    WHERE id = ?
  `).bind(
    newStatus,
    actorAadId,
    extras?.editedReply ?? null,
    auditId
  ).run();
}
```

### 6.3 Querying for reports

```typescript
export async function getWeeklyStats(db: D1Database, tenantId: string, weekStart: Date) {
  const weekEnd = new Date(weekStart.getTime() + 7 * 86400000);
  
  const rows = await db.prepare(`
    SELECT 
      COUNT(*) as total,
      SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
      SUM(CASE WHEN status = 'edited_and_approved' THEN 1 ELSE 0 END) as edited,
      SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
      SUM(CASE WHEN status = 'escalated' THEN 1 ELSE 0 END) as escalated,
      AVG(confidence) as avg_confidence,
      AVG(sensitivity_score) as avg_sensitivity
    FROM audit_log
    WHERE tenant_id = ?
      AND created_at >= ?
      AND created_at < ?
  `).bind(
    tenantId,
    weekStart.toISOString(),
    weekEnd.toISOString()
  ).first();
  
  return rows;
}
```

### 6.4 DSAR / deletion

```typescript
// GDPR Article 17 — right to erasure
export async function deleteEmployeeData(db: D1Database, tenantId: string, employeeAadId: string) {
  const result = await db.prepare(`
    DELETE FROM audit_log 
    WHERE tenant_id = ? AND employee_aad_id = ?
  `).bind(tenantId, employeeAadId).run();
  
  return { deleted: result.meta.changes };
}

// GDPR Article 15 — right of access
export async function exportEmployeeData(db: D1Database, tenantId: string, employeeAadId: string) {
  const rows = await db.prepare(`
    SELECT * FROM audit_log 
    WHERE tenant_id = ? AND employee_aad_id = ?
    ORDER BY created_at DESC
  `).bind(tenantId, employeeAadId).all();
  
  return rows.results;
}
```

---

## 7. Proactive messaging

Sending an unprompted DM to HR Lead (for approval cards, escalations, reports) requires a stored conversation reference.

### 7.1 How conversation references are obtained

When HR Lead first installs the app and opens a 1:1 chat with the bot, the bot receives a `conversationUpdate` activity:

```typescript
// In bot handler
if (activity.type === 'conversationUpdate' && activity.membersAdded) {
  const botMemberAdded = activity.membersAdded.some(m => m.id === env.MICROSOFT_APP_ID);
  if (botMemberAdded) {
    // Bot was added — capture conversation reference
    const ref = TurnContext.getConversationReference(activity);
    const tenantId = activity.channelData.tenant.id;
    const userAadId = activity.from.aadObjectId;
    
    await env.TENANT_CONFIG.put(
      `hr_lead_conversation:${tenantId}:${userAadId}`,
      JSON.stringify(ref)
    );
  }
}
```

### 7.2 Sending proactively

```typescript
export async function sendProactiveCard(
  env: Env,
  conversationRef: ConversationReference,
  card: any
) {
  const adapter = createBotAdapter(env);
  
  await adapter.continueConversationAsync(
    env.MICROSOFT_APP_ID,
    conversationRef,
    async (context) => {
      await context.sendActivity({
        type: 'message',
        attachments: [{
          contentType: 'application/vnd.microsoft.card.adaptive',
          content: card,
        }],
      });
    }
  );
}
```

### 7.3 Weekly reports via cron

```typescript
// wrangler.toml
[triggers]
crons = ["0 9 * * 1"]   # Monday 09:00 UTC (adjust for BST)

// Worker scheduled handler
export async function sendWeeklyReport(env: Env, ctx: ExecutionContext) {
  const tenants = await env.TENANT_CONFIG.list({ prefix: 'tenant_config:' });
  
  for (const { name } of tenants.keys) {
    const tenantId = name.replace('tenant_config:', '');
    const config = await getTenantConfig(env.TENANT_CONFIG, tenantId);
    
    if (!config?.weeklyReportEnabled) continue;
    if (config.subscriptionStatus !== 'active') continue;
    
    const stats = await getWeeklyStats(env.AUDIT_DB, tenantId, lastMonday());
    const card = buildWeeklyReportCard({ config, stats });
    
    const convRef = await getHrLeadConversationRef(env, tenantId, config.hrLeadAadId);
    if (convRef) {
      ctx.waitUntil(sendProactiveCard(env, convRef, card));
    }
  }
}
```

---

## 8. Secrets management

### 8.1 Cloudflare Worker secrets

Set via `wrangler` CLI:

```bash
wrangler secret put MICROSOFT_APP_ID
wrangler secret put MICROSOFT_APP_PASSWORD
wrangler secret put RELEVANCE_API_KEY
```

These are encrypted at rest by Cloudflare, injected as environment variables into the Worker at runtime.

### 8.2 Rotation schedule

- `MICROSOFT_APP_PASSWORD` — rotate quarterly (90 days). Create new secret in Entra ID app, update Worker, delete old secret.
- `RELEVANCE_API_KEY` — rotate quarterly or when a customer churns (in case shared-tenant keys leak)
- Future per-tenant Claude keys — rotate on customer offboarding

Automation: GitHub Actions scheduled workflow runs quarterly, alerts you. Actual rotation is manual (rotating keys silently is how you take down production at 3am).

### 8.3 Worker environment access

```typescript
// In handler
const microsoftAppId = env.MICROSOFT_APP_ID;
const relevanceKey = env.RELEVANCE_API_KEY;

// Never log these. Ever. 
// Pre-deploy CI hook: grep for `env.MICROSOFT_APP_PASSWORD` in console.log — fail build if found
```

---

## 9. Error handling patterns

### 9.1 Expected errors

| Error | Response to user | Log level | Alert? |
|---|---|---|---|
| JWT verification fails | 401 to Teams | WARN | No — usually from Teams retry logic |
| Tenant not provisioned | Polite bot reply, escalate to sales | WARN | Yes — surface via Slack webhook |
| Relevance AI unavailable | Escalation card to HR Lead | ERROR | Yes — PagerDuty/Slack |
| Relevance AI returns malformed response | Escalation card | ERROR | Yes |
| D1 write failure | Continue but log | ERROR | Yes |
| KV read failure | Escalation card | ERROR | Yes |
| Bot Framework 4xx | 200 OK to Teams, log | WARN | No |
| Bot Framework 5xx | 500 (Teams retries) | ERROR | Yes |

### 9.2 Retry strategy

- **Relevance AI calls:** retry 1× with exponential backoff (500ms → 1500ms)
- **Bot Framework calls:** rely on Teams retrying on 5xx
- **D1 writes:** retry 2× within the same request
- **KV reads:** retry 1×, fall back to cached config if present in Worker memory

### 9.3 Graceful degradation

Every failure path must produce SOMETHING in Teams, not a silent drop. Employee's experience of a failed message is: "the bot sent me an apology explaining a human will reply shortly." HR Lead's experience is: "I got an urgent escalation asking me to handle manually."

---

## 10. Testing strategy

Full test plan in `04-deployment-guide.md` §6. Summary of what gets tested:

### 10.1 Unit tests (Jest / Vitest)

- JWT verification (valid token, expired, wrong audience, malformed)
- Relevance AI client (retries, timeout, error propagation)
- Adaptive Card rendering (template → valid JSON, parameter escaping)
- Audit log (insert, update, DSAR deletion)
- Tenant config (read, write, missing keys)
- PII redaction (names, phone numbers, NHS numbers, emails)

### 10.2 Integration tests (against dev M365 tenant)

- Full message flow: message → draft → approval card → approve → reply in channel
- Escalation flow: sensitive message → holding reply → escalation card
- Edit flow: message → card → edit → modified reply sent
- Weekly report: cron triggers, card delivered to dev-tenant HR Lead

### 10.3 Manual smoke tests per customer

- Employee sends test message in #hr — draft arrives in HR Lead DM within 10s
- HR Lead taps Approve — reply posted in #hr within 5s
- Employee sends "I'm having issues with my manager" — escalation card arrives
- Bot responds to `/help` with help card

---

## 11. Observability

### 11.1 Logging

```typescript
// Use console.log/warn/error — Cloudflare's Logpush captures these
console.log('message_received', { tenantId, employeeAadId, sensitivity });
console.warn('relevance_retry', { tenantId, attempt: 2, error: e.message });
console.error('d1_write_failed', { tenantId, error: e.message });
```

Structured logs — always JSON fields, never string interpolation. Claude Code can enforce this with a linter rule.

### 11.2 Metrics

Counters maintained in D1 `tenant_stats_daily` (aggregated nightly via cron). Queryable for reports and billing.

### 11.3 Uptime monitoring

- External: Better Uptime or Uptime Robot pinging `/health` endpoint every 60s
- Alert: >2 failures in 5 min → Slack + email
- Status page: `status.intelforce.ai` via Statuspage.io (Phase 5 spec)

### 11.4 Customer-facing analytics

v1: weekly report card (artifact above).  
v1.5: simple dashboard Tab inside the Teams app showing last 7/30 days.  
v2: full Phase 4 dashboard outside Teams.

---

## 12. Cost at scale (validation)

Cloudflare Workers, at 50 customers averaging 200 messages/day:
- 50 × 200 × 3 (message + card + action) = 30,000 request/day = ~900,000/month
- Workers paid plan: 10M requests/month for $5 — well under
- KV reads: ~1M/month — within free tier
- D1 writes: ~900k/month — within free tier (5M writes/month free)
- D1 storage: 50 tenants × 12 months × 5000 rows = 3M rows, ~600MB — within free tier (5GB)

**Real bottleneck is Relevance AI cost, which scales linearly. Covered in `01-architecture-overview.md` §8.**

---

Continue to `03-azure-bootstrap-via-claude-code.md` for the one-time setup sequence.
