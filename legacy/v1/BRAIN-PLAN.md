# Intel Force OS — Brain System Plan
**All 5 decisions resolved. Ready to build.**

> Based on: Karpathy LLM wiki · Microsoft MarkItDown · Kepano Obsidian Skills  
> Status: Plan complete — decisions locked — build starts Phase 1  
> Visualisation: Built into dashboard Knowledge section. No redirect to Obsidian.

---

## The Core Idea

> *"Turn messy source material into structured, compounding knowledge."* — Karpathy

Every piece of knowledge is a `.md` file. Agents retrieve only what they need per invocation — 2-4k tokens instead of 40-200k. The vault compounds over time: each session adds knowledge that makes the next invocation smarter.

```
Token reduction maths:
  Without brain: 48-page handbook (40k) + history (8k) = 48k tokens/call
  With brain:    skill file (800) + 2 policy pages (2k) + session context (500) = 3.3k tokens/call
  Reduction:     48,000 / 3,300 = 14.5× (v1, 48-page handbook)
  
  At enterprise scale (200-page handbook, 12-month session history):
  Without brain: 200k+ tokens
  With brain:    still ~3.5k (only relevant pages load)
  Reduction:     200,000 / 3,500 = 57× → approaches the 71× benchmark
```

---

## Decisions — All Resolved

### Decision 1 — Handbook ingestion: Microsoft MarkItDown ✓

**Resolution:** Upload PDF → MarkItDown microservice converts to markdown → parser splits into per-section `.md` files → stored in KV → indexed in D1.

**MarkItDown facts (from repo):**
- Python 3.10+, no JavaScript/npm version
- Docker: `docker run --rm -i markitdown:latest < file.pdf > output.md`
- Supports PDF, Word, PowerPoint, Excel, HTML, images, audio
- Output optimised for LLM consumption (not print fidelity)
- No built-in REST API — we wrap it

**Integration architecture:**

```
HR Lead uploads PDF
        ↓
Next.js server action (POST /api/knowledge/upload)
        ↓
MarkItDown microservice (FastAPI + Docker, Hetzner)
        ↓  POST multipart/form-data
        ↓  returns: { markdown: string }
        ↓
Section parser (Node.js, runs in server action)
  — splits on H1/H2 headings → individual .md files
  — adds YAML frontmatter (type, title, tags, coverage, agent-instructions)
  — detects policy category (leave / sick / grievance / pay / disciplinary)
        ↓
KV write: brain:{tenantId}:handbook:{section-slug} → markdown content
D1 write: VaultFile row (path, type, title, tags, wikilinks, tokenCount, kvKey)
        ↓
Knowledge page refreshes → file appears in tree + graph
```

**MarkItDown microservice** (`services/markitdown/`):

```python
# services/markitdown/main.py
from fastapi import FastAPI, UploadFile, File
from markitdown import MarkItDown
import tempfile, os

app = FastAPI()
md = MarkItDown(enable_plugins=False)

@app.post("/convert")
async def convert(file: UploadFile = File(...)):
    suffix = os.path.splitext(file.filename)[1]
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        content = await file.read()
        tmp.write(content)
        tmp.flush()
        result = md.convert(tmp.name)
    os.unlink(tmp.name)
    return {"markdown": result.text_content, "filename": file.filename}

@app.get("/health")
def health():
    return {"status": "ok"}
```

```dockerfile
# services/markitdown/Dockerfile
FROM python:3.12-slim
RUN pip install 'markitdown[pdf,docx,pptx]' fastapi uvicorn python-multipart
COPY main.py .
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

Added to `observability/docker-compose.yml` as a sibling service.

**Section parser (TypeScript, runs in Next.js server action):**

```typescript
// apps/dashboard/lib/handbook-parser.ts

interface PolicySection {
  slug: string;               // "leave-holiday"
  title: string;              // "Annual Leave Policy"
  heading: string;            // "## 3.2 Annual Leave"
  content: string;            // raw markdown body
  tags: string[];             // ["leave", "holiday", "entitlement"]
  sectionRef: string;         // "§3.2"
  agentInstructions: string;  // auto-generated stub
}

