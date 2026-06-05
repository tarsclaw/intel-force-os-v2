# Pending /goal — W6 Day 36 Cash Conductor prep (Option X)

**Purpose:** durable record of the Option X /goal text drafted 2026-06-05 morning; founder pastes verbatim into fresh Claude Code session at location 2 (per `handoff-2026-06-05-location-shift.md` Step 3).

**Verified:** 3554 chars body (under 4000 cap); HEAD at draft time = `f1e8e91`.

**Context:** Bullhorn dev creds unobtainable today; pivoted from Phase 1a Bullhorn → Option X Cash Conductor W7-8 prep using Xero + QuickBooks + TrueLayer sandbox creds founder DID populate. See `goal-week-6-execution-plan.md` §2 for full W6 plan; this /goal is a same-day strategic pivot.

---

## Paste this INTO `/goal <text>` in a fresh Claude Code session

(Replace `<text>` with everything below the dashes.)

---

```
w6-d36-cash-conductor-prep-xero-qb-truelayer-live-tests

W6 pivot per Day 36 analysis: Bullhorn dev creds unobtainable today (Phase 1a blocked; bootstrap helper at dd226f4 stays in tree for Week 7+ pilot-cred arrival). Xero + QB + TrueLayer sandbox creds populated in dev-sandbox/_secrets.env (verified 12:11). Pivot to Cash Conductor W7-8 prep early: 3 MCP_LIVE_TESTS=1 blocks + 3 OAuth bootstrap helpers + ≥3 live capability tests per package. Tree clean at HEAD f1e8e91.

READ FIRST:
1. docs/operations/goal-week-6-execution-plan.md §2 (Phase 1a re-scoped; Phase 5a Cash Conductor target)
2. docs/operations/session-retrospective-2026-06-03.md
3. packages/mcp-connectors/{xero,quickbooks,open-banking}/README.md §Live tests deferred
4. packages/mcp-connectors/bullhorn/scripts/bootstrap-bullhorn-oauth.sh (dd226f4) — reference shape
5. ~/.ifos-local-vault/dev-sandbox/_secrets.env — XERO_*/QB_*/TRUELAYER_* SET; NEVER cat — use awk -F= for var names only (memory feedback-never-cat-secrets-files)
6. CLAUDE.md

CONSTRAINTS:
- Path A. Credentials NEVER in chat; read via process.env at runtime; per review-mcp-connector §5 errors mask values.
- NEVER cat/Read/head *_secrets / *.env / *token / *credential paths — awk for var names only.
- Fixture vitest 298+ stays green; add live tests gated by MCP_LIVE_TESTS=1.
- Atomic per-package commits (3 total). Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>.
- NO Codex / cortextos-submodule / Composio / AgentMail / Bullhorn-related work today.
- Quality > speed; STOP on test red after 1 fix round / context-decay / boundary violation.

BUILD (~9h; 3 packages × ~3h each, mirror @ifos/bullhorn dd226f4 shape):

1. @ifos/xero:
   - scripts/bootstrap-xero-oauth.sh — OAuth 2.0 + PKCE; local callback (port 3100 per .envrc); atomic write to ~/.ifos-local-vault/dev-sandbox/xero-tokens.json mode 0600 against Demo Company (XERO_DEMO_COMPANY_ORG_ID)
   - tests/live.test.ts gated by `if (!process.env.MCP_LIVE_TESTS) return;` — ≥3 tests: refreshTokens + listOpenInvoices + getInvoice
   - README §Live tests
   - Commit: feat(mcp/xero): MCP_LIVE_TESTS block + OAuth bootstrap helper

2. @ifos/quickbooks (mirror xero):
   - scripts/bootstrap-qb-oauth.sh — sandbox realm (QB_SANDBOX_REALM_ID); atomic write to qb-tokens.json
   - tests/live.test.ts — ≥3 tests: refreshTokens + listOpenInvoices + getInvoice
   - README §Live tests
   - Commit: feat(mcp/quickbooks): MCP_LIVE_TESTS block + OAuth bootstrap helper

3. @ifos/open-banking:
   - scripts/bootstrap-ob-oauth.sh — TrueLayer OAuth + PSD2 Mock Bank consent; atomic token write
   - tests/live.test.ts — ≥3 tests: refreshTokens + listTransactions + getAccountBalance against Mock Bank
   - README §Live tests
   - Commit: feat(mcp/open-banking): MCP_LIVE_TESTS block + TrueLayer OAuth bootstrap

GATES (per commit): typecheck CLEAN; fixture vitest 298+ green; pnpm test:live green (≥9 total); shellcheck on bootstrap scripts; tree clean.

STOP:
- OAuth bootstrap dance fails any service → STOP, surface; verify cred format.
- Live tests red after 1 fix round → STOP.
- Boundary / Bullhorn work / Codex attempted → STOP, NEVER auto-fix.
- ANY cat/Read/head of *_secrets/.env path → STOP.

EOD REPORT:
- 3 commit SHAs + per-package live-test pass counts (≥3 each; ≥9 total)
- Fixture vitest count maintained (298+)
- Per-package capability set-equality vs tools.yaml
- Founder gates for W7-8 Cash Conductor live wiring
- Tree-clean + recommendation: pause OR proceed to Granola Phase 1b
```

---

## Notes for the new session

- **Founder will be at keyboard 3 times** during build for OAuth consent clicks (Xero browser → "Allow", QuickBooks browser → "Allow", TrueLayer Mock Bank → "Allow"). ~5 min each.
- **9h budget is aggressive** for one day; if context-decay surfaces at any per-package checkpoint, STOP + surface rather than push through.
- **Don't touch Bullhorn** — explicitly out of scope per founder's reported block. Helper at `dd226f4` stays as-is.
- **Don't touch Granola** — Phase 1b is a separate /goal; Granola transport implementation is its own ~6-8h scope per `goal-week-6-execution-plan.md` §2 Phase 1b.
- **The diagnostic-generator fix at `9ae2e15`** is in tree; vitest baseline of 298+ INCLUDES the fixed test. Don't re-touch.
