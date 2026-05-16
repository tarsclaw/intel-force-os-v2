# Agent Bundle Pattern Reference

**The structural template every agent in the suite follows.** If you're writing a new agent or understanding an existing one, read this first.

This pattern was derived from the Proposal Builder build. Every agent in Phase 2 conforms to it. Every future agent should.

---

## Why there's a pattern at all

Without structure, every new agent is a one-off. With structure:
- A new dev reads one agent bundle, then understands all of them.
- The Provisioning System can validate any agent bundle against a single schema.
- Quality gates, escalation handling, logging, telemetry — implemented once in shared helpers, reused everywhere.
- The dashboard renders any agent's config, activity, and escalations with a single code path.

The pattern is the product's internal operating system.

---

## The six files

Every agent bundle contains exactly these files in this structure:

```
{agent-name}/
├── README.md
├── agent.md
├── config.schema.json
├── tools.yaml
├── validate.sh
├── context.sh
└── tests/fixtures/01-primary/
    ├── input.json
    └── expected.md
```

---

## File 1 — `README.md`

**Purpose:** 2-minute overview for anyone landing on this agent. Not for Claude — for humans.

**Template:**

```markdown
# {{Agent Display Name}}

**Purpose:** {{one-sentence purpose}}.

**Trigger:** {{how it's invoked — webhook / cron / manual / chained}}.

**Output:** {{what gets produced}}.

**Tier availability:** {{which pricing tiers include it}}.

---

## What it does

{{2-3 paragraphs in plain language. What the agent produces. Who's the end user. How it fits the tenant's business.}}

## What it needs

{{bullet list of vault files it reads, integrations it uses, tenant config it requires}}

## What it doesn't do

{{explicit exclusions — what this agent is NOT responsible for}}

## Cost per run

{{rough token estimate + GBP — helps sales size deals correctly}}

## Related

{{links to related agents — e.g. Content Creator → Repurposer}}
```

---

## File 2 — `agent.md`

**Purpose:** the production prompt. This is where the thinking lives. Claude Code loads this as the system prompt for every session of this agent.

**Required sections in order:**

```markdown
---
name: {{kebab-case-name}}
description: {{one sentence — when to invoke, what it does, one scope constraint}}
model: sonnet | opus | haiku     # tier-appropriate
tools: {{list of allowed tools including MCP functions}}
permission_mode: acceptEdits | manualReview
version: 1.0.0
owner: intelforce-platform
last_reviewed: YYYY-MM-DD
---

# Role

{{2-3 paragraphs defining the agent's role, loyalty, and core constraint.}}

You work for {{client.name}}. Your loyalty is to their {{brand/voice/pricing/customers}}.
You draft — you never send. Every output routes through a human at {{client.name}} before it reaches the external recipient.

---

# Context

<!-- CONTEXT-START -->
{{populated by context.sh at SessionStart}}
## Client voice profile
{{voice_profile}}
## Other agent-specific context sections
...
<!-- CONTEXT-END -->

---

# Workflow

Numbered steps. No skipping. No combining. Each step has a clear output.

## Step 1 — {{name}}
{{what to do, how to do it, what "done" looks like}}

## Step 2 — {{name}}
...

## Step N — {{final delivery step}}

---

# Output Specification

The output MUST have these sections in this exact order:

### 1. {{section name}}
{{what goes here, length bounds, style notes, good/bad example}}

### 2. {{section name}}
...

---

# Quality Gates

Check every gate before saving. Any fail → revise. Revision limit N.

- [ ] Gate 1 — {{structural or semantic check}}
- [ ] Gate 2 — ...

---

# Escalation Conditions

Stop all work. Do NOT save output. Write escalation note. Notify {{slack}}.

1. **{{Condition name}}.** {{description}}. Code: `ESCALATION_CODE_NAME`.
2. ...

---

# Internal quality notes (not for the output)

Symptoms that you're going wrong — self-correct mid-flow:
- {{symptom → corrective action}}
- ...

---

# Versioning
1.0.0 — YYYY-MM-DD — initial release.
```

