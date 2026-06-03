# /goal — Week 5 execution plan: Bullhorn-independent scaffold sweep + Janitor build prep

**Status:** Active (start Day 28; 7-day execution window through end-of-Week-5 ~2026-06-09).
**Type:** Multi-day execution plan (referenced throughout Week 5; per-phase atomic commits; no single autonomous-marathon goal).
**Authored:** 2026-06-02 (W4 close evening).
**Master plan citations:** Master brief §8.2 line 596 (Janitor = W5; key dependency Bullhorn MCP R+W) + ULTRAPLAN §8.1 A2 (Janitor spec) + master brief §5.3 line 401 (WorkOS AuthKit is the v1.0 auth substrate; "don't add a second auth system") + ADR-005 (W3 Diagnostic acceleration → builds non-Bullhorn first when Bullhorn is slow) + `docs/decisions/bullhorn-integration-path.md` Sub-decision A RESOLVED 2026-06-02 (direct API per-tenant OAuth = v1.0 path; marketplace deferred to v1.1+).
**Strategic premise:** Bullhorn commercial gate is slow. Build everything that DOESN'T need a live Bullhorn account first; live integration tests gated on Bullhorn dev-support reply land later when the reply arrives (~2026-06-09 per founder dev-support submission 2026-06-02).
**Quality bar:** Same as W3 polish — each artefact production-quality; cite all master-brief/ULTRAPLAN line anchors; SKELETON discipline (TODO(W-X) markers where live impl waits on a gate).
**Maps to:** Day-28 (2026-06-03) → Day-34 (2026-06-09). 7-day window.
**Builds on:** `docs/operations/goal-week-3-polish-and-scaffold.md` (5 agent.md scaffolds + Diagnostic polish) + `docs/operations/goal-w4-day-26-2026-06-01.md` + W4 polish goal (commits `f13cc15` → `e0d4520`).

---

## §0 — Mandatory reading order

Before writing any code, the executor reads these in order and confirms each in chat:

1. **`CLAUDE.md`** at repo root — instance scoping + five rules + four boundaries + Karpathy per-edit discipline
2. **`.agents/current-priorities.md`** header + action board + W4 close section
3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (four boundaries) + §5.3 (`_shared/` substrate; **WorkOS AuthKit at line 401**) + §6 (Day 7 single-sentence test) + §8.2 (build sequence — Janitor at line 596) + §10.5 (always-ratify artefacts)
4. **`docs/specs/ULTRAPLAN.md`** §8.1 A2 (Janitor; lines 507-514) + A3 (Scribe; lines 518-527) + A5 (Sourcing Scout; lines 547-558) + §9 (Bullhorn critical path)
5. **`docs/specs/PRODUCT-SPEC.md`** §0-§4 + §5.3 (shared schemas)
6. **`docs/decisions/sequencing-target.md`** §3.1 (build waves) + §4.1 (Diagnostic-first rationale)
7. **`docs/decisions/v1.0-kill-criterion.md`** §2 Triggers 1 + 3 (LOI deadline + JANITOR-BULLHORN-AUTH-W5)
8. **`docs/decisions/bullhorn-integration-path.md`** in full (Sub-decision A RESOLVED 2026-06-02 row at top; §4 per-agent Bullhorn surface; §1.4 fallback architecture)
9. **`docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md`** (cluster Fbis + G partial-ratification framework — Janitor + Scribe + Sourcing Scout bundles will land at the same partial-ratification shape; no expectation of Codex round-N clean ratification at the bundle layer)
10. **`agents/recruitment/cash-conductor/`** in full (the gold-standard bundle pattern to mirror: agent.md + cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures with TODO(W7-8) markers throughout)
11. **`agents/recruitment/concierge/`** in full (second bundle precedent; same pattern with TODO(W10-13) markers)
12. **`agents/recruitment/janitor/agent.md`** + **`agents/recruitment/scribe/agent.md`** + **`agents/recruitment/sourcing-scout/agent.md`** (contract-layer specs that the W5 bundles implement against — all RATIFIED at cluster E 2026-05-31)
13. **`agents/_shared/escalation-codes.md`** + **`agents/_shared/autosend-policy.yaml`** + **`agents/_shared/hook-helpers.sh`** (substrate the bundles plug into; same shape as CC + Concierge)
14. **`packages/mcp-connectors/xero/`** in full (the gold-standard MCP connector pattern to mirror for `@ifos/bullhorn` scaffolding — package.json + tsup.config.ts + tsconfig.json + vitest.config.ts + src/{auth,client,errors,types,cache,rate-limit,index}.ts + tests/{scaffold,auth,rate-limit,capabilities}.test.ts)
15. **`docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml`** §4 (tenant_adapters.config allowlist — current 11 keys; W5 adds 3 more via v0.4 supplement work)
16. **`docs/runbooks/day-4-provisioning.md`** §6.5 (`_secrets.env` skeleton pattern — for credential bootstrap reference; founder action items)

