# `agents/_shared/` — IFOS shared agent runtime

**Status:** Phase 3 scaffold (v0.1). `voice-loader.sh` lands in Phase 5 once `vertical-schema.yaml` v0.2 (Phase 4) defines voice corpus entities.

This directory is the **canonical source** for files the renderer copies into every per-tenant agent's runtime location at `${frameworkRoot}/orgs/<tenant>/agents/_shared/` per ADR-003 §3.3.3 Option γ. Each rendered agent reaches `_shared/` via a symlink at `.claude/hooks/_shared → ../../_shared`.

## Contents

| File | Purpose | Phase |
|---|---|---|
| `escalation-codes.md` | ESC catalogue — 24 active codes + 2 reserved | 1 (`a279226`) |
| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
| `hook-helpers.sh` | 3 `hh_decision_*` + 7 `autosend_*` Bash helpers per master brief §8.1 Change 2 + autosend §4 | 3 |
| `voice-loader.sh` | `hh_load_tone_rules` / `hh_load_voice_samples` / `hh_load_recent_edits` per master brief §8.1 Change 1 | 5 |
| `tests/test-hook-helpers.sh` | Offline test harness — 20 tests against fallback mode | 3 |

## Renderer-copies-not-symlinks contract (ADR-003 §3.3.3 Option γ)

The renderer COPIES this entire directory into every per-tenant rendered org-agents dir on every `render-agent` invocation. It does **not** symlink. Mid-pilot edits to `hook-helpers.sh` therefore require re-rendering every agent that uses it. v1.0 acceptable (single-tenant pilot); v1.1 may add SHA-based skip-if-unchanged optimisation per renderer README §Known Limitations.

## Live mode vs fallback mode

`hook-helpers.sh` writes to `decision_log` via two paths:

1. **Live mode (production)** — `IFOS_DB_URL` is set + `psql` is on PATH. Helpers `INSERT` via `psql -v ON_ERROR_STOP=1`. Postgres RLS isolates rows per tenant via the `ifos.tenant_slug` session variable (set with `SET LOCAL` per row).
2. **Fallback mode (degraded / offline)** — `IFOS_DB_URL` unset OR `psql` unavailable OR `psql` exited non-zero. Helpers append JSON lines to `${IFOS_DECISION_LOG_FALLBACK:-/vault/<tenant>/decision-log.jsonl}`. The trail replays into Postgres when connectivity returns via the autosend-syncer worker (Week 5+).

The dual-mode design is intentional. It means **agent processes are not blocked by Postgres unavailability** — they continue writing audit data locally + degrade gracefully. This is the v1.0 mitigation for Risk #1 (cortextOS primitive 1 flaky-under-load): even if the daemon stalls, individual agents still produce auditable output.

### Environment variables

| Var | Required? | Purpose | Default |
|---|---|---|---|
| `CTX_TENANT_SLUG` | **yes** | RLS-isolated tenant; matches `ifos_tenant_<slug>` Postgres role | — |
| `CTX_AGENT_NAME` | **yes** | Bundle agent name | — |
| `CTX_AGENT_DIR` | yes (for renderer-set paths) | Absolute path to rendered agent dir | — |
| `IFOS_DB_URL` | no (live mode only) | Full Postgres connection string with credentials | — |
| `IFOS_VAULT_ROOT` | no | Vault root prefix | `/vault` |
| `IFOS_DECISION_LOG_FALLBACK` | no | Override fallback JSONL path | `${IFOS_VAULT_ROOT}/<tenant>/decision-log.jsonl` |
| `HH_POLICY_FILE` | no | Override path to `autosend-policy.yaml` | `${CTX_AGENT_DIR}/.claude/hooks/_shared/autosend-policy.yaml` |
| `HH_ESC_CATALOGUE` | no | Override path to `escalation-codes.md` | `${CTX_AGENT_DIR}/.claude/hooks/_shared/escalation-codes.md` |
| `HH_AWAIT_TEST_MODE` | no (test only) | `approve` / `reject` / `timeout` — short-circuits `autosend_await_approval` poll loop | — |
| `HH_POLICY_VERSION_SHA` | no | Git SHA stamped into `decision_log.payload.policy_version_sha` per §7 | `unknown` |

## Public API

### 3 `hh_decision_*` contracts (master brief §8.1 Change 2)