export function splitHandbookIntoSections(markdown: string): PolicySection[] {
  // Split on H2 or H3 headings
  // Detect section category from keyword matching
  // Auto-generate agent-instructions stub
  // Return array of sections ready to write to KV
}
```

The auto-generated `## Agent instructions` block gives the agent a stub it can learn from — coverage scoring, confidence guidance, and cross-references to related sections.

---

### Decision 2 — Employee data: Hybrid strategy ✓

**Resolution:** Real-time for sensitive/changing data, cached vault for structural context.

**Why:** Leave balances change daily. A stale balance in the vault could cause a wrong answer that gets approved and sent. That's a compliance incident. Department structure and headcount change rarely — caching these avoids a Breathe HR API call on every invocation.

```
ALWAYS live from Breathe HR (call at query time):
  ├── Leave balances (days entitlement, days taken, remaining)
  ├── Current absence status (is the employee off right now?)
  └── Recent absence history (last 90 days)

CACHED in vault (refresh every 4h, anonymised):
  ├── vault/employees/_index.md  — dept map, headcount, job title groups
  ├── No names — employee refs only (A2841, B1203)
  └── No individual leave data — only aggregates (total leave taken this quarter)
  
NEVER in vault (not stored anywhere except D1 for audit):
  ├── Employee names (PIIredacted everywhere except encrypted D1 field)
  └── Individual medical or disciplinary records
```

**`vault/employees/_index.md` format:**

```markdown
---
type: employee-index
tenant: elm-row-dental
last-synced: 2026-04-25T12:00:00Z
employee-count: 34
departments: [Operations, Clinical, Admin, Management]
---

# Employee Index — Elm Row Dental

## Departments
- **Operations** — 12 employees
- **Clinical** — 14 employees  
- **Admin** — 6 employees
- **Management** — 2 employees

## Context for agents
When an employee asks about leave or absence, call `get_employee_info` to get
their live data from Breathe HR. Do NOT rely on this file for individual balances.

This file tells you the structure of the organisation, not individual records.
Use it to understand department context when crafting a reply.
```

**In `src/agents/tools.ts` — the get_employee_info tool always calls Breathe HR live:**

```typescript
case 'get_employee_info': {
  // ALWAYS hits Breathe HR API. Never reads from vault.
  // The vault only stores structural/aggregate context.
  if (!breatheHrApiKey) { ... fallback ... }
  const summary = await getEmployeeSummary(breatheHrApiKey, employeeName);
  // After the call, write the result to the session log (vault Layer 2)
  await appendToSession(kv, tenantId, { toolCall: 'get_employee_info', result: summary });
  return formatEmployeeSummary(summary);
}
```

---

### Decision 3 — Skill file editing: Admin writes, HR Lead inputs ✓

**Resolution:** HR Lead can upload documents and add client notes. Skill files and agent instruction blocks are platform-admin (Maddox) only.

```
HR Lead can:                          HR Lead CANNOT:
  Upload handbook PDF                   Edit skill .md files
  Add/edit client-profile.md            Edit ## Agent instructions blocks
  View all vault files (read-only)      Configure sensitivity thresholds
  Upload supplementary docs             Add new agent routing rules
  Add notes to the vault                Delete session logs or decisions
  
Platform admin (Maddox) can:
  Write and edit all skill files
  Set agent instruction blocks
  Configure sensitivity rules
  Promote HR Lead edits to policies
  Export/delete full tenant vault
```

**Why:** Agent skill files define HOW the agent behaves — thresholds, confidence rules, escalation triggers. An HR Lead misediting a skill file could silently break the agent. They get full visibility into what the agent knows, but the agent's operational logic stays under platform control.

In the dashboard, the Knowledge page shows:
- `skills/` folder: visible, read-only, "managed by Intel Force" badge
- `handbook/` folder: visible, editable (HR Lead can correct misformatted sections)
- `sessions/` + `decisions/`: visible, read-only, export only

---

### Decision 4 — Graph layout: Obsidian-style force-directed ✓

**Resolution:** D3.js force-directed graph, premium Obsidian aesthetic, visually spectacular.

**Design spec:**

