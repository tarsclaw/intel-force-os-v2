# /goal — Week 4 Track 1: Cash Conductor MCP connectors + Diagnostic live polish

**Status:** Authored 2026-05-31 (Day 25 / W4 Day-2); ready for execution.
**Type:** Goal prompt (paste into Claude Code at session start; executor runs to completion across W4 Days 3-7, target 2026-06-01 → 2026-06-05).
**Master plan citations:** Master brief §8.2 (build wave W4 Cash Conductor MCP connectors) + ULTRAPLAN §8.1 A4 (Cash Conductor spec lines 531-545) + ADR-005 (Week-3 acceleration → Cash Conductor pulled forward to W4 substrate) + `agents/recruitment/cash-conductor/agent.md` §8 build dependencies + `docs/decisions/2026-05-31-d1-founder-decision.md` (D1-B resolved) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic live render by 2026-06-14).
**Quality bar:** Production-quality. Each MCP connector parallels `@ifos/companies-house` pattern (Day-13 ratified); fixture-first tests; OAuth scaffolds where applicable; explicit rate-limit + token-rotation handling. Each agent.md citation verified against source before commit. No speculative content.
**Builds on:** Week-3 close (`docs/operations/goal-week-3-polish-and-scaffold.md`; 8/9 Codex-RATIFIED + 1 fix-applied at commit `fbcb61e`); D1-B decision (`docs/decisions/2026-05-31-d1-founder-decision.md`).

---

## §0 — Mandatory reading order

Before writing any code, the executor reads these in order and confirms each in chat:

1. **`CLAUDE.md`** at repo root — instance scoping + five rules + four boundaries + per-edit coding-discipline section
2. **`.agents/current-priorities.md`** Open + Day-25 sections (this goal opens W4 Track 1)
3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §8.2 W4-W7 rows + §10 (ratification cadence + always-ratify list) + §10.5
4. **`docs/specs/ULTRAPLAN.md`** §8.1 A4 lines 531-545 (Cash Conductor spec) + §10 risk rows referencing Open Banking 90-day token rotation
5. **`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`** (Cash Conductor pull-forward authorisation)
6. **`docs/decisions/2026-05-31-d1-founder-decision.md`** (D1-B Telegram shim — affects Cash Conductor `xero_reminder_send_customer` flow)
7. **`agents/recruitment/cash-conductor/agent.md`** in full (the output contract; §4 workflow shows the 14 steps Cash Conductor needs the connectors to fulfil)
8. **`agents/recruitment/diagnostic/agent.md`** §1 + §5 + §8 (Diagnostic live-smoke target state; §8 lists the production-readiness dependencies)
9. **`packages/mcp-connectors/companies-house/`** in full — the canonical reference implementation. Every new MCP connector follows this pattern (TypeScript + vitest + disk cache + rate-limit budget + `tools.yaml` capability declaration).
10. **`packages/utilities/web-scraper/`** + **`packages/diagnostic-generator/`** — for the pattern of integration with `cycle.sh` and `_shared/hook-helpers.sh`.
11. **`docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml`** — `cash_conductor_transactions` + `cash_conductor_invoices` table schemas the connectors populate.
12. **`docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql`** §2 + §3 + §3.5 — the actual table definitions including `updated_at` columns the connectors must respect on writes.
13. **`agents/_shared/autosend-policy.yaml`** — `xero_reminder_draft_internal` (line 188), `xero_reminder_send_customer` (line 263), `accounting_reconciliation_write`.
14. **`agents/_shared/escalation-codes.md`** — `ESC_ACCOUNTING_AUTH`, `ESC_ACCOUNTING_WRITE_FAIL`, `ESC_OPEN_BANKING_AUTH`, `ESC_OPEN_BANKING_TOKEN_AGING`, `ESC_RECONCILIATION_AMBIGUOUS`, `ESC_AUTOSEND_RACE`.
15. **`.codex/ratification/SKILL.md`** + the four type skills (architecture-decision, schema-change, postgres-migration, agent-bundle) — for the ratification step.

After reading: post in chat **"Read order complete. Five rules: [verbatim]. Four boundaries: [verbatim]. W4 Track 1 scope: Xero + QuickBooks + Open Banking MCP connectors + Cash Conductor bundle scaffold + Diagnostic live-smoke wrapper + review-mcp-connector Codex skill + cluster F manifest. Ready to begin Step 1."**

---

## §1 — Success state (what "done" looks like at end of W4 Track 1)

When this goal is complete, the following are ALL TRUE:

### MCP connectors (Days 1-4)