```bash
hh_decision_trigger <trigger_type> [<reason>]
hh_decision_output  <output_type> <artefact_ref> [<reason>]
hh_decision_action  <action_type> <target> <payload_hash> <payload_preview>
```

`hh_decision_action` is the **gated** call. Returns `0` if action allowed, `1` if blocked or approval rejected. All three write a `decision_log` row before returning.

### 7 `autosend_*` helpers (autosend-safety-policy §4)

```bash
autosend_policy_lookup        <action_type>                                          # prints tier
autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>               # prints possibly-elevated tier
autosend_emit_decision_log    <phase> <tier> <action_type> <target> <hash> <preview> <reason>
autosend_escalate             <ESC_CODE> [<key=value>...]
autosend_should_sample        <action_type> <tenant_slug>                            # returns 0 if sampled
autosend_spot_check_enqueue   <action_type> <target> <hash> <preview> <tenant_slug>
autosend_await_approval       <action_type> <target> <hash>                          # blocks until resolved
```

## Auto-send tier dispatch (autosend-safety-policy §4)

`hh_decision_action` dispatches per tier:

| Tier | Behaviour | Return |
|---|---|---|
| **green** | Emit `phase=action`, return 0 immediately | 0 |
| **yellow** | Emit `phase=action`, draw 1-in-N spot-check sample, return 0 | 0 |
| **orange** | Emit `phase=action` + escalate `ESC_AUTOSEND_NEEDS_REVIEW`, block on approval gate, return 0/1 | depends on approval |
| **red** | Emit `phase=gating_failed` + escalate `ESC_AUTOSEND_BLOCKED`, return 1 | 1 |
| _unknown_ | Emit `phase=gating_failed` (`fail-safe-red`) + escalate `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`, return 1 | 1 |

## Telegram-down failure mode

Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.

**Tested:** `HH_AWAIT_TEST_MODE=timeout` short-circuits the poll loop and exercises the timeout path; verified in `tests/test-hook-helpers.sh` test #7.

**Not tested:** the full 4h wall-clock timeout in production. First Diagnostic agent build (Week 3) is the natural place to exercise this — Diagnostic uses `diagnostic_email_send` (orange tier, PT4H timeout).

## Testing

```bash
bash agents/_shared/tests/test-hook-helpers.sh
```

Expected output: `Tests run: 20  Tests passed: 20  ALL PASS ✓` (~3 seconds).

### Live integration test (manual founder action)

Phase 3 acceptance #2 + #3 require live Postgres writes against the Hetzner VPS. Procedure:

1. Founder: retrieve `ifos_app` Postgres password from 1Password ("IFOS Postgres ifos_app — production"). Path A discipline applies — password stays in founder's local terminal.
2. Founder runs (single-line, NEVER in this chat):
   ```bash
   IFOS_DB_URL="postgresql://ifos_app:<password>@178.105.87.24:5432/ifos?sslmode=require" \
   CTX_TENANT_SLUG="migration-test" \
   CTX_AGENT_NAME="test-agent" \
   bash -c 'source agents/_shared/hook-helpers.sh; hh_decision_trigger "manual_smoke_test"'
   ```
3. Founder verifies via `psql` that one new row landed in `decision_log` with `phase='trigger'` + `tenant_slug='migration-test'`.
4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
   ```sql
   SELECT count(*) FROM decision_log
   WHERE tenant_slug = 'migration-test'
     AND payload->>'tier' = 'red'
     AND created_at > now() - interval '7 days';
   ```
5. Report result back. If row count > 3 in a 7-day window, kill-criterion Trigger 5 fires (per `v1.0-kill-criterion.md` §2 Trigger 5).

## Codex Day-7 ratification

Three new artefacts join the queue:

- `agents/_shared/autosend-policy.yaml` (Reference — runtime table)
- `agents/_shared/hook-helpers.sh` (Reference — runtime helpers)
- `agents/_shared/tests/test-hook-helpers.sh` (Reference — test harness)

All three sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md`. No new master-brief edits required.

## See also

- `docs/decisions/autosend-safety-policy.md` — full tier model + §4 reference impl
- `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 5 — red-tier breach kill criterion
- `agents/_shared/escalation-codes.md` — ESC catalogue
- `docs/build-brief/00-MASTER-BRIEF.md` §8.1 Changes 2+3 — decision-log + ESC vocabulary
- `~/.claude/plans/bubbly-snuggling-lantern.md` — active 5-phase plan