After reading: post in chat **"Read order complete. Five rules: [list verbatim]. Four boundaries: [list verbatim]. Janitor build dependency per master brief §8.2 line 596: Bullhorn MCP (R+W). ULTRAPLAN A2 build complexity: L (2 weeks; 1 week MCP + 1 week agent). Bullhorn Sub-decision A status: RESOLVED 2026-06-02 (direct API per-tenant OAuth = v1.0). WorkOS AuthKit per master brief §5.3 line 401 is the v1.0 auth substrate. Ready to begin Phase 1."**

---

## §1 — Success state (what "done" looks like at end of Day 34 / Week-5 close)

When this plan completes, the following are ALL TRUE:

### A — Bullhorn-independent MCP scaffolds (Days 28-29)

1. **`packages/mcp-connectors/bullhorn/`** SKELETON shipped. Mirror `@ifos/xero` pattern. ~20-25 vitest fixture-first; ESM build; tsup + vitest config. OAuth 2.0 (two-step auth-code flow per `bullhorn.github.io/docs`); REST API client with rate-limit budget (per-tenant_id; Bullhorn's published 10/sec / per-day caps); typed error hierarchy (BullhornAuthError, BullhornRateLimitError, etc.); concurrent-refresh-safe token rotation; live-test deferred per the honest-signal pattern established for OB (no `MCP_LIVE_TESTS` block; README "Live tests deferred to first commercial Bullhorn signup"). Status: Proposed.
2. **`packages/mcp-connectors/workos/`** SKELETON shipped. Mirror same pattern. Smaller scope: org + connection + directory_sync read endpoints; WorkOS-SDK-compatible signatures; rate-limit budget (per-tenant). Status: Proposed.
3. **`packages/mcp-connectors/granola/`** SKELETON shipped (vendor pivoted Fathom/Fireflies → Granola per founder 2026-06-03; sits in the background during calls without an extra meeting attendee + has an official MCP server at `mcp.granola.ai/mcp`). Wraps the 6 official Granola MCP tools (`list_meetings` + `get_meetings` + `query_granola_meetings` all-plans + `list_meeting_folders` + `get_meeting_transcript` Paid-only + `get_account_info` all-plans) with IFOS rate-limit, plan-tier guard, OAuth 2.1 PKCE token persistence, typed errors. Plan tiers per Granola docs are `free` | `paid` (not `basic|business|enterprise`); founder confirmed Business+/Paid 2026-06-03 so Paid-only tools unlocked-by-default. Status: Proposed.

### B — v0.4 schema supplement (Days 29-30)

4. **`docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml`** + **`docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql`** drafted. Adds the following keys to `tenant_adapters.config` allowlist (validator trigger extended): `operator_telegram_chat_id` (D1-B per Concierge cycle.sh Step 11), `email_channel` (Concierge per-tenant MS Graph vs Gmail selection), `workos_org_id` (tenant SSO org ID per master brief §5.3 line 401), `granola_workspace_id` (per-tenant Granola workspace for W6+ Scribe; SUBSTITUTED for `workos_directory_id` per Day-29 Granola vendor pivot — SCIM `workos_directory_id` deferred to v1.1+ supplement when SCIM write-back is in scope), `bullhorn_corporation_id` (per-tenant Bullhorn account identifier). Migration is forward + backward (UP creates `validate_tenant_adapters_config_v0_4` function with 16-key allowlist + per-key validators, rebinds the trigger, drops the v0.3 function; DOWN restores the v0.3 trigger + function verbatim; both atomic + idempotent). Status: Proposed.

### C — 3 remaining v1.0 agent bundles scaffolded (Days 30-33)

5. **`agents/recruitment/janitor/`** full bundle scaffolded mirroring CC + Concierge pattern. cycle.sh (n-step orchestration per agent.md §4) + validate.sh (Gate A G1-G5 per agent.md §5; dedup confidence ≥0.85 + no-merge-on-recent-activity + others) + context.sh (tenant auth refresh + Bullhorn client + corporation_id resolution) + cleanup.sh (transient cache purge) + tools.yaml (Bullhorn R+W capabilities + companies-house enrichment + ESC mapping in failure_modes per cluster Fbis pattern) + 3 fixtures (01-primary happy-path dedup merge, 02-edge-case-fuzzy-match conflict, 99-recent-activity-blocked adversarial). TODO(W5-6) markers throughout — agent.md is the CONTRACT, code is SCAFFOLD per the Reading-discipline note pattern established in CC + Concierge.
6. **`agents/recruitment/scribe/`** full bundle scaffolded same pattern. cycle.sh per agent.md §4 (polling-driven from Granola — Granola does NOT publish a webhook surface; 5-min cron polls `list_meetings_by_date_range` per tenant per @ifos/granola README §Scribe consumption pattern; transcript ingest → entity extraction → Bullhorn note write); validate.sh Gate A per §5; tools.yaml Bullhorn-write + @ifos/granola read capabilities (3 meeting tools + transcript tool with Paid-plan guard); 3 fixtures.
7. **`agents/recruitment/sourcing-scout/`** full bundle scaffolded. cycle.sh per agent.md §4 (3 active sources at v1.0 per 2026-06-02 Proxycurl caveat); validate.sh Gate A; tools.yaml Bullhorn-passive-match + Reed + CV-Library; 3 fixtures. LinkedIn Step 4 is NO-OP per the v1.0 caveat.

### D — Quality gates + state hygiene (Day 34)

8. All bundles shellcheck CLEAN; all YAML parses; 0 boundary violations.
9. `scripts/run-tenancy-audit.sh` re-run by founder after v0.4 supplement lands (validates the new allowlist trigger).
10. `.agents/current-priorities.md` W5 CLOSED state with deliverables enumerated.
11. `docs/operations/decision-log.md` appended with W5 strategic decisions.
12. `docs/RISK-REGISTER.md` updated if anything new surfaced.
13. **Cluster F-tris ratification manifest entry** added — Janitor + Scribe + Sourcing Scout agent-bundles + Bullhorn MCP + WorkOS MCP + v0.4 supplement + Granola MCP (vendor pivoted from Fathom/Fireflies 2026-06-03). Founder triggers when ready (expected partial-ratification outcome per Fbis + G precedent; same disagreement-doc framework applies if rounds blow out).

### E — Founder-side gates carried to W6 (not blocking W5 scaffolding)

- Bullhorn dev-support reply → enables live integration tests + Sub-decision B RESOLVED row in bullhorn-integration-path.md
- Granola Business+/Paid workspace + browser-based OAuth 2.1 PKCE consent (per workspace) → enables live transcript tests for @ifos/granola (founder confirmed tier 2026-06-03; browser consent dance still pending for the test workspace)
- Reed + CV-Library commercial signups → enables live Sourcing Scout tests
- WorkOS account setup → enables live SSO tests
- Q1 LOI with Jack → enables pilot data flow (Trigger 1 fires 2026-06-03 without it)

---

## §2 — Day-by-day phases

Each phase is per-artefact atomic commits + commits referenceable from this doc.

### Phase 1 — Day 28 (2026-06-03): @ifos/bullhorn MCP scaffold

**Reading prep:** §0 items 1-3, 8, 14. State the Bullhorn OAuth pattern back to founder before writing code.

**Build:**
- `packages/mcp-connectors/bullhorn/` directory structure mirroring `@ifos/xero` (package.json + tsup.config.ts + tsconfig.json + vitest.config.ts + src/{auth,client,errors,types,cache,rate-limit,index}.ts + tests/{scaffold,auth,rate-limit,capabilities}.test.ts)
- OAuth implementation per Bullhorn docs: two-step (REST login URL + REST token URL); per-corporation_id; refresh_token rotation; atomic file-write per the xero pattern
- Rate-limit per published Bullhorn caps (typically 10/sec per corporation + per-endpoint quotas); soft 80% / hard 100% bucket; per-(corporation_id, endpoint) isolation
- Typed errors: BullhornError → {BullhornAuthError, BullhornRateLimitError, BullhornNotFoundError, BullhornValidationError}
- Capabilities: getCandidate, listCandidates, updateCandidate, getPlacement, getClient, getContact, createNote, createActivityLogEntry, refreshTokens (matches Janitor + Scribe + Concierge agent.md tools.yaml refs)
- Fixture-first tests: scaffold (5; public surface), auth (7; load/round-trip/shouldRefresh/refresh-success/401-no-leak/concurrent-dedup/refresh-token-rotation), rate-limit (5; soft/hard/per-corporation isolation), capabilities (6+; happy + error path per capability per `review-mcp-connector.md` §6)
- README ≥120 lines per `@ifos/xero` template; explicit "Live tests deferred to first commercial Bullhorn signup" per honest-signal pattern from cluster F OB R3 closure
- Boundary scan: no Composio/AgentMail; no cortextOS submodule imports

**Commits (atomic per file group):**
- `feat(mcp/bullhorn): scaffold @ifos/bullhorn MCP connector — OAuth + REST + rate-limit + typed errors`
- (single commit; package is self-contained)

**Gate to next phase:** package builds clean (`pnpm typecheck && pnpm test && pnpm build`); 20+ vitest pass; 0 boundary violations.

### Phase 2 — Day 28 evening / Day 29 morning: @ifos/workos MCP scaffold

**Reading prep:** master brief §5.3 line 401 + WorkOS public docs at `workos.com/docs` (verify live; founder confirms WorkOS is their existing identity provider).

**Build:**
- `packages/mcp-connectors/workos/` mirror same pattern as @ifos/bullhorn (smaller scope)
- OAuth-bearer client (WorkOS uses simple bearer auth with secret key; no per-tenant token rotation needed — IFOS holds a single secret + scopes by org_id)
- Capabilities: getOrganization, getConnection, listDirectoryUsers, listDirectoryGroups, refreshSession (the SSO-relevant subset for v1.0; provisioning + audit-log capabilities deferred to v1.1+)
- Rate-limit budget: WorkOS's published caps (typically 100 RPS); per-org_id bucket
- 15+ vitest fixture-first; same shape
- README per pattern; live-test deferred to founder WorkOS account confirmation

**Commit:** `feat(mcp/workos): scaffold @ifos/workos MCP connector — WorkOS AuthKit per master brief §5.3 line 401`

### Phase 3 — Day 29: Granola MCP wrapper scaffold (vendor pivot landed)

**Vendor pivot:** original plan called for Fathom OR Fireflies; founder pivoted to **Granola** on 2026-06-03 — sits in the background during calls without an extra meeting attendee, has an official MCP server at `mcp.granola.ai/mcp` (no first-party MCP client wiring needed; just wrap their 6 tools with IFOS-tier rate-limit + plan-tier guard + audit). The original `packages/mcp-connectors/{fathom,fireflies}/` paths are NOT being built; the actual artefact is `packages/mcp-connectors/granola/`.

**Founder gate (resolved 2026-06-03):** Granola plan tier confirmed Business+/Paid. The two Paid-only tools (`list_meeting_folders`, `get_meeting_transcript`) are unlocked-by-default; tenant provisioning pre-caches `plan_tier='paid'` in the `GranolaClient` via `get_account_info()` so the per-call Paid-plan guard short-circuits before any wire round-trip.

**Build (shipped Day-29; commit `1b657e6`):** wrapper around the official Granola MCP server. 11 src + 4 test files + README. OAuth 2.1 + PKCE + Dynamic Client Registration; per-`workspace_id` token persistence (atomic file write); per-`workspace_id` rate-limit (60/min hard, 48/min soft); transport abstraction (`GranolaTransport` interface lets tests inject fakes; live `@modelcontextprotocol/sdk` `StreamableHTTPClientTransport` wiring is W5-live work at first commercial signup). 6 capability functions grouped into 4 source files (meetings + folders + transcripts + account) mirroring the official MCP tools. Error hierarchy adds `GranolaPlanTierInsufficientError` (carries `required_tier` + `capability` metadata; pre-emptive guard via `PAID_PLAN_TOOLS` set OR upstream 403 surface). 33/33 vitest pass; tsup ESM build 22.06KB + DTS 17.88KB.

**Commit landed:** `feat(mcp/granola): scaffold @ifos/granola wrapper — IFOS-tier over mcp.granola.ai/mcp for Scribe W6`

### Phase 4 — Day 30: v0.4 schema supplement + migration

**Build:**
- `docs/verticals/recruitment/vertical-schema.v0.4-supplement.yaml` — new declarations for 5 new tenant_adapters.config keys (operator_telegram_chat_id, email_channel, workos_org_id, **granola_workspace_id** [substituted for original `workos_directory_id` per Day-29 Granola vendor pivot; SCIM `workos_directory_id` deferred to v1.1+ supplement], bullhorn_corporation_id) per Phase 1 + 2 + 3 + W4 D1-B Path-A reference
- `docs/verticals/recruitment/migrations/v0.3-to-v0.4.sql` — ALTER FUNCTION renames + new allowlist entries + new type-validators per key; forward + backward symmetric; idempotent
- Update `agents/recruitment/concierge/context.sh` TODO(W10-13) markers — flip from "v0.4 supplement required" to "v0.4 supplement landed; SELECT enabled at W10-13"
- Update `docs/decisions/2026-05-31-d1-founder-decision.md` implementation-surface item 5 — Path A or Path B choice now testable; Path A confirmed (reuse approval_routing + add operator_telegram_chat_id as top-level for clarity)
- Update `.agents/current-priorities.md` to reflect v0.4 supplement landed

**Commits:**
- `feat(schema): v0.4-supplement + migration — 5 new tenant_adapters.config keys for D1-B + WorkOS + Bullhorn`
- `fix(concierge/context.sh): flip v0.4 TODOs from supplement-pending to supplement-landed`
- `fix(d1-b): Path A confirmed (reuse approval_routing) + Path B (top-level key) both supported per v0.4 landed`
- `state(w5-d30): v0.4 supplement landed; SSO + bridge + Bullhorn config paths schema-clean`

**Founder gate:** founder runs `bash scripts/run-tenancy-audit.sh` after v0.4 lands to verify the new allowlist trigger doesn't break T1-T12.

### Phase 5 — Days 31-32: Janitor + Scribe full bundles

**Janitor bundle (Day 31):** mirror Cash Conductor + Concierge pattern atomic-per-file:
- `cycle.sh` (n-step per agent.md §4; nightly cron 02:00 UTC; mode=full-cleanup OR mode=incremental)
- `validate.sh` (Gate A G1-G5 per agent.md §5; dedup confidence ≥0.85; no-merge on 90-day activity)
- `context.sh` (Bullhorn auth refresh + corporation_id resolution + dedup confidence threshold env)
- `cleanup.sh` (transient cache purge; green-tier `janitor_cleanup` audit row)
- `tools.yaml` (Bullhorn R+W capabilities + companies-house enrichment + ESC mapping in failure_modes per cluster Fbis pattern)
- 3 fixtures: `01-primary.yaml` (dedup happy-path; high-confidence merge), `02-edge-case-fuzzy-match.yaml` (multi-candidate dedup; manual review queue), `99-recent-activity-blocked.yaml` (adversarial — candidate with activity in last 90 days; ESC_JANITOR_RECENT_ACTIVITY_BLOCKED)
- 5 atomic commits per file; Reading-discipline note added to agent.md per CC + Concierge pattern

**Scribe bundle (Day 32):** same pattern. Polling-driven from Granola (5-min cron `list_meetings_by_date_range` per @ifos/granola README §Scribe consumption pattern — Granola does NOT publish webhooks); tools.yaml capabilities for Bullhorn-write + @ifos/granola read (3 meeting tools + transcript with Paid-plan guard) + voice-classifier. 3 fixtures.

**Commits per bundle: 5 atomic** (one per file group); total ~10 commits across Phases 5.

### Phase 6 — Day 33: Sourcing Scout bundle

Same pattern. cycle.sh per agent.md §4 with v1.0 caveat applied (Step 4 LinkedIn = NO-OP); tools.yaml Bullhorn-passive-match + Reed + CV-Library capabilities; 3 fixtures including the v1.1+-deferred LinkedIn handling. 5 atomic commits.

### Phase 7 — Day 34: Quality gates + state hygiene + cluster F-tris manifest

- Run full smoke (tenancy + tests + shellcheck + YAML + boundary) per W4 polish Phase 2 pattern
- Update `.agents/current-priorities.md` to W5 CLOSED state
- Append `docs/operations/decision-log.md` Day-34 entry
- Update `docs/RISK-REGISTER.md` if anything new
- Add cluster F-tris entry to `scripts/run-codex-ratification.sh` (Janitor + Scribe + Sourcing Scout agent-bundles + 3 new MCP packages + v0.4 supplement)
- Print W5 close report + recommended W6 /goal shape

**Commits: 2-3 atomic.**

---

## §3 — Phase budgets + stop conditions

| Phase | Day | Budget | Soft-stop trigger | Hard-stop trigger |
|---|---|---|---|---|
| 1 (Bullhorn MCP) | 28 | 4h | tests fail after 1 round of fixes | typecheck won't pass after 2 rounds — back off + ask founder |
| 2 (WorkOS MCP) | 28-29 | 2h | WorkOS public docs ambiguous on a capability | mark capability as v1.1+ stub and defer |
| 3 (Granola MCP) | 29 | 2h | Granola docs ambiguous on PKCE endpoint URL | hold TODO(W5-live) marker + scaffold against placeholder default |
| 4 (v0.4 supplement) | 30 | 4h | migration SQL won't validate locally | back off + ask founder for review before continuing |
| 5 (Janitor + Scribe bundles) | 31-32 | 8h total | shellcheck fails after 1 round of fixes per file | mirror exact pattern from CC bundle instead of inventing |
| 6 (Sourcing Scout bundle) | 33 | 4h | tools.yaml grew beyond CC + Concierge size | pause + verify against agent.md §3 contract |
| 7 (Close) | 34 | 2h | smoke fails on a previously-green test | STOP — surface + joint diagnosis with founder |

**Universal stop conditions (apply to every phase):**
- Boundary violation (Composio/AgentMail in agent.md / tools.yaml / fixtures) → STOP, surface, do not auto-fix
- Schema-before-code violation (consumer code attempts unallowlisted tenant_adapters.config key read) → STOP, surface
- Founder-gated work (live API call, commercial signup, production credential) → flag-and-continue with scaffold; defer live work
- Codex ratification round attempted in this plan → NOT ALLOWED. Ratification runs are deferred to Phase 7 cluster F-tris manifest entry + founder-triggered execution. **No agent.md edits during this plan that aren't structural-fix-driven** (don't accumulate Codex churn we already paid the price for in cluster Fbis + G).