1. **`packages/mcp-connectors/xero/`** exists; modeled on companies-house. Capabilities: `oauth_refresh`, `list_open_invoices`, `list_payments`, `get_invoice`, `write_payment_received`. Fixture-first; ≥15 vitest passing; OAuth scaffold accepts real credentials from `_secrets.env` but tests use fixtures. README documents the Xero rate-limit (60 calls/min per tenant; 5000/day; documented at https://developer.xero.com/documentation/guides/oauth2/limits).
2. **`packages/mcp-connectors/quickbooks/`** exists; same shape as Xero. Capabilities mirrored. ≥12 vitest passing. README documents QB rate-limit (500/min throttled).
3. **`packages/mcp-connectors/open-banking/`** exists; abstraction over TrueLayer + Plaid UK (provider chosen per-tenant config). Capabilities: `oauth_refresh` (90-day PSD2 consent), `list_transactions_since(last_ingested_at)`, `get_account_balance`. **Token-aging logic implemented**: emits `ESC_OPEN_BANKING_TOKEN_AGING` with `info`/`warn`/`blocking` staging per Cash Conductor §6 (≤30d/14d/7d). ≥15 vitest passing.
4. **Sage MCP connector — DEFERRED** per Cash Conductor §9 Q8 recommendation; documented in W4-5 backlog as "rebuild at first pilot tenant on Sage."

### Cash Conductor bundle scaffold (Day 5)

5. **`agents/recruitment/cash-conductor/cycle.sh`** exists; 14 steps per agent.md §4. Wires to the 3 connectors above + the D1-B `autosend-bridge-telegram` package (built separately at Concierge W10; cycle.sh degrades gracefully when absent — drafts-only mode per agent.md §1 readiness caveat).
6. **`agents/recruitment/cash-conductor/validate.sh`** exists; enforces Gate A per agent.md §5 (invoice/amount/contact triple-match; not-paid-in-24h; voice-classifier thresholds; Open Banking token age ≥7d).
7. **`agents/recruitment/cash-conductor/context.sh`** exists; hydrates tenant config + accounting auth + Open Banking auth + voice corpus + tone rules.
8. **`agents/recruitment/cash-conductor/cleanup.sh`** exists; purges transient OAuth tokens + provider rate-limit caches; emits `cash_conductor_cleanup` green-tier audit row.
9. **`agents/recruitment/cash-conductor/tools.yaml`** exists; declares: `xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`, `telegram_notify`, `autosend_bridge_telegram` (per D1-B).
10. **3 fixtures** at `agents/recruitment/cash-conductor/fixtures/`:
    - `01-primary.yaml` — happy path: Stage-1 exact-match reconciliation + 1 chase draft generated + Telegram approval flow
    - `02-edge-case-fuzzy-match.yaml` — Stage 4 fuzzy multi-candidate → `ESC_RECONCILIATION_AMBIGUOUS`
    - `99-token-aging-canary.yaml` — Open Banking token at 6 days → `ESC_OPEN_BANKING_TOKEN_AGING` blocking
11. **Cash Conductor agent.md `Status: Proposed`** unchanged — the agent.md was already RATIFIED by Codex R3; the bundle scaffold doesn't flip Status (production-readiness still gates on Hire #1 + accounting/Open Banking commercial signups per §8).

### Diagnostic live-smoke wrapper (Day 2 — small)

12. **`scripts/run-diagnostic-smoke.sh`** exists. Takes `--firm "<name>" [--sector <sector>]`; sets the env vars (`IFOS_REPO_ROOT`, `CTX_AGENT_DIR`, `CTX_TENANT_SLUG`, `IFOS_VAULT_ROOT`); reads `COMPANIES_HOUSE_API_KEY` + `ANTHROPIC_API_KEY` from `~/.ifos-local-vault/migration-test/_secrets.env`; runs `bash agents/recruitment/diagnostic/cycle.sh`; on success copies the report to `docs/artefacts/diagnostic-<firm-slug>-<ISO-date>.md` and prints the vault path. Single command for the founder.

### Codex `review-mcp-connector.md` skill (Day 1)

13. **`.codex/ratification/review-mcp-connector.md`** exists. Type-specific skill for MCP connector packages. Adds checks on top of SKILL.md: OAuth refresh idempotency; rate-limit budget declared; explicit retry policy; secrets never logged; fixture-first tests; integration with `_shared/hook-helpers.sh` for decision_log emissions. Modeled on `review-agent-bundle.md` length + structure.

### Codex ratification (Day 6)

14. **`scripts/run-codex-ratification.sh` cluster F added** — `mcp-connector` skill type per artefact:
    - `packages/mcp-connectors/xero/`
    - `packages/mcp-connectors/quickbooks/`
    - `packages/mcp-connectors/open-banking/`
    - `agents/recruitment/cash-conductor/` (full bundle via `agent-bundle` skill — re-ratification post-scaffold)
15. **Cluster F run executed** (founder runs, billed); verdict in `logs/codex-ratification/<session>/`. Expected: RATIFIED on all 4 OR ≤2 mechanical findings per artefact (closeable in 1 fix-pass).

### State + audit (Day 7)

16. **`.agents/current-priorities.md`** updated with W4 Track 1 close section.
17. **`docs/RISK-REGISTER.md`** updated: Risk #11 (Open Banking token rotation) — mitigated by Step 5 token-aging logic.
18. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue extended with Cluster F entries.
19. **All commits pushed.** Atomic per-package per Day-21 + Day-25 pattern.

---

## §2 — Scope: IN / OUT

### IN scope (must complete)

| Item | Why |
|---|---|
| Xero MCP connector (fixture-first; OAuth scaffold) | §1 success criterion 1; Cash Conductor's most likely first-tenant accounting system |
| QuickBooks MCP connector | §1 success criterion 2; second-most-likely |
| Open Banking MCP connector (TrueLayer + Plaid UK abstraction) | §1 criterion 3; harder due to 90-day token rotation but blocks all reconciliation |
| Cash Conductor bundle scaffold (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) | §1 criteria 5-10; agent.md is already RATIFIED, needs siblings |
| Diagnostic live-smoke wrapper | §1 criterion 12; ends Trigger 2 the moment founder lands API keys |
| `review-mcp-connector.md` Codex skill | §1 criterion 13; needed before cluster F can ratify the new connectors |
| Cluster F ratification manifest + run | §1 criteria 14-15 |
| State + manifest updates | §1 criteria 16-19 |

### OUT of scope (defer)

| Item | Reason |
|---|---|
| Sage MCP connector | Cash Conductor §9 Q8 — defer to first-pilot-on-Sage trigger |
| Diagnostic voice classifier microservice | Separate W4-5 polish goal; deferred until Anthropic key live + first pilot voice corpus seeded |
| Diagnostic LinkedIn deep data via Proxycurl | Gated on Proxycurl founder signup (founder-action item 8a); separate slice |
| Cash Conductor live integration tests (against real Xero/QB sandbox) | Gated on founder commercial signups (item 10); fixture-first is the v1.0 ship gate |
| `autosend-bridge-telegram` package | Reserved for Concierge W10 build slice per D1-B doc §"Implementation surface"; Cash Conductor cycle.sh degrades gracefully when absent (drafts-only mode) |
| Bullhorn MCP connector | Track 2 (Bullhorn-gated); not Track 1 |
| Brain UI work | v1.1+ |
| Modifying ratified ADRs / schema supplements | Closed Week 3; no edits beyond mechanical fixes via founder authorization |

---

## §3 — Path A discipline reminder

Credentials needed from founder DURING execution:

| Step | Credential | Path A protocol |
|---|---|---|
| Step 12 (Diagnostic live smoke) | `COMPANIES_HOUSE_API_KEY` + `ANTHROPIC_API_KEY` | Founder registers self-service; saves to `~/.ifos-local-vault/migration-test/_secrets.env` mode 0600; replies "key saved"; key NEVER pasted in chat |
| Step 15 (Cluster F Codex run) | Codex CLI auth | Founder runs `codex login` once; token persists in `~/.codex/auth.json` |
| Live connector tests (deferred per §2) | Xero dev key / QB sandbox / TrueLayer dev key | Founder commercial signups (items 8-10); same `_secrets.env` save protocol |

When the executor reaches a credential gate:

1. STOP executing.
2. State: "Founder action needed: <specific credential>. Register at: <verified URL>. Save command: `<exact bash with placeholder>`. Confirm 'key saved' when done; DO NOT paste the key in chat."
3. Wait.
4. Resume.

**NEVER** ask the founder to paste any key. **NEVER** echo a key after they confirm. **NEVER** commit `_secrets.env`. **NEVER** include keys in commit messages or error logs.

---

## §4 — Execution plan (Day-by-day, ~5-7 day window; commit per step)

### DAY 1 — Substrate verification + review-mcp-connector skill + Diagnostic live-smoke wrapper

#### Step 1 — Pull master + verify substrate state (~15 min)

```bash
cd ~/code/CortexOS
git pull origin main
pnpm install
# Build the 4 IFOS packages so workspace deps resolve
for p in packages/utilities/web-scraper packages/mcp-connectors/companies-house packages/diagnostic-generator packages/agent-renderer; do
  (cd "$p" && pnpm -s build && pnpm -s test) | tail -3
done
bash agents/_shared/tests/test-hook-helpers.sh | tail -2
bash agents/_shared/tests/test-voice-loader.sh | tail -2
find agents scripts -name "*.sh" -print0 | xargs -0 shellcheck && echo "shellcheck: CLEAN"
```

Acceptance: 65 vitest pass + 2 bash suites green + shellcheck clean.

Commit (only if any incidental fixes needed): `chore(week-4): substrate verification before track-1 build`

#### Step 2 — Author `review-mcp-connector.md` Codex skill (~1.5 hours)

Create `.codex/ratification/review-mcp-connector.md` modeled on `review-agent-bundle.md`. The skill ADDS these checks on top of `SKILL.md`:

1. **Capabilities surface** — every capability declared in the connector's `tools.yaml` (or equivalent registration) must have a corresponding TypeScript function exported from the package.
2. **OAuth refresh idempotency** — if the connector handles OAuth, refresh must be safe to call concurrently AND must use atomic token rotation (no torn writes to `_secrets.env`).
3. **Rate-limit budget declared** — README must state the upstream rate-limit (calls/min, calls/day) AND the connector's chosen safety margin (typically 80% of upstream limit).
4. **Explicit retry policy** — 429/5xx handling: max retries, backoff strategy, ESC code on exhaustion.
5. **Secrets never logged** — grep the package source for `console.log.*KEY|console.log.*SECRET|console.log.*PASSWORD`; must be 0 matches. Same for `throw new Error\(.*KEY` etc.
6. **Fixture-first tests** — vitest must have at least one fixture per capability; live API calls behind an env-var gate (`MCP_LIVE_TESTS=true`) that defaults off in CI.
7. **decision_log integration** — every state-changing capability emits via `_shared/hook-helpers.sh hh_decision_action` with the registered `action_type` from `autosend-policy.yaml`.

Output format identical to other type skills: RATIFIED with optional advisory notes, OR REJECTED with a numbered issue list each citing line/section + concrete fix.

Commit: `feat(codex-skill): review-mcp-connector.md for cluster F ratification`

#### Step 3 — Diagnostic live-smoke wrapper (~30 min)

Create `scripts/run-diagnostic-smoke.sh`:

```bash
#!/usr/bin/env bash
# Usage: bash scripts/run-diagnostic-smoke.sh --firm "Hays plc" [--sector recruitment]
# Reads CH + Anthropic keys from ~/.ifos-local-vault/migration-test/_secrets.env
# Runs Diagnostic cycle.sh; on success archives the report under docs/artefacts/
set -euo pipefail
# ... arg parsing + env-var setup + cycle.sh invocation + report archival
```

Acceptance:
- `bash -n` clean; shellcheck clean
- Dry-run path: prints what it would do without keys
- Error message clear when keys missing
- README at `scripts/README.md` updated with the smoke command

Commit: `feat(diagnostic-smoke): one-command live smoke wrapper for Trigger-2 closure`

### DAY 2 — Xero MCP connector

#### Step 4 — Scaffold `packages/mcp-connectors/xero/` (~3-4 hours)

Mirror the companies-house structure exactly:

```
packages/mcp-connectors/xero/
  package.json              # @ifos/xero workspace package; deps: zod, undici (fetch)
  tsconfig.json
  vitest.config.ts
  src/
    index.ts                # public surface: createXeroClient(config)
    auth.ts                 # OAuth 2.0 refresh logic; atomic token rotation
    invoices.ts             # list_open_invoices, get_invoice
    payments.ts             # list_payments, write_payment_received
    types.ts                # Xero API response types (Zod schemas)
    cache.ts                # 7-day disk cache for read-only calls; same pattern as companies-house
    rate-limit.ts           # token bucket: 60/min per tenant; safety margin 48/min
  tests/
    auth.test.ts            # refresh idempotency; concurrent-refresh safety
    invoices.test.ts        # list + get fixtures
    payments.test.ts        # list + write_payment_received fixtures
    rate-limit.test.ts      # bucket exhaustion → ESC_RATE_LIMIT_HIT mock fire
  fixtures/
    invoices-page-1.json    # 25 invoices from Xero v2 API shape
    invoices-page-2.json
    payments-recent.json
    payment-write-ok.json
    payment-write-409.json  # concurrent-write conflict
  README.md                 # capabilities + rate-limit + auth pattern + retry policy
```

Acceptance per `review-mcp-connector.md` skill:
- All 5 skill checks pass (capabilities ↔ exports; OAuth idempotency; rate-limit documented; retry policy explicit; no secret logs)
- ≥15 vitest pass
- `pnpm typecheck` clean
- README ≥150 lines including the Xero capability matrix

Commit: `feat(mcp/xero): scaffold @ifos/xero MCP connector — fixture-first, OAuth + rate-limit + retry`

### DAY 3 — QuickBooks MCP connector

#### Step 5 — Scaffold `packages/mcp-connectors/quickbooks/` (~3-4 hours)

Same shape as Xero. Capabilities: `oauth_refresh`, `list_open_invoices`, `list_payments`, `get_invoice`, `write_payment_received`. QB has a slightly different OAuth flow (per-realm); document the diff in README.

Acceptance: same as Xero. ≥12 vitest.

Commit: `feat(mcp/quickbooks): scaffold @ifos/quickbooks MCP connector — fixture-first parity with xero`

### DAY 4 — Open Banking MCP connector

#### Step 6 — Scaffold `packages/mcp-connectors/open-banking/` (~5 hours; hardest)

Abstracted over TrueLayer (v3 API) + Plaid UK; provider chosen via `config.provider`. Capabilities: `oauth_refresh` (90-day PSD2 consent), `list_transactions_since(last_ingested_at)`, `get_account_balance`.

**Critical: token-aging logic** — implement a `getTokenAgeStage(token_issued_at)` function that returns `'fresh' | 'info' | 'warn' | 'blocking'`:
- fresh: ≥30 days from expiry
- info: 15-30d
- warn: 8-14d
- blocking: ≤7d

`oauth_refresh` checks staged age + emits `ESC_OPEN_BANKING_TOKEN_AGING` with the appropriate stage in payload. At `blocking`, refresh attempts STOP and the cycle.sh consumer must surface to operator for re-authorization.

Acceptance: same as Xero. ≥15 vitest including token-aging test cases at boundary days.

Commit: `feat(mcp/open-banking): scaffold @ifos/open-banking MCP connector — TrueLayer + Plaid UK + 90-day token staging`

### DAY 5 — Cash Conductor bundle scaffold

#### Step 7 — Author 5 sibling files + 3 fixtures (~5 hours)

Per `agent.md §4` (14-step workflow) + `agent.md §5` Gate A spec + ADR-003 agent bundle pattern.

Files:
- `agents/recruitment/cash-conductor/cycle.sh` — 14 steps; wires the 3 connectors above + the autosend-bridge-telegram package (graceful degradation when absent per D1-B + agent.md §1 readiness caveat — drafts-only when bridge missing)
- `agents/recruitment/cash-conductor/validate.sh` — Gate A enforcement per agent.md §5
- `agents/recruitment/cash-conductor/context.sh` — hydration
- `agents/recruitment/cash-conductor/cleanup.sh` — transient OAuth token + cache purge; emits `cash_conductor_cleanup` audit row (green tier; add to autosend-policy.yaml if not yet registered)
- `agents/recruitment/cash-conductor/tools.yaml` — capability declarations: `xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`, `telegram_notify`, `autosend_bridge_telegram`
- 3 fixtures per §1 criterion 10

Acceptance:
- shellcheck clean on all 4 .sh files
- `bash -n` clean
- Per-step hh_decision_* calls match agent.md §4 verbatim
- Every fixture exercises a distinct Gate A / Gate B / ESC path
- Adapter boundary: 0 Composio/AgentMail references
- Vault/Postgres split: narrative draft body to vault, structured state to Postgres (no narrative in `decision_log.payload`)

Commit per file: `feat(cash-conductor): cycle.sh — 14-step orchestration` etc. (6 commits total)

### DAY 6 — Cluster F Codex ratification

#### Step 8 — Extend `scripts/run-codex-ratification.sh` with cluster F (~15 min)

Add CLUSTERS[F] block listing the 4 artefacts:
```
packages/mcp-connectors/xero|mcp-connector
packages/mcp-connectors/quickbooks|mcp-connector
packages/mcp-connectors/open-banking|mcp-connector
agents/recruitment/cash-conductor|agent-bundle
```

Update `--list-clusters` loop (add F) + usage help (add `mcp-connector` to skill types if not yet there).

Acceptance: `bash scripts/run-codex-ratification.sh --list-clusters` shows cluster F with 4 items + correct skill mapping; shellcheck clean.

Commit: `feat(codex-harness): add cluster F for W4 Track-1 connectors + Cash Conductor bundle`

#### Step 9 — Cluster F run (founder runs, ~30 min Codex time)

Founder runs:
```bash
bash scripts/run-codex-ratification.sh --cluster F
```

Triage per master brief §10.3 step 5 (≤2 round-trips per artefact):
- All RATIFIED → close
- Mechanical REJECTIONS → fix + re-run (≤2 rounds total)
- Founder-decision REJECTIONS → write `docs/decisions/codex-disagreement-YYYY-MM-DD-<topic>.md` per Day-11 pattern

Commit (per remediation cycle if needed): `fix(cluster-f-rN): <N> mechanical fixes + <M> founder-escalated`

### DAY 7 — State + manifest sync + W4 Track-1 close

#### Step 10 — State updates (~45 min)

1. **`.agents/current-priorities.md`** — W4 Track 1 close section. List shipped artefacts. Update Open backlog: W4 Track 2 (Bullhorn-dependent agents — Janitor/Scribe) conditional on Bullhorn A+B Accepted; Cash Conductor full live test conditional on accounting/Open Banking commercial signups; Diagnostic live render gated on API keys.
2. **`docs/RISK-REGISTER.md`** — Risk #11 (Open Banking token rotation) mitigated.
3. **`docs/decisions/2026-05-18-codex-ratification-manifest.md`** §1 queue — Cluster F verdicts captured.

Commit: `state(w4-track-1-close): cluster F verdicts + W4 Track-2 backlog + risk register sync`

Push:
```bash
git push origin main
```

Final §10 end-of-goal report per the template below.

---

## §5 — Hard quality gates (must pass at each commit)

| Gate | Threshold | Verification |
|---|---|---|
| **Shellcheck** | All `.sh` files clean (errors only; warnings allowed with explicit `# shellcheck disable=`) | `find agents scripts -name "*.sh" -print0 \| xargs -0 shellcheck` |
| **Typecheck** | All TS packages clean | `pnpm typecheck` per package |
| **Unit tests** | Each modified package: all tests pass; ≥3 new tests per non-trivial change | `pnpm test` per package |
| **No secrets in commits** | grep for API keys, OAuth tokens, passwords in diff | manual scan + grep for `[A-Za-z0-9_-]{32,}` in non-test files |
| **URLs verified** | Every external URL in docs/code curl-checked before citing | `curl -sI -L <url>` returns 200/301 |
| **Path A discipline** | No credentials in chat, ever | self-audit before each step |
| **Master plan citations** | Every claim cites master brief / ULTRAPLAN / ADR / agent.md line | grep diff for citation strings |
| **Spec line-anchor accuracy** | Cited lines exist + contain claimed content | spot-grep each citation against the source file |
| **Commit messages** | Conventional commits + Co-Authored-By footer + cite master plan section | grep commit log |
| **Codex skill output captured** | Cluster F run writes per-artefact `.output.md` + `.verdict.txt` files | `ls logs/codex-ratification/<session>/` |
| **Adapter boundary** | 0 Composio / AgentMail references in agent.md/tools.yaml/fixtures | `grep -rinE "composio\|agentmail" agents/` returns 0 |

---

## §6 — Failure modes + recovery

| Failure | Recovery |
|---|---|
| Founder slow to register CH or Anthropic key | Step 3 (live-smoke wrapper) ships regardless; smoke run defers until keys arrive |
| Xero/QB/TrueLayer/Plaid API docs out of date or shapes differ from fixtures | Test against real sandbox once founder commercial signup lands; fixture-only tests should still cover the connector's logic correctness |
| Open Banking token-aging boundary off-by-one | Property-based test on `getTokenAgeStage` covering exact day boundaries |
| Cluster F returns >2 REJECTED on a single artefact | Founder review per master brief §10.3 step 5; write disagreement doc; defer |
| Cash Conductor bundle integration with `autosend-bridge-telegram` blocked (package not yet built — that's Concierge W10) | cycle.sh degrades to drafts-only mode per agent.md §1 readiness caveat; documented and tested via fixture 01-primary |
| pnpm install fails (e.g. lockfile drift) | `git checkout pnpm-lock.yaml`; `pnpm install --frozen-lockfile`; re-run |
| New connector breaks existing test suite | STOP; root-cause; fix; all tests green before proceeding |

---

## §7 — When to ask the founder (vs proceed)

### Proceed without asking

- Connector scaffold structure choices (file layout, type definitions, fixture content)
- Test fixture additions
- Doc + README writing
- Refactoring existing TS code that doesn't change behaviour
- Citing additional master plan sections beyond those explicitly listed
- Per-step Codex remediation within the ≤2-round ceiling

### MUST ask the founder

- Any deviation from `agent.md` output contract patterns
- Any decision that changes the master-plan citation chain
- Any commercial signup (founder commercial action)
- Any live API call against a paid service (cost-incurring)
- Any modification to live VPS Postgres state
- Any reduction in Gate A strictness on the Cash Conductor bundle
- Codex disagreement requiring founder arbitration (write disagreement doc per Day-11 pattern)
- D1-B implementation choices that materially differ from `2026-05-31-d1-founder-decision.md` §"Implementation surface"

---

## §8 — Codex ratification protocol

Per master brief §10 + §10.3 step 5 hard ceiling + Day-25 Codex-cycle pattern.

### Skill development (Step 2)

The new `review-mcp-connector.md` skill is itself an artefact subject to ratification. It ratifies via `review-architecture-decision.md` (skills are architectural artefacts). Add to next ratification cluster.

### Cluster F manifest (Step 8)

Add CLUSTERS[F] to `scripts/run-codex-ratification.sh`. 4 artefacts (3 connectors + Cash Conductor bundle).

### Cluster F run (Step 9)

```bash
bash scripts/run-codex-ratification.sh --cluster F
```

Triage rules:
- **All RATIFIED:** close; proceed to Step 10.
- **Mechanical REJECTIONS:** Round 2 remediation; expect RATIFIED. ≤2 round-trips per artefact.
- **Founder-decision REJECTIONS:** STOP; write founder-decision doc; defer.
- **Codex disagreement (challenges a master-plan claim):** STOP; write `docs/decisions/codex-disagreement-YYYY-MM-DD-<topic>.md`; founder arbitrates.

---

## §9 — Quality multiplier: "presentable to Codex on first submission"

Each connector should ratify on FIRST submission. That means:

1. **Every capability documented.** README lists all exported functions with input/output Zod schemas + which `autosend-policy.yaml` action_type they correspond to.
2. **Every rate-limit cited from upstream documentation.** No invented numbers. URL of the upstream rate-limit page in README.
3. **OAuth refresh atomic.** Concurrent-refresh test must demonstrate no torn writes to `_secrets.env`.
4. **No secrets logged.** grep the diff for `console.log` / `console.error` paths that include credential vars; must be empty.
5. **Fixture coverage** — at minimum one fixture per capability + one error-path fixture per capability.
6. **Integration with `_shared/hook-helpers.sh`** — every state-changing capability emits `hh_decision_action` with the correct `action_type` per `autosend-policy.yaml`.
7. **Adapter boundary** — 0 Composio / AgentMail references in any file the connector touches.

If a connector doesn't meet these 7 criteria, Cluster F will reject it. Re-write before commit, not after.

---

## §10 — End-of-goal report template

After Step 10, the executor produces this exact report:

```
═══════════════════════════════════════════════════════
W4 TRACK 1 COMPLETE — Cash Conductor MCP CONNECTORS + DIAGNOSTIC LIVE-SMOKE WRAPPER

Connectors shipped:
  @ifos/xero:              <N> capabilities, <M> vitest, README <L> lines
  @ifos/quickbooks:        <N> capabilities, <M> vitest, README <L> lines
  @ifos/open-banking:      <N> capabilities (TrueLayer + Plaid UK), <M> vitest, token-aging logic tested at boundaries
  (sage:                   DEFERRED to first-pilot-on-Sage trigger per Q8)

Cash Conductor bundle:
  cycle.sh:                14 steps; D1-B graceful degradation tested
  validate.sh:             Gate A per agent.md §5
  context.sh:              hydration complete
  cleanup.sh:              transient state purge
  tools.yaml:              6 capabilities declared
  fixtures:                3 (primary + fuzzy-match + token-aging-canary)

Diagnostic live-smoke wrapper:
  scripts/run-diagnostic-smoke.sh: ready; Trigger-2 closes on next API-key-saved + smoke run

Codex skill:
  .codex/ratification/review-mcp-connector.md: built; ratified via review-architecture-decision

Cluster F verdict:
  <N> RATIFIED / <M> REJECTED of 4

Commits (~12-15):
  <SHA>  chore(week-4): substrate verification
  <SHA>  feat(codex-skill): review-mcp-connector.md
  <SHA>  feat(diagnostic-smoke): one-command live-smoke wrapper
  <SHA>  feat(mcp/xero): scaffold @ifos/xero
  <SHA>  feat(mcp/quickbooks): scaffold @ifos/quickbooks
  <SHA>  feat(mcp/open-banking): scaffold @ifos/open-banking
  <SHA>  feat(cash-conductor): cycle.sh
  <SHA>  feat(cash-conductor): validate.sh
  <SHA>  feat(cash-conductor): context.sh
  <SHA>  feat(cash-conductor): cleanup.sh
  <SHA>  feat(cash-conductor): tools.yaml
  <SHA>  feat(cash-conductor): 3 fixtures
  <SHA>  feat(codex-harness): cluster F
  <SHA>  fix(cluster-f-rN): mechanical fixes (if any)
  <SHA>  state(w4-track-1-close): final sync

Master plan alignment:
  ✓ ADR-005 — Cash Conductor pull-forward to W4 substrate
  ✓ master brief §8.2 W4 row — Cash Conductor MCP connectors
  ✓ ULTRAPLAN §8.1 A4 — Cash Conductor spec lines 531-545
  ✓ D1-B (2026-05-31 decision) — autosend bridge approach baked into cycle.sh
  ✓ Trigger 2 — Diagnostic live-smoke wrapper ready; closes the moment API keys land

W4 Track 2 backlog (unchanged; conditional on Bullhorn A+B Accepted):
  - Bullhorn MCP connector (W4-5 build chain)
  - Janitor build (W5; depends on Bullhorn R+W)
  - Scribe build (W6; depends on Bullhorn W + Fathom/Fireflies)

Pending founder actions (carried forward):
  - CH + Anthropic API keys (Item 3) — closes Diagnostic live render
  - v0.3 migration to live VPS (Item 4 — if not yet done)
  - Bullhorn A+B chase / fallback at 2026-06-10 (Item 6)
  - Q1 LOI (Item 7 — Jack's lane; Trigger 1 fires 2026-06-03)
  - Commercial signups for Xero / QB / Open Banking (Items 10, 8a) — gates live connector tests
  - Fathom OR Fireflies signup (Item 9 — Scribe W6 prereq)

Open Codex disagreements: <none | list>

Next decision for founder:
  - Approve W4 Track 2 entry condition (Bullhorn A+B Accepted) or pivot to next Track-1 slice (Diagnostic voice classifier microservice)?
═══════════════════════════════════════════════════════
```

---

## §11 — Risks specific to this goal

| # | Risk | Likelihood | Mitigation |
|---|---|---|---|
| 1 | Xero / QB / TrueLayer / Plaid API shapes have changed since the public docs were last updated | Medium | Fixture-first: connector logic correctness tested against pinned fixture shapes; real-API verification deferred to founder commercial signup |
| 2 | Open Banking 90-day token rotation logic has off-by-one bugs at day boundaries | Medium | Property-based testing on `getTokenAgeStage` covering days 0-100 |
| 3 | Cluster F finds substantive issues beyond mechanical (substantive Codex disagreement) | Low | Per goal §8 triage rules; defer + founder review |
| 4 | The `autosend-bridge-telegram` graceful-degradation logic in cycle.sh is incorrect (sends instead of drafting when bridge missing) | High-impact-if-wrong | Fixture `01-primary` MUST cover both bridge-present and bridge-absent code paths; assert that the orange-tier action row is written but NOT auto-sent in the bridge-absent case |
| 5 | Cash Conductor bundle integration test surface grows beyond fixture coverage | Medium | Three fixtures targeted at the highest-risk paths (happy / fuzzy-match-ambiguity / token-aging); broader integration coverage deferred to first-pilot-tenant phase |
| 6 | Founder commercial signups delay live testing | Medium | All scaffolds work fixture-first; live testing deferred without blocking the W4 Track-1 close |
| 7 | Goal slippage past 7-day window | Low-medium | Open Banking is the longest step (~5 hours); if it slips, defer to Day-7 polish; ship Xero + QB + Cash Conductor scaffold + smoke wrapper first |

---

## §12 — Definition of "W4 Track 1 complete"

Complete when:

- All 19 items in §1 success state are TRUE
- ~12-15 commits pushed to origin/main
- Cluster F logs in `logs/codex-ratification/<session>/`
- §10 end-of-goal report posted by executor
- Founder has reviewed the §10 report

**Day 7 (2026-06-05) is the soft target. Day 9 (2026-06-07) is the hard cutoff** (W5 Janitor build starts then per master brief §8.2 if Bullhorn A+B has Accepted). If Day 9 hits without completion, escalate to founder review + scope-cut decision.

---

*End of /goal prompt for W4 Track 1.*