**Hard rules for agent.md:**
- Every workflow step must have an explicit output — no "consider" or "reflect" steps that produce nothing.
- Every quality gate must be either structurally checkable (length, presence of a section, regex match) or semantically checkable by LLM-as-judge.
- Every escalation condition has a stable `SCREAMING_SNAKE_CASE` code registered in `_shared/escalation-codes.md`.
- Output specification section count matches what `validate.sh` structurally checks.
- All client references use `{{client.name}}` templating. Zero hardcoded client data.

---

## File 3 — `config.schema.json`

**Purpose:** the Configuration Wizard's source of truth for what to collect per tenant for this agent.

**Required top-level shape:**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://intelforce.ai/schemas/agents/{agent-name}/v1.0.0.json",
  "title": "{{Agent Display Name}} — Tenant Configuration",
  "description": "{{one-line explanation}}",
  "type": "object",
  "required": [/* list top-level sections that must be present */],
  "additionalProperties": false,
  "properties": {
    "client":        { ... },
    "sales_lead":    { ... },
    "{{integration}}": { ... },
    "vault":         { ... },
    "notifications": { ... },
    "output":        { ... },
    "behaviour":     { ... }
  }
}
```

**Every config.schema.json includes:**
- `client` — identity (slug, name, industry, currency, timezone)
- Integration-specific sections matching what `tools.yaml` declares
- `notifications` — where escalations post
- `output` — output-shape controls (e.g. draft vs send, target stages)
- `behaviour` — tunable limits (revision_limit, retrieval_top_k, etc.) with sensible defaults

---

## File 4 — `tools.yaml`

**Purpose:** declares MCP server dependencies + scopes + fallback behaviour.

**Required structure:**

```yaml
agent: {{agent-name}}
version: 1.0.0

required:
  - name: {{integration}}
    purpose: "..."
    mcp_server:
      type: official | community | community-forked | build-your-own
      source: "..."
      version_pin: "..."
    auth:
      type: api_key | oauth2
      secret_ref: "secrets://{tenant_id}/{integration}/..."
    tools_used: [ mcp__x__y, ... ]
    scopes_required: [ "scope1", "scope2" ]
    degraded_mode:
      condition: "..."
      behaviour: "..."
      fallback_available: true | false

optional:
  - name: ...

preflight_checks:
  - name: ...
    description: "..."
    blocks_activation: true | false

telemetry:
  emit_events: [...]
  cost_budget_per_invocation: {...}
```

---

## File 5 — `validate.sh`

**Purpose:** PostToolUse hook. Runs after agent writes. Enforces structural quality gates. Feeds failures back into Claude's context for self-correction.

**Required structure:**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Pull in shared helpers
source /tenant/.claude/bin/hook-helpers.sh
hh_init

# Hook receives JSON on stdin from Claude Code
HOOK_INPUT=$(cat)
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

# Early exit if the write wasn't to a file this agent cares about
[[ ! "$FILE_PATH" =~ {{agent-specific-path-pattern}} ]] && exit 0

CONTENT=$(cat "$FILE_PATH")

# -- Agent-specific structural checks --
# (file path convention, frontmatter, required sections, etc.)

# -- Universal content checks (shared) --
hh_check_no_placeholders "$CONTENT"
hh_check_banned_phrases "$CONTENT"
hh_check_client_banned_phrases "$CONTENT"

# -- Agent-specific word count / structure --
hh_check_word_count "$CONTENT" {{min}} {{max}}

# Done
hh_report_and_exit
```

Keep agent-specific checks focused — structural only, not semantic. Semantic checks (voice match, fact-match-to-source, tonal appropriateness) happen via LLM-as-judge in v1.1, not in `validate.sh`.

---

## File 6 — `context.sh`

**Purpose:** SessionStart hook. Hydrates the CONTEXT block in `agent.md` with tenant-specific data before Claude reads it.

**Required structure:**