---

## §4 — Founder gates explicit

Single-point-of-failure gates that block specific phases:

| Gate | Blocks | Path A discipline |
|---|---|---|
| Founder confirms Granola plan tier (RESOLVED 2026-06-03: Business+/Paid) | Phase 3 — RESOLVED | Founder confirmed Business OR Enterprise; not Free; encoded in v0.4 supplement §0 notes |
| Bullhorn dev-support reply | LIVE integration tests for @ifos/bullhorn (NOT scaffold) | Founder forwards reply when received |
| WorkOS account confirmation | LIVE @ifos/workos tests (NOT scaffold) | Founder confirms "WorkOS account is X" |
| ifos_app Postgres password | Tenancy audit run | Founder runs `bash scripts/run-tenancy-audit.sh` locally; types password at prompt |
| v0.4 migration run against live VPS | Schema active in production tenant | Founder runs migration after my SQL draft + review; uses `run-v0.4-migration-as-postgres.sh` wrapper (analog to v0.3 wrapper landed 2026-05-31) |
| Q1 LOI with Jack | Trigger 1 (2026-06-03 PAUSE) | Founder closes the LOI conversation directly |

None of these block the SCAFFOLDING phases of this plan. All gates are about LIVE deployment readiness, not the SKELETON layer.

---

