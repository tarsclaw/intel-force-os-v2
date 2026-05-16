# Escalation Codes Registry

Every agent that escalates uses a code from this registry. Codes are stable and appear in logs, Slack alerts, and the dashboard's Escalations view. Adding a new code is a PR that updates this file plus the agent's `agent.md`.

---

## Cross-agent codes

These can be raised by any agent.

| Code | Meaning |
|---|---|
| `FATAL_CONFIG_MISSING` | Tenant config missing or malformed. Container won't function. |
| `VAULT_READ_FAILED` | Vault filesystem unavailable. Nothing the agent can do. |
| `INTEGRATION_AUTH_FAILED` | OAuth token rejected; requires human re-auth via dashboard. |
| `RATE_LIMIT_EXHAUSTED` | External provider rate limit hit; automatic retry scheduled. |
| `COST_BUDGET_EXCEEDED` | Tenant's monthly cost budget reached; agent paused until reset. |
| `REVISION_LIMIT_EXCEEDED` | Quality gates failed on all allowed revision attempts. |
| `CONTENT_POLICY_VIOLATION` | Agent output tripped an LLM safety filter; human review required. |

---

## Proposal Builder (`phase-1-poc-stack/proposal-builder`)

| Code | Meaning |
|---|---|
| `INSUFFICIENT_SIGNAL` | Transcript too short to draft a proposal responsibly |
| `BUDGET_BELOW_MINIMUM` | Prospect's budget below client's minimum engagement |
| `HIGH_COMPETITIVE_INTENSITY` | Prospect evaluating 3+ competitors; needs human touch |
| `HIGH_VALUE_HUMAN_DRAFT` | Deal size ≥ threshold; partners draft all enterprise deals |
| `OUT_OF_STANDARD_SCOPE` | Prospect needs services not in client's catalogue |
| `BUYER_SKEPTICISM` | Transcript sentiment requires human judgment |
| `LANGUAGE_MISMATCH` | Non-English transcript; no translation attempted |
| `SUMMARY_CONTRADICTION` | Fathom summary contradicts transcript content |

---

## Lead Hunter

| Code | Meaning |
|---|---|
| `NO_RESULTS_FOUND` | ICP criteria too narrow; zero prospects matched |
| `DUPLICATE_SATURATION` | >80% of results already in CRM; criteria needs broadening |
| `DATA_PROVIDER_DEGRADED` | Companies House / Prospeo / Kaspr returning partial data |
| `ICP_CRITERIA_MISSING` | Tenant hasn't completed ICP definition in vault |
| `COMPLIANCE_WARNING` | Prospect industry triggers ICO/GDPR concern (finance/health) |

---

## Client Onboarder

| Code | Meaning |
|---|---|
| `SIGNED_PROPOSAL_MISSING` | Can't find signed proposal in vault to extract scope from |
| `SCOPE_CONTRACT_MISMATCH` | Signed contract differs materially from proposal |
| `CLIENT_DATA_INCOMPLETE` | Required onboarding data (logins, access, contacts) missing |
| `TIMELINE_IMPOSSIBLE` | Signed timeline impossible from today's date |

---

## Content Creator

| Code | Meaning |
|---|---|
| `BRIEF_TOO_AMBIGUOUS` | Topic brief lacks enough specificity to write well |
| `SOURCES_INSUFFICIENT` | Couldn't find enough authoritative sources to cite |
| `CONTROVERSIAL_TOPIC` | Topic in domain requiring human editorial judgment |
| `VOICE_MATCH_FAILED` | Voice-match failed after max revisions |
| `FACT_CONTRADICTION` | Sources contradict each other; human must adjudicate |

---

## Repurposer

| Code | Meaning |
|---|---|
| `LONGFORM_TOO_THIN` | Source long-form under 600 words; not enough to atomise |
| `PLATFORM_VOICE_MISMATCH` | Client's brand voice doesn't transfer to target platform |
| `SOURCE_PIECE_NOT_FOUND` | Referenced long-form piece missing from vault |

---

## Caption Writer

| Code | Meaning |
|---|---|
| `ASSET_UNREADABLE` | Image/video analysis failed |
| `ASSET_OFF_BRAND` | Content inappropriate for client's brand |
| `NSFW_CONTENT` | Content flagged by safety filter |
| `CONTEXT_MISSING` | Asset needs accompanying context to caption meaningfully |

---

## Follow-Up Pilot

| Code | Meaning |
|---|---|
| `PROSPECT_OPTED_OUT` | Unsubscribe/opt-out detected in prior conversation |
| `CONVERSATION_ENDED_BADLY` | Prior exchange ended with hostility or formal rejection |
| `STALE_BEYOND_RECOVERY` | >90 days since any contact; lead should be archived, not nurtured |
| `MISSING_RELATIONSHIP_SIGNAL` | No prior substantive exchange to reference |

---

## Reporting Engine

| Code | Meaning |
|---|---|
| `DATA_SOURCE_UNAVAILABLE` | Required integration (GA4, HubSpot, Stripe) down or unauthorised |
| `KPI_UNDERPERFORMANCE` | Client's headline KPIs below target; human must explain |
| `RETENTION_CONTEXT_MISSING` | Client has been on board < 30 days; insufficient data for monthly report |
| `DATA_GAP_DETECTED` | Significant missing data periods; can't produce comparable month |

---

## SOP Writer

| Code | Meaning |
|---|---|
| `PROCESS_TOO_AMBIGUOUS` | Request too vague to extract a process from |
| `CONFIDENTIAL_DEPENDENCIES` | SOP references individuals by name who flagged confidentiality |
| `CROSS_FUNCTIONAL_DEPENDENCY` | SOP requires sign-off from people outside the requester's scope |

---

## Librarian

| Code | Meaning |
|---|---|
| `INDEX_CORRUPTION` | pgvector index reports inconsistency |
| `DISK_SPACE_LOW` | Vault disk usage > 90% of plan allowance |
| `EMBEDDING_PROVIDER_DOWN` | Cohere API unreachable; indexing paused |
| `TAG_CONSISTENCY_BROKEN` | Major tag taxonomy drift detected |

---

## Adding new codes

When adding a new escalation code:

1. Choose a `SCREAMING_SNAKE_CASE` code that's self-explanatory.
2. Add it to the correct agent section above.
3. Update the agent's `agent.md` §Escalation Conditions.
4. Update the agent's `validate.sh` or workflow to raise it.
5. Update the dashboard's Escalations view renderer so the code has a human-readable label and suggested action.

---

## How escalations surface

1. Agent calls `hh_escalate CODE "why" "saw" "recommend" slug` (from `hook-helpers.sh`)
2. An escalation note file lands in `/tenant/outbox/escalations/{YYYY-MM-DD}-{slug}-{agent}.md`
3. The escalation-notifier sidecar watches this directory, posts to the tenant's Slack escalations channel
4. Dashboard displays the escalation in the Operations Control view with "Resolve" button
5. On resolution, the file is moved to `/tenant/outbox/escalations/resolved/` and the dashboard entry closes