```
Node types and visual treatment:
  ● Policy files    — emerald (#10b981), large circle, glow on hover
  ● Session files   — amber (#f59e0b), medium circle, pulsing if today
  ● Decision files  — sky (#38bdf8), small circle
  ● Skill files     — purple (#a78bfa), hexagon shape
  ● Client profile  — white (#f4f4f5), star shape (central node)

Node size = citation frequency
  Files cited more by agents → larger node
  Rarely used files → smaller, dimmer
  
  This makes the graph self-organising around what matters:
  leave-holiday.md will be huge; health-safety.md will be small

Edges (links from [[wikilinks]]):
  — Thin lines (#ffffff08) between connected nodes
  — On hover: highlight all edges of selected node in node's colour
  — Edge weight = number of shared citations (thicker = more related)

Ambient effects:
  — Dark canvas (#07090b) matching dashboard
  — Grain texture overlay
  — Subtle emerald radial glow behind the client-profile node (hub)
  — Nodes that were cited in the LAST 24H get a pulse animation
  — Nodes that were NEVER cited are 40% opacity (shows knowledge gaps)

Interactions:
  — Click node → opens in markdown viewer (centre panel)
  — Hover → mini card preview (frontmatter: type, last-updated, citation count, coverage)
  — Drag nodes (force graph is draggable)
  — Scroll to zoom
  — Double-click canvas → reset to centre
  — Search bar above graph → type to highlight matching nodes, dim others
  — Filter pills: [All] [Policies] [Sessions] [Decisions] [Skills]
```

**D3 implementation approach:**

```typescript
// apps/dashboard/components/brain/knowledge-graph.tsx
'use client';
import * as d3 from 'd3';

interface GraphNode {
  id: string;           // vault path
  type: 'policy' | 'session' | 'decision' | 'skill' | 'profile';
  title: string;
  citationCount: number;
  lastCited: Date | null;
  coverage?: number;    // policy files only
}

interface GraphEdge {
  source: string;       // vault path
  target: string;       // wikilink target
  weight: number;       // shared citation frequency
}
```

The graph is rendered in the right panel of the Knowledge page. On small screens, it collapses to a full-screen modal triggered by a "Show graph" button.

---

### Decision 5 — Session timeline: Hybrid real-time + paginated history ✓

**Resolution:** Today's activity uses SSE (same channel as the escalations stream, already built). Historical sessions load on demand, grouped by week.

**Why:** Real-time for today makes the system feel alive — HR Lead sees each query appear as it happens. Loading 12 months of history upfront would be slow and unnecessary; weekly grouping makes navigation fast.

```
Session timeline UX:

  ● Live  — TODAY'S SESSIONS (SSE, real-time)
  ─────────────────────────────────────────────
  09:14  Draft created — annual leave — Jane D.    [PENDING]
  09:10  Tool call — lookup_handbook_policy         ✓
  09:09  Message received — #hr-queries             ✓

  ───────── YESTERDAY ─────────
  16:33  Escalation — grievance — Sarah K.         ↑
  [Load 23 more ↓]

  ───────── THIS WEEK ─────────
  Mon 22 · 18 events  Tue 21 · 11 events  [Load week ↓]

  ───────── APRIL ─────────
  [W17 ·47] [W16 ·38] [W15 ·52] [W14 ·29]
```

The week-blocks show a token-cost sparkline alongside event count — this is where the token reduction becomes visible. Clients can SEE their costs go down as the brain learns their knowledge.

---

