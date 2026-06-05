# Handoff — 2026-06-05 location shift

**Context:** Founder unplugging Mac mini, moving to location 2. Resume from here.

**HEAD at handoff:** `f1e8e91` (`state(w6-d35): record bootstrap-helper progress`)
**Tree state:** clean (0 uncommitted tracked changes)
**Active /goal:** none firing; previous W5-W6 marathon /goal auto-cleared after 9 hook retries

---

## What was done this session (W6 Day 36 morning)

1. **Discovered `_secrets.env` editor-unsaved buffer bug.** Founder believed file was filled; verified empty multiple times via safe `awk` pattern. Root cause: VS Code unsaved buffer (Cmd+S never pressed). After save, 12 of 26 vars populated.

2. **Bullhorn dev creds unobtainable today** — founder reported the dev portal route isn't accessible. `dd226f4` already shipped the OAuth bootstrap helper (lives in tree for Week 7+ pilot-cred arrival).

3. **W6 plan split** (commit `fc459ca`) — Phase 1 → 1a (Bullhorn; blocked) + 1b (Granola; pending workspace meeting + transport implementation).

4. **Path A discipline incident** — Claude `cat`'d a live `_secrets.env` early in session, exposing 2 keys to chat transcript. Founder rotated both (ANTHROPIC + COMPANIES_HOUSE). Memory `feedback-never-cat-secrets-files` written to prevent recurrence.

5. **Strategic pivot decision** — founder picked **Option X** (Cash Conductor W7-8 prep early): MCP_LIVE_TESTS=1 blocks for `@ifos/xero` + `@ifos/quickbooks` + `@ifos/open-banking` using the real sandbox creds founder DID populate. The Option X /goal text is saved at `docs/operations/pending-goal-w6-d36-cash-conductor-prep.md` (next file) for clean copy-paste at location 2.

## Current credential state in `~/.ifos-local-vault/dev-sandbox/_secrets.env` (verified 12:11)

**SET (12):** ANTHROPIC_API_KEY (rotated), COMPANIES_HOUSE_API_KEY (rotated), XERO_CLIENT_ID + SECRET + DEMO_COMPANY_ORG_ID, QB_CLIENT_ID + SECRET + SANDBOX_REALM_ID, TRUELAYER_CLIENT_ID + SECRET, WORKOS_SECRET_KEY, granola_api_key (unused; wrong format for our code)

**EMPTY (still need):** BULLHORN_* (×6 — blocked, see above), GRANOLA_CLIENT_ID + WORKSPACE_ID (don't fill manually; auto-populated by Phase 1b bootstrap helper), REED_* + CVLIBRARY_* (pending email reply), TELEGRAM_BOT_TOKEN (in shell env; redundant)

## Pickup workflow at location 2 (~10 min total)

### Step 1 — Power on, open Claude Code, verify state

```bash
cd ~/code/CortexOS
echo "CTX_INSTANCE_ID=$CTX_INSTANCE_ID"          # must print: ifos-v2
git status --short                               # should show only `??` untracked
git log --oneline -3                             # should show f1e8e91 as HEAD
```

If HEAD is NOT `f1e8e91`: check if you pushed before unplug + pulled at location 2 (`git status --branch` shows ahead/behind).

### Step 2 — Read this doc, the pending /goal, and confirm direction

```bash
$EDITOR docs/operations/handoff-2026-06-05-location-shift.md      # this file
$EDITOR docs/operations/pending-goal-w6-d36-cash-conductor-prep.md  # the /goal to fire
```

Re-read the /goal text. If still aligned with what you want today, proceed to Step 3. If you've changed your mind (e.g. Bullhorn creds did arrive; or you want Option Y Granola instead), tell Claude what changed before firing anything.

### Step 3 — Fresh Claude Code session

Close any old Claude Code sessions. Open a new one in `~/code/CortexOS`.

Send Claude this orientation message FIRST (do NOT paste with `/goal` prefix):

```
W6 Day 36 resuming after location shift. Tree clean at HEAD f1e8e91. Read docs/operations/handoff-2026-06-05-location-shift.md + docs/operations/pending-goal-w6-d36-cash-conductor-prep.md. Re-verify _secrets.env state (XERO_*/QB_*/TRUELAYER_* should be SET) using awk pattern — NEVER cat (per memory feedback-never-cat-secrets-files). When verified, tell me + I'll paste the /goal as a stop-hook to fire Option X (Cash Conductor W7-8 prep: 3 MCP_LIVE_TESTS=1 blocks + 3 OAuth bootstrap helpers + ≥9 live capability tests).
```

Claude will verify creds, confirm readiness, then you paste the pending /goal text from `docs/operations/pending-goal-w6-d36-cash-conductor-prep.md` as a `/goal` command.

### Step 4 — During the ~9h Option X build

Claude builds + commits per-package atomically. You may need to be at the keyboard 3 times (once per service: Xero, QuickBooks, TrueLayer) to click "Allow" in the browser when the OAuth bootstrap dance opens consent pages. Plan ~5 min of founder time per service.

## Before unplugging — DO THESE NOW

| # | Action | Required? |
|---|---|---|
| 1 | Push 144 commits to origin (GitHub) | **STRONGLY RECOMMENDED** — insurance against hardware loss in transit. Command: `git push origin main` |
| 2 | Close VS Code (saves any open buffers; prevents data loss) | Recommended |
| 3 | Note `HEAD = f1e8e91` somewhere (phone, paper) as belt-and-braces | Optional |
| 4 | Close Claude Code sessions cleanly | Recommended (don't force-quit) |

## What NOT to do

- Don't fire the pending /goal in the current session before unplug (would interrupt mid-build)
- Don't push WIP to origin if you don't want intermediate state public (alternative: push to a branch like `wip/2026-06-05-handoff` then merge later)
- Don't try to power Mac mini back up without giving it ~30 seconds settled after re-plug
- Don't open Claude Code at location 2 until git state is verified per Step 1

---

*End of handoff. Safe to unplug after Step 1 of "Before unplugging" above is complete.*