```bash
#!/usr/bin/env bash
set -euo pipefail

source /tenant/.claude/bin/hook-helpers.sh
hh_init

# -- Read trigger payload --
TRIGGER_FILE="${CLAUDE_TRIGGER_FILE:-}"
# (if not set, derive from most recent unprocessed file in relevant intake dir)

# -- Extract agent-specific trigger context --
# (e.g. for Proposal Builder: the Fathom call ID; for Lead Hunter: the ICP criteria snapshot)

# -- Load vault context files --
VOICE_PROFILE=$(cat /tenant/vault/brand/voice-profile.md)
# other vault files as needed

# -- Retrieve similar prior content via pgvector --
RETRIEVED=$(hh_retrieve "query text" "tag" 3 | hh_format_retrieved)

# -- Build the CONTEXT block --
CONTEXT_BLOCK=$(cat <<EOF
<!-- CONTEXT-START -->
## Voice profile
$VOICE_PROFILE

## {Other agent-specific sections}
...

<!-- CONTEXT-END -->
EOF
)

# -- Inject into agent.working.md --
awk -v ctx="$CONTEXT_BLOCK" '
  /<!-- CONTEXT-START -->/ { print ctx; in_ctx=1; next }
  /<!-- CONTEXT-END -->/ { in_ctx=0; next }
  !in_ctx { print }
' "$AGENT_MD" > "$WORKING_AGENT_MD"

hh_log "hydrate" "ok" "null"
```

---

## File 7 — `tests/fixtures/01-primary/`

**Purpose:** a canned input + golden output pair the agent can be validated against in isolation.

**`input.json` shape:** whatever the trigger payload looks like for this agent. For webhook-triggered agents, this is the webhook body. For cron-triggered agents, it's a synthetic `{"cron": true, "timestamp": "..."}`. For manual, it's the dashboard's invocation payload.

**`expected.md` shape:** the output the agent should produce. Not pixel-perfect — the fixture is for directional validation. Acceptable variance:
- Wording differences (don't grade on prose)
- Section ordering (must match)
- Key decisions (must match — tier recommended, escalation raised, scope items, etc.)

When an agent's behaviour changes intentionally (v1.0 → v1.1), the fixtures update with it. A PR that changes agent.md without updating fixtures fails code review.

---

## Shared behavioural rules every agent follows

### Always
- Use `{{client.name}}` templating — no client-specific prose hardcoded in `agent.md`
- Source voice from `/tenant/vault/brand/voice-profile.md`
- Source pricing from `/tenant/vault/brand/pricing.md` (where relevant)
- Source service catalogue from `/tenant/vault/brand/service-catalogue.md`
- Write outputs to `/tenant/vault/{appropriate-path}/` with YAML frontmatter
- Attribute outputs to the agent via frontmatter `drafted_by: {agent}@{version}`
- Emit structured telemetry events via `hh_log`
- Respect the tenant's `cost_budget` — back off if approaching hard stop

### Never
- Send anything externally without a human in the loop
- Invent facts, prices, dates, statistics, or case study outcomes
- Use language outside the voice profile or banned phrase list
- Write to another tenant's vault (impossible by filesystem scoping, but enforced in code anyway)
- Log secrets, API keys, OAuth tokens, or encrypted payloads
- Modify the source agent.md (only agent.working.md is session-scoped)

---

## When to break the pattern

Only when the pattern breaks you.

Specifically:
- **Voice Receptionist** runs on Vapi, not Claude Code. The bundle structure is different (Vapi flow JSON + post-call webhook handler instead of agent.md + hooks). It lives outside Phase 2.
- **Ad Manager** has a continuous optimisation loop that doesn't fit the one-shot session model. It's a persistent service, not a Claude Code agent. Also outside Phase 2.

Everything else — even experimental one-off agents — follows this pattern. If a new agent seems like it can't, the default assumption is the agent is ill-designed, not that the pattern is wrong. Defend deviations.

---

## Version history

- 1.0 (2026-04-22) — initial release based on Proposal Builder build lessons
