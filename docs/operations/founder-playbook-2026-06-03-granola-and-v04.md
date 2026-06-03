# Founder playbook — 2026-06-03 (Granola consent + v0.4 migration)

**For:** Maddox (founder)
**Two tasks, both unblock live-testing:**
1. Connect Granola MCP to your Claude Code (~5 min)
2. Apply v0.4 migration + re-run tenancy audit (~10 min)

**Total time:** ~15 minutes if you do both.
**Path A discipline:** No credentials enter chat. Granola tokens are managed by Claude Code's MCP client automatically; postgres password is entered interactively on the VPS terminal (peer auth = no postgres password ever).

When each task completes, reply with the **exact one-liner** shown at the end. That's how I know to act on the next dependency.

---

## ⚡ TASK 1 — Connect Granola MCP to Claude Code (~5 min)

**Why first:** verifies your Granola Business+ workspace works end-to-end through the official MCP server BEFORE we test the `@ifos/granola` wrapper against it. If this fails, the wrapper would fail too — so we surface that early.

**What this does (and doesn't do):**
- ✅ Adds Granola as an MCP server available to your interactive Claude Code sessions
- ✅ Authenticates via browser OAuth — Claude Code's MCP client handles token capture + refresh automatically
- ✅ Lets you ask Claude Code things like "summarize my last Granola meeting" — proves connectivity + plan tier
- ❌ Does NOT plug into the `@ifos/granola` wrapper yet — that's W5-live wiring (separate dance; needs the tokens to land at a specific vault path which Claude Code's MCP client doesn't expose). This task validates Granola works; the IFOS wrapper integration is W6 work.

### Step 1.1 — Add the MCP server (~1 min)

In ANY terminal (doesn't matter which directory):

```bash
claude mcp add granola --transport http https://mcp.granola.ai/mcp
```

Expected output: a one-line confirmation that the server was added. No browser opens yet.

### Step 1.2 — Restart Claude Code in a fresh terminal (~1 min)

Open a NEW terminal tab/window and start Claude Code:

```bash
cd ~/code/CortexOS
claude
```

(Or wherever you usually start it. The restart is required so Claude Code picks up the new MCP server registration.)

### Step 1.3 — Authenticate (~2 min)

Inside the new Claude Code session, type:

```
/mcp
```

You'll see a list of MCP servers including `granola`. Select it (arrow keys + Enter, or whatever your TUI flow is), then choose **'Authenticate'**.

This opens your default browser at a Granola OAuth consent page. Sign in with your Granola account (the Business+/Paid one), click **Allow**. The browser redirects back to a "you can close this tab" page.

Token capture is automatic from there — Claude Code's MCP client persists the access_token + refresh_token in its own state (not the IFOS vault).

### Step 1.4 — Smoke test (~1 min)

In the same Claude Code session, ask:

```
Using the granola MCP, list my meetings from the last 3 days.
```

**Expected:** Claude calls the `list_meetings` Granola tool and returns a structured list. If you've had meetings transcribed in Granola recently, they appear.

**Optional plan-tier check** — ask:

```
Using the granola MCP, list my meeting folders.
```

If this returns folders, your Paid plan is active (folders are Paid-only per Granola docs). If it returns a 403 / "Paid plan required" error, your workspace isn't on a Paid plan — flag to me and we revisit the wrapper's plan-tier handling.

### Reply with exactly:

```
granola MCP connected; list_meetings works; folders works (Paid confirmed)
```

OR if folders failed:

```
granola MCP connected; list_meetings works; folders failed (Free plan?)
```

OR if anything broke:

```
granola FAILED at step 1.X: <one-line error>
```

---

## ⚡ TASK 2 — Apply v0.4 migration + re-run tenancy audit (~10 min)

**Why:** v0.4 supplement landed in the repo 2026-06-03 (commit `a1bbcf6`). Until the migration is applied to the live VPS, the `validate_tenant_adapters_config_v0_4` trigger doesn't exist — meaning the new 5 keys (`operator_telegram_chat_id`, `email_channel`, `workos_org_id`, `granola_workspace_id`, `bullhorn_corporation_id`) would still hard-fail an UPDATE in production. This is the bridge from "schema in repo" to "schema live."

### Step 2.1 — Pre-flight (~1 min)

From the repo root:

```bash
cd ~/code/CortexOS
echo "CTX_INSTANCE_ID=$CTX_INSTANCE_ID"          # must print: ifos-v2
shellcheck scripts/run-v0.4-migration-as-postgres.sh && echo OK
```

If `CTX_INSTANCE_ID` is empty, run `source .envrc` first.

### Step 2.2 — Dry run (~2 min)

```bash
bash scripts/run-v0.4-migration-as-postgres.sh --dry-run
```

This SSH-probes the VPS + peer-auth-probes postgres, doesn't write anything. You'll be prompted for your **VPS sudo password** (your maddox-user password) when SSH runs commands that need sudo — `postgres` peer auth doesn't need a postgres password.

**Expected output (last few lines):**
```
✓ SSH reachable: maddox@<vps-ip>
✓ postgres peer auth: working passwordless (sudoers NOPASSWD set)
  OR
! postgres peer auth requires sudo password — you will be prompted on the VPS
✓ Re-run without --dry-run to apply
```

If you see any `✗` line, **STOP** and paste the failure to me; I'll triage.

### Step 2.3 — Live apply (~3 min)

Only after dry-run is clean:

```bash
bash scripts/run-v0.4-migration-as-postgres.sh
```

The migration is wrapped in `BEGIN ... COMMIT` with `ON_ERROR_STOP=1` — any failure rolls back atomically. Safe to retry.

**Expected output (last few lines):**
```
✓ Migration applied successfully
✓ trigger_v0_4 = 1
✓ trigger_v0_3_gone = 0 (replaced)
✓ function_v0_4 = 1
✓ function_v0_3_gone = 0 (dropped)
✓ v0.4 migration applied as postgres; trigger v0_4 active; v0_3 cleaned up
```

### Step 2.4 — Run tenancy audit (~3 min)

```bash
bash scripts/run-tenancy-audit.sh
```

This uses `ifos_app` via SSH tunnel and asks you for the **ifos_app password** (in 1Password as "IFOS Postgres ifos_app — production" or similar — same as you used for v0.3).

**Expected output (last few lines):**
```
T1-T12 invariants: 12/12 PASS
v0.4 allowlist trigger: validated
```

If T12 false-positives surface again, refer to the W4 Phase C heuristic refinements (already landed in the script).

### Reply with exactly:

```
v0.4 applied; tenancy audit 12/12
```

OR if anything broke:

```
v0.4 FAILED at step 2.X: <one-line error>
```

---

## What happens after both tasks reply green

- **Task 1 green:** unblocks W5-live planning for `@ifos/granola` wrapper integration tests. I'll write the W6 wiring playbook when we get there.
- **Task 2 green:** flips Action Board item 14 from ⏸ to ✅; unblocks the W6 author from writing `@ifos/janitor` tools.yaml validation against live schema.
- **Both green:** W5 Day-31 (Janitor bundle scaffold) is unblocked with maximum confidence. The /goal I drafted is ready to fire whenever you are.

---

## What to do if Task 1 fails

If Claude Code can't add the MCP server or the OAuth flow breaks:

1. **First check:** is your Claude Code CLI current? `claude --version`. MCP-add support requires recent versions.
2. **Second check:** is Granola itself working? Open `app.granola.ai` in browser — does it load? Are your meetings there?
3. **Third check:** does your Granola account have MCP enabled? Some workspaces require enabling MCP in account settings before the OAuth flow works.

If all three check out and it still fails, paste the exact error to me.

## What to do if Task 2 fails

If the migration apply fails mid-flight:

1. **Atomic rollback already happened** — the `BEGIN ... COMMIT` wrap + `ON_ERROR_STOP=1` ensures nothing partial landed on the VPS.
2. **The local repo state is unchanged** — no rollback needed locally.
3. **Paste the exact error** to me. Likely cause is either a v0.3 prerequisite drift (something in production state differs from the migration's expectation) or a network/SSH glitch (just re-run).

The companion rollback script `migrations/v0.4-to-v0.3.sql` exists if v0.4 needs to be reverted post-apply, but that's a separate "if shit hits fan" operation — not part of this normal-path playbook.