## Architecture — Three Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 3: AGENT SKILLS  — compact, loaded per invocation            │
│                                                                     │
│  skills/hr-policy-lookup.md       ~800 tokens                       │
│  skills/employee-info.md          ~600 tokens                       │
│  skills/approval-router.md        ~700 tokens                       │
│  skills/weekly-reporter.md        ~500 tokens                       │
│  skills/proposal-builder.md       ~900 tokens                       │
│  skills/lead-hunter.md            ~600 tokens                       │
│  [one per agent — 14 total]                                         │
├─────────────────────────────────────────────────────────────────────┤
│  LAYER 2: SESSION MEMORY  — auto-written, append-only               │
│                                                                     │
│  sessions/2026-04-25.md           today's log (appended live)       │
│  sessions/2026-04-24.md           yesterday (closed, immutable)     │
│  decisions/2026-04-25-A2841.md    individual decision records       │
│  weekly/2026-W17.md               auto-generated Friday summary     │
├─────────────────────────────────────────────────────────────────────┤
│  LAYER 1: KNOWLEDGE BASE  — client truth, written on upload         │
│                                                                     │
│  client-profile.md                company name, tone, ICP           │
│  handbook/leave-holiday.md        §3.x — from MarkItDown            │
│  handbook/sick-leave.md           §5.x                              │
│  handbook/grievance.md            §4.x — usually largest section    │
│  handbook/pay-benefits.md         §7.x — often thin, flag gaps      │
│  handbook/disciplinary.md         §6.x                              │
│  handbook/health-safety.md        §8.x                              │
│  handbook/index.md                TOC + coverage scores             │
│  employees/_index.md              dept map, headcount (no names)    │
│  policies/approval-flow.md        who approves what, thresholds     │
│  policies/sensitivity-rules.md    escalation triggers               │
│  integrations/breathe-hr.md       API config, field map             │
│  integrations/teams.md            bot config, channel map           │
└─────────────────────────────────────────────────────────────────────┘
         ↓ all stored in Cloudflare KV — per-tenant namespace
         ↓ indexed in D1 VaultFile table — for fast listing
         ↓ visualised as graph in dashboard Knowledge section
```

---

## File Format — Every Vault File

```markdown
---
type: policy
section: "§3.2"
title: "Annual Leave"
last-updated: 2026-04-25
coverage: 95
tags: [leave, holiday, entitlement, carry-forward]
related: [[leave-holiday]], [[approval-flow]], [[sick-leave]]
citations: 47
last-cited: 2026-04-25
---

# Annual Leave

## Entitlement
Full-time employees receive **25 days** per year pro-rated for part-time staff...

## Carry-forward
Up to **5 days** may be carried forward into the next holiday year...

## Booking procedure
...

## Agent instructions
When an employee asks about annual leave or remaining holiday:
1. Always call `get_employee_info` first — entitlement + taken + remaining comes from Breathe HR live
2. Use this page for: carry-forward rules, booking procedure, and policy exceptions
3. Confidence: 0.85 if Breathe HR data present; 0.55 if not (flag data unavailability)
4. Related: check [[approval-flow]] if employee wants to book; check [[sick-leave]] if absence-related
5. Red flag: sensitivity ≥ 0.7 if employee mentions dispute, unfairness, or manager conflict
```

**Every file MUST have:**
- YAML frontmatter (type, title, tags, related, citations, last-cited)
- `## Agent instructions` block at the bottom (operational guidance, not visible to HR Lead by default)
- `[[wikilinks]]` to related files (these build the graph)

---

## Session Log Format

```markdown
---
date: 2026-04-25
tenant: elm-row-dental
queries: 6
approved: 3
pending: 3
escalated: 0
cost-gbp: 0.74
avg-tokens: 3240
avg-response-time-s: 1.8
---

# Session — Friday 25 April 2026

## 09:09 — Annual leave query
**Employee:** ref #A2841 · Operations dept  
**Query:** "Do I have any remaining annual leave this year?"  
**Skill loaded:** `skills/hr-policy-lookup` (847 tokens)  
**Policies retrieved:** [[leave-holiday]] (1,240 tokens) · [[approval-flow]] (380 tokens)  
**Breathe HR:** live call — 25d entitlement · 18d taken · 7d remaining  
**Total context:** 3,212 tokens (vs 48,000 without brain → **14.9× reduction**)  
**Draft:** sent for approval 09:14  
**Outcome:** APPROVED by Jordan R. at 09:14 · 5 min response time  
**Decision file:** [[decisions/2026-04-25-A2841-leave]]

## 08:43 — Sick leave query
...
```

The `avg-tokens` and the explicit comparison to "without brain" turns the session log into a live cost dashboard. HR Leads see the reduction happening.

---

## Skill File — All 14 Agents

Each skill file is ~600-900 tokens. Written by platform admin. HR Lead can read, not edit.

**Template:**