## §5 — Cluster F-tris ratification expectation

Per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` precedent: expect **partial-ratification with disagreement docs** at the bundle layer for Janitor + Scribe + Sourcing Scout. The pattern:
- Contract layer (agent.md content) already RATIFIED at W3 cluster E (2026-05-31) for all 3 agents
- Bundle layer (cycle.sh + sibling files) ratifies via cluster F-tris ≤2 rounds; if more rounds needed → partial-ratification per Fbis + G precedent
- MCP connectors (@ifos/bullhorn + @ifos/workos + @ifos/granola) ratify via review-mcp-connector skill; expect 1-2 rounds plus possible counter-arguments (same shape as cluster F closure)
- v0.4 supplement ratifies via review-schema-change skill; expect clean ratification given it's additive-only

**Do NOT iterate Codex rounds during W5 itself.** Run ONCE at Phase 7; accept partial-ratification if 2 rounds blow out; document via disagreement docs per Fbis + G template. Hard-stop discipline preserves W5 momentum.

---

## §6 — Companion: deferred to W6+

Things explicitly OUT OF SCOPE for W5 but named for traceability:

- **Concierge production wiring** (real Telegram Bot API + postgres approvals reader) — W10-13 build slice per Concierge agent.md §10
- **Cash Conductor production wiring** (live Xero/QB/OB calls; live invoice/payment writes) — W7-8 build slice per CC agent.md §10
- **LinkedIn vendor selection for Sourcing Scout v1.1+** — W8-9 decision per `docs/decisions/codex-disagreement-2026-06-02-fbis-g-scaffold-runtime-drift.md` Risk 14
- **Concierge bundle completion** — already done per W4 Day-26 evening close
- **Janitor + Scribe + Sourcing Scout LIVE deployment** — W7+ once Bullhorn dev-support reply + commercial signups land
- **WorkOS SSO live integration** — W6+ once tenant onboarding workflow needs admin auth
- **Brain UI (rich-panel approval surface)** — v1.1+ per ADR-007 + brain-ui-scope.md

---

## §7 — Reading-discipline carryover

Every bundle scaffold lands with the Reading-discipline note pattern established in CC + Concierge (commits `8cc0491` + `d46474c`). The note explicitly frames agent.md as the CONTRACT vs SKELETON runtime + lists actual hh_decision_* emissions in the SCAFFOLD cycle.sh. This pre-emptively closes the scaffold-vs-runtime-drift Codex finding that drove cluster Fbis to partial-ratification.

---

*End of W5 execution plan. Refresh `.agents/current-priorities.md` header at each phase close. This document is the source of truth; deviations require an entry in `docs/operations/decision-log.md`.*