```markdown
---
agent: hr-policy-lookup
tokens: 847
model: claude-sonnet-4-6
version: 1.2
last-updated: 2026-04-01
managed-by: platform-admin
---

# HR Policy Lookup Skill

## Your role
You retrieve relevant policy sections from the client handbook vault.
You do NOT generate answers — you retrieve and return source text.

## How to retrieve
Search by: section heading > tag match > keyword scan
Load only sections relevant to the query. Max 3 sections per call.

## Output format
Return: `[[section-slug]]` reference + policy text + agent-instructions block

## Coverage handling
If `coverage < 60` for a section: flag it in your response.
If the handbook has no relevant section: set confidence below 0.5 and say so.

## What you do NOT do
Do not paraphrase policy. Return source text.
Do not make up policy that isn't in the handbook.
Do not guess at company-specific rules.
```

---

## The Knowledge Dashboard — Visual Spec

Three panels, always in-browser, Obsidian aesthetic.

```
┌──────────────────────────────────────────────────────────────────────────┐
│  Knowledge                                          [Upload] [Export .zip]│
│                                                                           │
│  ┌──────────────┐  ┌────────────────────────────┐  ┌───────────────────┐ │
│  │  FILE TREE   │  │  MARKDOWN VIEWER            │  │  KNOWLEDGE GRAPH  │ │
│  │              │  │                             │  │                   │ │
│  │ 📁 handbook/ │  │  # Annual Leave             │  │   [D3 force graph │ │
│  │  ● leave.md  │  │                             │  │    Obsidian-style │ │
│  │  ● sick.md   │  │  ## Entitlement             │  │    #07090b canvas │ │
│  │  ○ pay.md    │  │  25 days per year...        │  │    grain texture  │ │
│  │              │  │                             │  │    emerald glows  │ │
│  │ 📁 sessions/ │  │  ## Carry-forward           │  │    pulse on live] │ │
│  │  ● today     │  │  Up to 5 days...            │  │                   │ │
│  │  · yesterday │  │                             │  │  [All][Policies]  │ │
│  │              │  │  → Related:                 │  │  [Sessions][Skills│ │
│  │ 📁 decisions/│  │  [[sick-leave]]             │  │                   │ │
│  │ 🔒 skills/   │  │  [[approval-flow]]          │  │  🔍 Search nodes  │ │
│  │   managed    │  │                             │  │                   │ │
│  │              │  │  [🔒 Agent instructions     │  │                   │ │
│  │  ─────────   │  │   hidden — admin only]      │  │                   │ │
│  │  34 files    │  │                             │  │  leave.md ●●●     │ │
│  │  Coverage:   │  │  Last cited: 4m ago         │  │  grievance.md ●●  │ │
│  │  ████░░ 82%  │  │  Citations: 47 this month   │  │  sick.md ●        │ │
│  │              │  │  Coverage: 95%              │  │  [size=citations] │ │
│  └──────────────┘  └────────────────────────────┘  └───────────────────┘ │
│                                                                           │
│  ─── LIVE SESSION TIMELINE ──────────────────────────────────────────── │
│  ● 09:14  Draft created — annual leave — #A2841   [PENDING]  3,212 tok  │
│  ✓ 09:10  Handbook lookup — §3.2 Annual Leave                            │
│  ✓ 09:09  Message received — #hr-queries                                 │
│  ─── Yesterday (25 events) [load] ─── W17 (47 events) [load] ──────── │
└──────────────────────────────────────────────────────────────────────────┘
```

**Graph visual details (Obsidian aesthetic):**

```
Canvas:       #07090b (matches dashboard)
Grain:        SVG fractalNoise overlay at 0.35 opacity
Node colors:
  Policy      #10b981 emerald, circle, glow
  Session     #f59e0b amber, circle (today = pulsing)
  Decision    #38bdf8 sky, small circle
  Skill       #a78bfa purple, hexagon
  Profile     #f4f4f5 white, large star (central hub)
Node size:    citations/month → radius 4–20px
Node opacity: never-cited = 40%, cited today = 100%
Edges:        rgba(255,255,255,.06) at rest
              node-color at 60% on hover
Link force:   short links for [[wikilinks]], longer for weaker connections
Charge:       -200 (repulsion keeps nodes readable)
```

---

## Technical Implementation

### New files to create

```
services/
  markitdown/
    Dockerfile
    main.py                    ← FastAPI wrapper around MarkItDown
    requirements.txt

src/brain/
    vault.ts                   ← KV read/write helpers
    session.ts                 ← session log append + decision write
    skills.ts                  ← skill file loader (cached in Worker memory)
    parser.ts                  ← handbook section splitter
    index.ts                   ← exports

packages/db/prisma/
  schema.prisma                ← add VaultFile model, VaultFileType enum

packages/trpc/src/routers/
  vault.ts                     ← new tRPC router (listFiles, getFile, getGraph, updateFile)

apps/dashboard/
  app/t/[slug]/knowledge/
    page.tsx                   ← REWRITE: three-panel layout
  components/brain/
    file-tree.tsx              ← left panel
    markdown-viewer.tsx        ← centre panel (renders md + wikilinks)
    knowledge-graph.tsx        ← right panel (D3 force graph)
    session-timeline.tsx       ← bottom strip (SSE + paginated)
    upload-zone.tsx            ← handbook upload with progress
```

### KV key schema

```
brain:{tenantId}:profile                        → client-profile.md
brain:{tenantId}:handbook:{slug}               → policy section .md
brain:{tenantId}:employees:_index              → dept map .md
brain:{tenantId}:sessions:{YYYY-MM-DD}         → session log .md (append-only)
brain:{tenantId}:decisions:{date}-{ref}        → decision record .md (immutable)
brain:{tenantId}:weekly:{YYYY-Www}             → weekly summary .md
brain:{tenantId}:skills:{agent-slug}           → skill file .md
brain:{tenantId}:vault-index                   → JSON: [{path, type, title, tags, kvKey}]
```

### New Prisma model

```prisma
model VaultFile {
  id          String        @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  tenantId    String        @map("tenant_id") @db.Uuid
  path        String        -- "handbook/leave-holiday"
  type        VaultFileType
  title       String
  tags        String[]
  wikilinks   String[]      -- parsed [[targets]] for graph edges
  coverage    Int?          -- policy files only, 0-100
  tokenCount  Int?          @map("token_count")
  citations   Int           @default(0) -- how many times agents cited this
  lastCited   DateTime?     @map("last_cited")
  kvKey       String        @map("kv_key")
  editableBy  String        @default("admin") @map("editable_by") -- "admin"|"hr_lead"
  createdAt   DateTime      @default(now()) @map("created_at")
  updatedAt   DateTime      @updatedAt @map("updated_at")

  tenant Tenant @relation(fields: [tenantId], references: [id])
  @@unique([tenantId, path])
  @@index([tenantId, type])
  @@index([tenantId, lastCited(sort: Desc)])
  @@map("vault_files")
  @@schema("ops")
}

enum VaultFileType {
  POLICY SKILL SESSION DECISION PROFILE INTEGRATION EMPLOYEE_INDEX
  @@schema("ops")
}
```

### tRPC vault router

```typescript
vault.listFiles(tenantId, type?)       → VaultFile[]
vault.getFile(tenantId, path)          → { meta: VaultFile, content: string }
vault.updateFile(tenantId, path, md)   → void  (HR Lead editable files only)
vault.getGraph(tenantId)              → { nodes: GraphNode[], edges: GraphEdge[] }
vault.getSessions(tenantId, range)    → SessionSummary[]  (paginated by week)
vault.uploadHandbook(tenantId, file)  → { sections: string[], coverage: number }
vault.getTokenStats(tenantId)         → { avgTokens: number, reduction: number, savingsGbp: number }
```

### Token reduction tracking

Every agent invocation writes `avg-tokens` to the session log. The vault router `getTokenStats` queries D1 for:
- Average tokens per invocation this month
- Estimated tokens WITHOUT brain (full handbook size × invocation count)
- Calculated reduction factor
- Estimated cost savings (tokens × Anthropic pricing)

This becomes a live dashboard metric showing clients their ROI.

---

## Build Roadmap — 5 Phases

### Phase 1 — MarkItDown + vault foundation (1 session)
1. `services/markitdown/` — Dockerfile + FastAPI wrapper
2. Add to `observability/docker-compose.yml`
3. `src/brain/vault.ts` — KV read/write helpers
4. `src/brain/parser.ts` — handbook section splitter (heading-based + category detection)
5. Add VaultFile model to Prisma schema
6. Write the 14 skill `.md` files for all agents (one per agent)

**Exit criteria:** Upload a PDF → MarkItDown converts it → parser splits into sections → sections in KV → VaultFile rows in D1.

### Phase 2 — Agent integration (1 session)
1. `src/brain/skills.ts` — skill file loader (cached per Worker instance)
2. Modify `src/agents/claude.ts`: replace full handbook load with skill + policy retrieval
3. Modify `src/agents/tool-executor.ts`: write tool results to session log
4. Write session log on every invocation
5. Write decision record on every approval/rejection

**Exit criteria:** Agent invocation uses <5k tokens. Session log written after each call. Token reduction measurable in D1.

### Phase 3 — Dashboard Knowledge page (1 session)
1. `vault.ts` tRPC router
2. Rewrite `app/t/[slug]/knowledge/page.tsx` — three-panel layout
3. `file-tree.tsx` — folder tree with coverage indicators
4. `markdown-viewer.tsx` — renders md + clickable wikilinks + frontmatter sidebar
5. `upload-zone.tsx` — drag-and-drop PDF upload, calls MarkItDown, shows progress + sections parsed
6. Session timeline (static, paginated — SSE in Phase 4)

**Exit criteria:** HR Lead can upload a PDF, see it split into sections, click into each section, navigate wikilinks.

### Phase 4 — D3 Knowledge Graph (1 session)
1. Install `d3` in dashboard
2. `knowledge-graph.tsx` — force-directed graph from `vault.getGraph`
3. Node sizing by citation count
4. Pulse animation for files cited in last 24h
5. Filter pills (All / Policies / Sessions / Skills)
6. Search bar — highlights matching nodes
7. Click node → opens in markdown viewer
8. Wire SSE for live session timeline

**Exit criteria:** Graph renders all vault files. Wikilink edges visible. Nodes pulse when cited. Click opens file.

### Phase 5 — Token stats + polish (1 session)
1. `vault.getTokenStats` → token reduction metric on Overview KPI tile
2. Token cost visible per session in timeline
3. Coverage recommendations ("§7 Pay & Benefits is thin — consider expanding")
4. Vault export: download all files as `.zip` of markdown (GDPR data portability)
5. Handbook health report — section-by-section coverage bars

**Exit criteria:** HR Lead can see "Today you saved £X vs loading full context". Vault exportable.

---

## Environment Variables to Add

```bash
# Dashboard (.env.local)
MARKITDOWN_URL=http://localhost:8080   # or deployed service URL

# Worker (wrangler secret put)
# None needed — brain reads from KV which Worker already has access to
```

---

## What This Looks Like in Practice

**Day 1 (onboarding):**
1. HR Lead uploads `Elm_Row_Dental_HR_Handbook_2025.pdf`
2. MarkItDown converts → 48 pages → structured markdown
3. Parser detects 9 sections → creates 9 policy `.md` files
4. Graph appears: 9 emerald nodes floating in the canvas
5. Coverage bars: Leave 95% · Sick 90% · Grievance 85% · Pay 60% (flagged thin)

**Week 1:**
1. 28 employee queries handled
2. 28 session entries appended to `sessions/2026-04-25.md` etc.
3. 28 decision records in `decisions/`
4. Graph grows: session nodes appear (amber), decision nodes appear (sky)
5. Wikilinks form: `leave-holiday.md` has 18 edges (most cited)
6. `leave-holiday.md` node is now 3× bigger than `health-safety.md`

**Month 1:**
1. 247 queries handled
2. Average: 3,240 tokens/invocation (down from 48,000)
3. Token reduction: 14.8×
4. Estimated saving: £142 vs loading full context every time
5. The graph is a living map of what matters to this company

**The compound effect (Karpathy's insight):**
The vault gets smarter over time. Decision records show the agent which drafts get approved unchanged (copy that pattern). Session logs show which policy sections are cited most (those need better coverage). The `## Agent instructions` blocks can be tuned based on real approval data. Month 3 agents are materially better than Month 1 agents — on the same skill files — because the vault gives them better context about how this specific company thinks.

---

*All 5 decisions locked. Build starts Phase 1.*
