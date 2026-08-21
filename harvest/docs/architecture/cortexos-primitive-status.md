# cortextOS primitive status — Week 0 Day 1 audit

**Date:** 2026-05-16 (Week 0, Day 1)
**Status:** Reference (Week-0 audit of cortextOS submodule at pinned SHA; no Proposed/Accepted lifecycle).
**Audited SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383` (`packages/harness/cortextos/` reference pin, per `packages/harness/PINNED-SHA.md`)
**Package manifest:** `cortextos@0.1.1` (npm), but CHANGELOG shows `0.2.0` work landed (External Persistent Crons) — the version field has drifted; the audit reflects the actual code at the pinned SHA.
**Method:** read code under `src/daemon/`, `src/pty/`, `src/bus/`, `src/telegram/`, `src/cli/`; cross-reference with `README.md`, `CHANGELOG.md`, `CRONS_MIGRATION_GUIDE.md`, `templates/{orchestrator,analyst,agent,m2c1-worker,agent-codex}/`; line-cite `tests/unit/**` and `tests/integration/**`; cross-check Day-0 findings in `.agents/learnings/00-cortextos-quirks.md`; classify per the four-status scheme from master brief §6 Day 1.

Two findings need founder review before the Day 7 single-sentence test (master brief §6 / Ultraplan §12). Both are master-brief drifts against the verified SHA, surfaced in Primitive 3:

1. **No `chokidar` watcher in the bus** — master brief §2.4 row 3 says "bus/ shell wrappers + chokidar watcher in daemon", but the bus is poll-based (`FastChecker` default 1000ms). `chokidar` is only used by the dashboard's UI file-feed.
2. **The four `bus/kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 names `kb-search.sh / kb-add.sh / kb-update.sh / kb-list.sh`. The actual files at SHA `c21fbfe` are `kb-collections.sh / kb-ingest.sh / kb-query.sh / kb-setup.sh`. The brain-replacement seam (§3.4 + §5) needs reconciliation before Codex ratification.

Both are details, not blockers — but they are exactly the kind of spec drift the Day 7 test exists to surface.

---

## Summary table

| # | Primitive | Status | v1.0 dependency |
|---|---|---|---|
| 1 | Persistent PTY via PM2 | **shipped but flaky** | Cash Conductor (A4), Concierge (A6) |
| 2 | 71-hour context rotation | **shipped and tested** | Concierge (A6) |
| 3 | Inter-agent file bus | **shipped and tested** (with two master-brief drifts) | None in v1.0; load-bearing for v1.1 Brief Decoder |
| 4 | Approval gates | **shipped and tested** | Cash Conductor (A4), Concierge (A6); standing-auth not in cortextOS — IFOS-layer concept |
| 5 | Telegram + iOS approval surface | **shipped and tested** (Telegram); **aspirational** (iOS) | Every Tier-1 agent's escalation path |
| 6 | Overnight autoresearch (theta wave) | **shipped and tested** | None in v1.0; v1.1 Night Sourcer |
| 7 | Multi-agent orchestrator | **shipped and tested** | None in v1.0; v1.1 Brief Decoder |

**Day 7 §6 Q2 read** ("Does the CortexOS submodule give us primitives 1, 4, and 5 working today?"): **all three are present and tested, but Primitive 1 carries real Day-0 brittleness via quirks 2 and 3 plus a prior production restart-storm.** Direct live verification on our `ifos-v2` install — running the verification commands in each section — closes the gap before answering Q2 with a confident yes.

---

## Primitive 1 — Persistent PTY via PM2

**Master-brief description:** `node-pty` + `ecosystem.config.js` regen via `cortextos ecosystem`; agents run as PM2-managed PTY processes that auto-restart on crash or after the 71-hour context rotation (master brief §2.4 row 1).

**Status:** `shipped but flaky`

The code is real, well-instrumented, and the agent-process layer has unit tests with substantial regression coverage. It does not earn "shipped and tested" because (a) there is no direct unit test of `AgentPTY.spawn()` against the real `node-pty` binding, (b) Day-0 setup surfaced two concrete production-class quirks against this primitive (node-pty Node 25+ ABI breakage, npm-link PATH conflict), and (c) `ecosystem.config.js:42-46` cites a real "2026-04-22 restart storm" that required structural hardening (BUG-011, BUG-032, BUG-040, BUG-048 fixes are still visible as defence-in-depth in `agent-process.ts`).

**Evidence (code):**

- `packages/harness/cortextos/src/pty/agent-pty.ts:31-189` — `AgentPTY` class. Lazy-loads `node-pty` at line 59-61 (`const nodePty = require('node-pty'); this.spawnFn = nodePty.spawn;`), spawns the `claude` binary directly in a 200×50 xterm-256color PTY at line 146-152, wires `onData` → `OutputBuffer` and `onExit` → handler, and includes the "trust this folder?" auto-accept at lines 173-188 (sends `\r` at 5s and 8s after spawn).
- `packages/harness/cortextos/src/daemon/agent-process.ts:21-720` — `AgentProcess` orchestrates the full lifecycle. Notable hardening visible in the code: BUG-040 lifecycle-generation guard (`agent-process.ts:111` and `:142-146`), BUG-032 CRLF + 5s wait on `/exit` graceful shutdown (`:227-231`), BUG-011 exit-promise race fix (`:133-152, :248-256`), BUG-048 stale-config session-timer re-read (`:611-636`). Crash recovery uses exponential backoff capped at 5 minutes (`:437`), `max_crashes_per_day` default 10 (`:28`), halts the agent after exceeded.
- `packages/harness/cortextos/src/daemon/index.ts:30-214` — daemon-level crash plumbing. `recordCrash` / `shouldSendCrashLoopAlert` / `writeDaemonCrashedMarkers` form the crash-loop detector (3 crashes in 15 min triggers a Telegram alert with 30-min cooldown, `:34-36`). PM2's `max_restarts: 10` in `ecosystem.config.js:47` is the circuit breaker beyond it.
- `packages/harness/cortextos/ecosystem.config.js:14-51` — daemon script entry, env-driven, `autorestart: true`, `max_restarts: 10`, `restart_delay: 5000`. The 35-line comment block above `max_restarts` explicitly names the 2026-04-22 storm and warns against raising the values without strengthening the upstream fix.
- `packages/harness/cortextos/package.json:48` — `node-pty: ^1.1.0` runtime dep; `engines.node: ">=20.0.0"`.

**Tests cited:**

- `tests/unit/daemon/agent-process.test.ts` (348 lines) — `AgentPTY` is mocked (lines 6-19 inject a vi-mocked PTY); tests cover start/stop/crash/restart and the BUG-040 generation-guard logic.
- `tests/unit/daemon/crash-handlers.test.ts` (183 lines) — daemon-level crash history, crash-loop threshold, marker writes.
- `tests/unit/pty/output-buffer.test.ts` (116 lines) — PTY output buffering only, no spawn path.
- `tests/unit/pty/inject.test.ts` (93 lines) — message-injection-into-PTY layer.
- `tests/e2e/lifecycle.test.ts` (282 lines) — name is misleading; the file's imports (bus message/task/event/heartbeat/approval) show it exercises the file-bus lifecycle, **not** PTY spawn. No `AgentPTY` import.
- **No `agent-pty.test.ts` exists.** The integration between `AgentPTY` and the real `node-pty` native binding is not unit-tested in the submodule.

**IFOS dependency:**

- Master brief §2.4 row 1: used by Triage, Concierge, Pulse, Watchtower, Cash Conductor.
- §8.2 v1.0 build order: **A4 Cash Conductor (Tier 1, weeks 7-8)** and **A6 Concierge (Tier 1, weeks 9-10)** require it.
- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
- v1.1: A7 Inbound Triage, A10 Competitor Interception, A11 Night Sourcer (with primitive 6), A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all require it.

**Risk if flaky:** Tier-1 always-on agents collapse to scheduled cron with cold-start latency, eliminating the "sub-second to first useful action" claim that justifies pricing the Triage/Concierge/Pulse demos above point-tool parity (Ultraplan §3.2). Per Ultraplan §3.1 row 1, the documented contingency is: "Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving." Quirk 2 (`.agents/learnings/00-cortextos-quirks.md`) — `node-pty` requires `npm rebuild` on Node 25+ — is the most likely re-trip wire because the Mac Studio cluster nodes for the v2.0 Sovereign tier may not run Node 22 LTS by default.

**Verification method (against our `ifos-v2` instance):**

```bash
# 1. Prereq + binding check
cortextos-ifos doctor                    # confirms node-pty, PM2, claude on PATH
node -e "require('node-pty').spawn"      # explicit binding probe; throws if rebuild needed

# 2. Spawn + survive crash test (requires a test agent)
cortextos-ifos init test-org
cortextos-ifos add-agent probe --template agent --org test-org
cortextos-ifos ecosystem                 # writes ecosystem.config.js
pm2 start ecosystem.config.js
cortextos-ifos status                    # 'probe' must show status=running with a PID
ls ~/.cortextos/ifos-v2/state/probe/heartbeat.json   # heartbeat written within 60s

# 3. Crash-loop detector live-fire (debug build)
CTX_DEBUG_ALLOW_CRASH_TRIGGER=1 pm2 restart ifos-daemon
for i in 1 2 3; do kill -SIGUSR2 $(pm2 pid ifos-daemon); sleep 5; done
ls ~/.cortextos/ifos-v2/state/.daemon-crash-history.json
# Verify Telegram operator chat received "🚨 CRITICAL: cortextos daemon is crash-looping"

# 4. PATH conflict check (quirk 3 — bus commands from inside the PTY must resolve to cortextos-ifos)
pm2 logs ifos-daemon --lines 200 | grep -E 'spawn .*cortextos'   # must not show plain 'cortextos'
```

---

## Primitive 2 — 71-hour context rotation

**Master-brief description:** The daemon auto-restarts a session before the context limit; pre-rotation hook checkpoints state to vault (master brief §2.4 row 2).

**Status:** `shipped and tested`

Two complementary mechanisms ship: a wall-clock session timer at exactly 71 hours (255600s) plus a context-percentage tiered handoff system that fires earlier when actual token usage crosses configurable thresholds. Both have regression-named bug fixes and dedicated test files. No Day-0 brittleness evidence.

**Evidence (code):**

- `src/daemon/agent-process.ts:597-639` — `startSessionTimer()`. `DEFAULT_MAX_SESSION_S = 255600` (line 598) is exactly 71 × 3600. Timer fires `sessionRefresh()` at line 634. BUG-048 fix (line 607-636) re-reads `max_session_seconds` from disk on each timer tick so config edits take effect; `MAX_SETTIMEOUT_MS = 2_147_483_647` clamp at line 603 prevents int32-overflow infinite-loop wedge.
- `src/daemon/agent-process.ts:269-283` — `sessionRefresh()` is `stop() + start()`. `shouldContinue()` at line 454 returns true if a `.jsonl` conversation file exists under `~/.claude/projects/<launchdir>/`, so the refresh resumes with `--continue` (passes `--continue` flag at `agent-pty.ts:228`).
- `src/daemon/fast-checker.ts:899-1003` — `checkContextStatus()` polls `${stateDir}/context_status.json` written by the `hook-context-status` statusLine bridge. Three tiers: Tier 1 warning at `ctx_warning_threshold` default 70% injects `[CONTEXT] Window at X%`, Tier 2 handoff at `ctx_handoff_threshold` default 80% writes the handoff prompt and `.force-fresh` marker (line 996-1000), Tier 3 force-restart 5 minutes after Tier 2 if the agent didn't comply (line 962-967).
- `src/daemon/fast-checker.ts:947-952` — PTY-output regex `/extra usage.*?1[Mm] context|conversation too long.*?compaction/i` is the API-overflow last-resort trigger; bypasses thresholds and force-restarts immediately.
- `src/daemon/fast-checker.ts:898-908` — circuit breaker (`ctxCircuitRestarts`, `ctxCircuitBrokenAt`) pauses auto-restarts for 30 minutes if context-triggered restarts pile up (persisted to disk so it survives `--continue` restarts per line 994).
- `src/daemon/agent-process.ts:454-492` — `shouldContinue()` checks for `.force-fresh` marker first and deletes it (line 466-469); this is how the context handoff path forces a fresh session.

**Tests cited:**

- `tests/unit/daemon/agent-process.test.ts:234-348` — `sessionRefresh()` delegation order (line 234), 1-second timer fires (line 254), config-on-disk reschedule for longer durations (line 270), and the int32-setTimeout overflow regression (line 305).
- `tests/unit/daemon/fast-checker.test.ts` — 859 lines covering the poll loop and context monitor.
- `tests/unit/daemon/context-monitor.test.ts` — 223 lines, dedicated context-monitor unit tests.

**IFOS dependency:**

- Master brief §2.4 row 2: Concierge (cross-week candidate conversations), Watchtower (per-contractor state), Pulse (multi-source watching).
- v1.0 build: **A6 Concierge** (master brief §8.2, weeks 9-10) holds candidate-lifecycle state across days; loses context-rollover gracefulness if this primitive fails.
- v1.1+: A7 Inbound Triage, A12 T5 Supply Chain Auditor, A13 T3 Compliance Watchtower all carry per-entity state across many days.

**Risk if flaky:** Concierge loses cross-week candidate conversation context at the 71-hour boundary or at API overflow; rejection drafts lose the prior-state nuance that defines Gate A voice quality on the hardest test case (Ultraplan §8.1 A6 gotcha: "Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship"). Per Ultraplan §3.1 row 2, the documented contingency is: "Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement."

**Verification method (against our `ifos-v2` instance):**

```bash
# 1. Wall-clock rotation (trim to 60s for a live test)
cortextos-ifos add-agent rot-probe --template agent --org test-org
echo '{"max_session_seconds": 60}' > ~/.cortextos/ifos-v2/orgs/test-org/agents/rot-probe/config.json
pm2 restart ifos-daemon
pm2 logs ifos-daemon | grep "Session timer fired"          # within ~60s
pm2 logs ifos-daemon | grep "Session refresh (--continue restart)"

# 2. Context-percentage handoff (Tier 2)
mkdir -p ~/.cortextos/ifos-v2/state/rot-probe
cat > ~/.cortextos/ifos-v2/state/rot-probe/context_status.json <<EOF
{"used_percentage": 81, "exceeds_200k_tokens": false, "written_at": "$(date -u +%FT%TZ)", "session_id": "test"}
EOF
# Set thresholds in config.json: ctx_handoff_threshold: 80
sleep 5
ls ~/.cortextos/ifos-v2/state/rot-probe/.force-fresh        # must exist
pm2 logs ifos-daemon | grep "Handoff prompt injected"

# 3. Tier 3 force-restart (deadline)
# After Tier 2 fires, wait 5 minutes without acting; expect "Handoff deadline exceeded — force restarting"

# 4. Circuit breaker
# Trigger Tier 3 more than the threshold within 15 min; expect "Context circuit breaker reset after 30min pause"
```

---

## Primitive 3 — Inter-agent file bus

**Master-brief description:** `bus/` shell wrappers + `chokidar` watcher in the daemon; agents drop typed files for inter-agent handoff (master brief §2.4 row 3).

**Status:** `shipped and tested`

The bus is real, well-tested at unit and integration layers, with HMAC-SHA256 message signing and a documented 3-directory lifecycle. However, **two pieces of the master-brief description are wrong against the verified SHA `c21fbfe`** — flagged below; both affect the brain-replacement boundary (§3.4) and need founder review before Day 7.

**Evidence (code):**

- `bus/` directory holds 47 shell wrappers (e.g. `bus/send-message.sh`). Each is a thin shim that execs `node ${SCRIPT_DIR}/../dist/cli.js bus <command> <args>` — confirmed by reading `bus/send-message.sh:1-23`.
- `src/bus/message.ts:51-88` — `sendMessage()` writes JSON atomically to `${ctxRoot}/inbox/<to>/{pnum}-{epochMs}-from-{sender}-{rand5}.json`; `pnum` encodes priority for filesystem-native sort (`urgent=0 high=1 normal=2 low=3`).
- `src/bus/message.ts:96-164` — `checkInbox()` is the receive path: acquire lock → recover stale inflight (>5 min back to inbox, line 108 + 200-225) → readdir + sort → HMAC verify → move inbox → inflight → return parsed messages. Corrupt or invalid-sig messages quarantine to `.errors/`.
- `src/bus/message.ts:170-195` — `ackInbox()` moves the matching file from `inflight/` to `processed/`.
- `src/bus/message.ts:19-44` — HMAC-SHA256 signing using `${ctxRoot}/config/bus-signing-key`. Quirk 5 in `.agents/learnings/00-cortextos-quirks.md` confirms each instance has its own key (IFOS and Personal have separate HMAC keys).
- `src/daemon/fast-checker.ts:75` — poll interval defaults to 1000ms. **This is the actual bus dispatcher**: every 1 second, fast-checker calls `checkInbox(paths)` and injects messages into the PTY via `injectMessage`. There is no filesystem watcher in this path.

**Tests cited:**

- `tests/unit/bus/message.test.ts` (142 lines) — send/receive/ack round-trip, priority sort, inbox→inflight→processed lifecycle, stale-inflight recovery, HMAC sign/verify path.
- `tests/integration/multi-agent-crons.test.ts` (922 lines) — multi-agent bus traffic with cron-driven handoff.
- `tests/integration/codex-bus-roundtrip.test.ts` (137 lines) — cross-runtime bus.
- `tests/integration/codex-handoff-lifecycle.test.ts` (165 lines) — Codex agent handoff via bus.
- `tests/e2e/lifecycle.test.ts` (282 lines) — full bus lifecycle: send → checkInbox → ackInbox round-trip with real temp dirs.

**Two master-brief spec corrections (surface for Day 7 founder review):**

1. **No `chokidar` watcher in the bus.** The bus is poll-based, not push-based. `grep -rn chokidar src/` returns zero hits; `chokidar@^5.0.0` in `package.json:47` is used only by `dashboard/src/lib/watcher.ts:5` for the dashboard UI's file change feed, not for inter-agent message delivery. Master brief §2.4 row 3's "chokidar watcher in daemon" is incorrect against the verified SHA. The actual dispatcher is `FastChecker` polling at `pollInterval` (default 1000ms, configurable). Operational impact: message-delivery latency is bounded by the poll interval, not zero-latency event-driven; relevant for the Brief Decoder → Sourcing Scout → Concierge "four-agent pipelines complete in seconds" claim (Ultraplan §3.2). With 1s polling per hop and 3 hops, end-to-end is ≥3s, not sub-second.

2. **The four `kb-*.sh` files we plan to shadow have different names than the master brief states.** Master brief §3.4 lists `kb-search.sh`, `kb-add.sh`, `kb-update.sh`, `kb-list.sh`. The actual files at `packages/harness/cortextos/bus/` are `kb-collections.sh`, `kb-ingest.sh`, `kb-query.sh`, `kb-setup.sh`. This is the brain-replacement seam — the master brief's named files do not exist at SHA `c21fbfe`. Either the brief was written against a different cortextOS version, or the four shadow points need to be revised. This is a Day-7 Codex-ratification-blocking discrepancy.

**IFOS dependency:**

- Master brief §2.4 row 3: "Our agents drop typed files into the bus; we override `kb-*` to point at the wiki". §3.4 brain-replacement boundary is built on these shadow points.
- §8.2 v1.1: A8 **Brief Decoder** is the load-bearing test of the file bus + handoff to Sourcing Scout → Concierge (Ultraplan §3.1 row 3: "This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2"). v1.0 agents don't strictly depend on the bus for inter-agent handoff — but they do depend on it for KB read/write.

**Risk if flaky:** Brief Decoder → Sourcing Scout → Concierge pipeline (master brief §2.4 row 7) cannot complete in seconds; falls back to manual queue or scheduled cron, killing the "shortlist in 15 minutes" Sourcing Scout pitch. Separately, the brain-replacement boundary (§3.4 / §5) depends on the exact set of shadow points — until the file-name discrepancy is reconciled, our overrides won't intercept the correct calls and the wiki swap-out won't work.

**Verification method (against our `ifos-v2` instance):**

```bash
# 1. Round-trip with two agents
cortextos-ifos add-agent alice --template agent --org test-org
cortextos-ifos add-agent bob   --template agent --org test-org

cortextos-ifos bus send-message bob normal "hello from alice" --from alice
ls ~/.cortextos/ifos-v2/inbox/bob/    # must contain a 2-*-from-alice-*.json

# 2. HMAC verify
cat ~/.cortextos/ifos-v2/config/bus-signing-key   # must exist; non-empty
# tamper with the message text in inbox/bob/*.json, then trigger alice→bob delivery:
# expect to see "[bus/message] SECURITY: ... failed HMAC verification — rejecting"
# and the file moves to inbox/bob/.errors/

# 3. Stale-inflight recovery
mkdir -p ~/.cortextos/ifos-v2/inflight/bob
touch -t 197001010000 ~/.cortextos/ifos-v2/inflight/bob/3-*-from-alice-*.json   # set mtime to epoch
# next checkInbox by bob's fast-checker should move it back to inbox/

# 4. Confirm poll-based dispatch (no chokidar)
ps -ef | grep -i chokidar         # no daemon process should be watching
pm2 logs ifos-daemon --lines 200 | grep -iE "poll|tick|checkInbox"

# 5. Brain-replacement seam file-name reconciliation
diff <(ls packages/harness/cortextos/bus/kb-*.sh | xargs -n1 basename) \
     <(printf 'kb-add.sh\nkb-list.sh\nkb-search.sh\nkb-update.sh\n')
# this WILL show diff; that diff IS the spec issue that needs reconciliation
```

---

## Primitive 4 — Approval gates

**Master-brief description:** Daemon enforces explicit approval before external action; `manualFireDisabled` flag on crons; standing authorisations per agent (master brief §2.4 row 4).

**Status:** `shipped and tested`

Per-approval per-action gates ship and are tested; the `manualFireDisabled` flag is enforced at the IPC layer; Telegram inline-button approve/deny round-trip is wired end-to-end; visible production hardening points to prior incidents that have been remediated. **Standing authorisations** (the "auto-approve category X for the next 24h" idea from §2.4) is **NOT** a cortextOS primitive — it's an IFOS-layer concept we'd build on top.

**Evidence (code):**

- `src/bus/approval.ts:178-229` — `createApproval()` writes JSON to `${approvalDir}/pending/approval_<epoch>_<rand5>.json`; fan-out to activity-channel Telegram with inline `[Approve][Deny]` buttons (line 220) and a best-effort ping to the requesting agent's own Telegram bot (line 226). The two awaits are deliberate — the comment at line 213-219 explains why short-lived CLI callers must await the fetch.
- `src/bus/approval.ts:235-270` — `updateApproval()` moves the JSON `pending/` → `resolved/`, then notifies the requesting agent via an inbox bus message at line 265 (priority `urgent`, sender `system`).
- `src/bus/approval.ts:18-25` — `buildApprovalKeyboard()` produces the inline keyboard `{callback_data: appr_allow_<id> | appr_deny_<id>}`. `src/daemon/fast-checker.ts:454-552` routes those callbacks back through the activity-channel poller, enforcing `ALLOWED_USER` at line 552 (`SECURITY: callback from unauthorized user ... - rejecting`).
- `src/daemon/ipc-server.ts:62-115` — `handleFireCron` enforces the `manualFireDisabled` opt-out at line 86-89: returns `{ok:false, error: 'Manual fire disabled for this cron.'}` and a separate 30-second cooldown via `manualFireCooldownRemaining` at line 91.
- `src/types/index.ts:398` — `manualFireDisabled?: boolean` typed on the cron definition.
- `src/bus/task.ts:68` and `src/types/index.ts:46` — `needs_approval` flag on tasks, the upstream of the workflow.
- `README.md:159-161` — explicit claim: "cortextOS has undergone a dedicated security hardening sprint covering prompt injection resistance, guardrail enforcement, and approval gate integrity. Agents require explicit human approval before any external action (email, deploy, delete, financial)."
- Production-incident evidence in code comments:
  - `src/bus/approval.ts:34-42` — path-resolution bug "that hid for hours because of the silent `.catch` below"; fix removed silent fallback, surfaces misconfiguration loudly now.
  - `src/bus/approval.ts:101-107, 222-226` — "the 50h+ Repo-B-style stall" where operators on per-agent bots missed approvals because only the activity-channel was pinged; fix adds per-agent ping.

**Tests cited:**

- `tests/unit/bus/approval.test.ts` (432 lines) — create/update/list pending/resolved flow, HMAC where applicable, category validation.
- `tests/unit/daemon/ipc-fire-cron.test.ts` — explicit `manualFireDisabled` enforcement test and cooldown enforcement.
- `tests/unit/daemon/ipc-mutations.test.ts` — IPC `add-cron` / `update-cron` permission paths.

**IFOS dependency:**

- Master brief §2.4 row 4 + §3.4 + Product Spec §6.1 row 4: every agent that auto-sends. Triage, Concierge, Cash Conductor, Competitor Interception, Spec Pitcher, T1 Onboarding Concierge — all depend on the approval gate to graduate from drafts-only.
- v1.0: A4 Cash Conductor (chase email + escalation tier) and A6 Concierge (auto-send acknowledge-new-candidate at Boutique+). Per Ultraplan §10 Risk #9, "A consultant complains about auto-send tone within first 2 weeks → Auto-send paused immediately for that tenant" — the approval gate is the kill-switch.
- v1.1: A7 Inbound Triage's auto-send is the most dangerous; per Ultraplan §8.2 A7 gotcha: "Misclassification of a complaint as a routine inbound is a relationship killer."

**Risk if flaky:** Every Tier-1 auto-send agent collapses to drafts-only — the documented v1.0 Risk-#1 contingency (Ultraplan §3.5: "Every Tier 1 agent has a 'degraded mode' fallback (drafts-only, no auto-send, scheduled retry) that runs if cortextOS state is unhealthy"). Loses the Triage and Cash Conductor closing demos but does NOT kill v1.0.

**Verification method (against our `ifos-v2` instance):**

```bash
# 1. End-to-end approval round-trip
cortextos-ifos bus create-approval test-org probe-agent \
  --title "test send" --category external-comms \
  --context "this is a test"
# expect: approval_<epoch>_<rand>.json in ~/.cortextos/ifos-v2/orgs/test-org/approvals/pending/
# expect: Telegram activity channel receives "🔔 Approval request: test send" with [✅ Approve][❌ Deny] buttons
# tap Approve in Telegram → file moves to resolved/, requesting agent's inbox gets urgent system message

# 2. manualFireDisabled enforcement
cortextos-ifos bus add-cron probe-agent never-manual 1h "test prompt" \
  --manual-fire-disabled
# from dashboard /workflows/probe-agent/never-manual, press Test Fire button
# expect HTTP 403 + UI message "Manual fire disabled for this cron"

# 3. Unauthorized callback rejection
# craft a Telegram callback_query payload from a non-ALLOWED_USER id, hit the bot webhook
# expect: pm2 logs show "SECURITY: activity-channel callback from unauthorized user X - rejecting"

# 4. Standing-authorisation gap test (proves it is NOT a cortextOS feature)
grep -rn "standing.auth\|standing_authoris\|standing-auth\|stand.*approval" \
  packages/harness/cortextos/src/
# expect: zero hits — confirms we build standing-auth in our layer
```

---

## Primitive 5 — Telegram + iOS approval surface

**Master-brief description:** Bot per agent, `.env` carries `BOT_TOKEN / CHAT_ID / ALLOWED_USER`; the escalation path for every Tier-1 agent (master brief §2.4 row 5).

**Status:** `shipped and tested` (Telegram); **iOS surface is aspirational**

Telegram is mature, hardened, and well-tested. iOS is explicitly "coming soon" in the README and has no APNs/push-notification code path — only an `outbound-messages.jsonl` log shape that a future iOS app would consume. Ultraplan §3.1 row 5 already accepts iOS deferral to v1.2, so this is not a v1.0 blocker.

**Evidence (code):**

- `src/telegram/api.ts` (620 lines) — full Bot API client. `validateCredentials()` (line 14-75) catches four named failure modes upfront: `bad_token` (401 on `getMe`), `chat_not_found` (400 on `getChat`), `chat_is_bot`, and the `self_chat` trap (line 71-74: `CHAT_ID matches the bot's own user ID. You likely pasted the BOT_TOKEN prefix instead of your real chat_id`). Never leaks `BOT_TOKEN` in error messages.
- `src/telegram/poller.ts` (196 lines) — `TelegramPoller` polls `getUpdates` every 1s by default, persists offset to `.telegram-offset[-<suffix>]`. The offset-suffix mechanism (line 41-47) lets two pollers coexist in one `stateDir` — used to run an activity-channel bot alongside per-agent bots without offset clobbering.
- `src/daemon/fast-checker.ts:454-552` — callback handling enforces `ALLOWED_USER` at line 468 and 552 (`SECURITY: callback from unauthorized user ${fromUserId} - rejecting`). `appr_allow_<id>` / `appr_deny_<id>` callback routing for the approval-gate UX from primitive 4.
- `src/telegram/transcribe.ts` (137 lines) + `src/telegram/media.ts` (217 lines) — voice-note transcription and image/document handling — past the "approval surface" minimum but indicates the surface is production-grade for general agent comms.
- Per-agent `.env` contract from `README.md:82-87`: `BOT_TOKEN`, `CHAT_ID`, `ALLOWED_USER`. Agent .env loaded by `agent-pty.ts:100-111` before spawn; values surface as env vars to the PTY child.
- `bus/_telegram-curl.sh` exists as a fallback path for shell-side telegram sends.

**iOS evidence (aspirational):**

- `README.md:33` — "Native iOS app coming soon."
- `src/cli/bus.ts:1644` is the **only** iOS reference in the entire src tree: writes a `mobile-reply` entry to `${ctxRoot}/logs/<agent>/outbound-messages.jsonl` so a future "iOS app chat history" can consume it. There is no APNs client, no push-notification subscription, no iOS-specific routing. The JSONL shape is forward-compatibility scaffolding.

**Tests cited:**

- `tests/unit/telegram/api.test.ts` (325 lines) — credential validation, self-chat trap, send/post/getUpdates round-trips.
- `tests/unit/telegram/poller.test.ts` (225 lines) — offset persistence, two-poller suffix coexistence.
- `tests/unit/telegram/send-message.test.ts` (277 lines).
- `tests/unit/telegram/media.test.ts` (263 lines).
- `tests/unit/telegram/logging.test.ts` (281 lines).
- `tests/unit/telegram/transcribe.test.ts` (92 lines).
- No iOS-surface tests (because no iOS surface).

**IFOS dependency:**

- Master brief §2.4 row 5: every Tier-1 agent's escalation path. Triage, Concierge, Cash Conductor, Pulse, Watchtower, Brief Decoder, Competitor Interception, Night Sourcer, T5, Timesheet Ranger — they all escalate via Telegram and approve via Telegram inline buttons.
- Product Spec §6.1 row 5: "Telegram + iOS approval surface — every Tier 1 agent's escalation path."
- Day-0 already verified: per `.agents/current-priorities.md` and quirks file, the personal install's dashboard credentials are at `~/.cortextos/default/dashboard.env`, IFOS at `~/.cortextos/ifos-v2/dashboard.env`; agent `.env` is the per-agent Telegram credential.

**Risk if flaky:** Telegram alone covers v1.0; iOS deferral is already an accepted decision per Ultraplan §3.1 row 5 ("iOS in v1.2 is the marketing line, not a tech blocker"). Real risk is Telegram outage during a Cash Conductor escalation, which is exactly what the activity-channel + per-agent-bot belt-and-braces pattern (primitive 4 evidence, `approval.ts:222-226`) was built to mitigate after the "50h+ Repo-B-style stall" incident.

**Verification method (against our `ifos-v2` instance):**

```bash
# 1. Bot credential validation — catches the four failure modes
cortextos-ifos doctor                          # walks each agent's .env, hits getMe + getChat
# expect: ✅ for each agent's BOT_TOKEN + CHAT_ID + ALLOWED_USER

# 2. Send + callback round-trip
cortextos-ifos add-agent tg-probe --template agent --org test-org
cat > ~/.cortextos/ifos-v2/orgs/test-org/agents/tg-probe/.env <<EOF
BOT_TOKEN=<bot-token>
CHAT_ID=<your-chat-id>
ALLOWED_USER=<your-user-id>
EOF
pm2 restart ifos-daemon
# From Telegram: send "test" to tg-probe's bot → expect agent acknowledges in chat
# From dashboard: create an approval for tg-probe → expect activity-channel inline buttons

# 3. Unauthorized callback rejection (security)
# Use a second Telegram account NOT in ALLOWED_USER; tap an approval button
# expect: button does nothing; pm2 logs show "SECURITY: callback from unauthorized user X - rejecting"

# 4. Two-poller offset coexistence
ls ~/.cortextos/ifos-v2/state/tg-probe/.telegram-offset*
# expect: at least one offset file; if activity-channel bot is configured for the org,
# expect: .telegram-offset-activity present alongside .telegram-offset

# 5. iOS aspirational proof
grep -rn "apns\|push.notification" packages/harness/cortextos/src/   # zero hits
grep -rn "outbound-messages.jsonl" packages/harness/cortextos/src/   # one hit at cli/bus.ts:1644
```

---

## Primitive 6 — Overnight autoresearch (theta wave)

**Master-brief description:** Analyst-template agents schedule overnight experiments, evaluate results, surface findings for review (master brief §2.4 row 6).

**Status:** `shipped and tested`

Full experiment lifecycle code, dedicated sprint-3 test file, fully-documented 8-phase theta-wave skill shipped in the `analyst` template. Approval-gate integration ties it back into primitive 4. Not on the v1.0 critical path — Ultraplan §3.1 row 6 already defers it to v1.1 Night Sourcer.

**Evidence (code):**

- `src/bus/experiment.ts` (542 lines) — `Experiment` type at line 8-28 with full lifecycle fields (status `proposed | running | completed`, decision `keep | discard | null`, baseline/result values, hypothesis, surface, direction, window, measurement, learning). `ExperimentCycle` type at line 66-79 carries the recurring-experiment cron metadata (`loop_interval`, `enabled`, `created_by`). `ExperimentConfig.theta_wave` config block at line 81-94 with `enabled / interval / metric / auto_create_agent_cycles / auto_modify_agent_cycles` toggles.
- CHANGELOG §"Experiment System (Theta Wave)" lines 150-160 confirms shipped functions: `createExperiment`, `runExperiment`, `evaluateExperiment`, `manageCycle`, `loadExperimentConfig`. Approval-gate integration: `experiments/config.json` with `approval_required: true` makes `create-experiment` auto-create an approval and block until approved.
- `templates/analyst/.claude/skills/theta-wave/SKILL.md` (156 lines) — fully fleshed-out 8-phase cycle (Initiate → Deep System Scan → Evaluate Previous → Evaluate Agent Cycles → External Research → Conversation with Orchestrator → Hypothesis and Action → Score+Log+Report). References `cortextos bus manage-cycle create/modify/remove` for cycle CRUD.
- `templates/analyst/.claude/skills/autoresearch/SKILL.md` (different file) — the per-agent autoresearch skill (hypothesis → change → measure → keep/discard).
- The autoresearch substrate is daemon-managed crons (primitive that ships at CHANGELOG 0.2.0): `${CTX_ROOT}/state/{agent}/crons.json`. Overnight scheduling is just a cron expression like `0 22 * * 1-5`.

**Tests cited:**

- `tests/sprint3-experiments.test.ts` (444 lines) — sprint-named test file dedicated to the experiment system.
- `tests/integration/multi-agent-crons.test.ts` (922 lines) — exercises the cron-scheduled run substrate that overnight autoresearch sits on.
- `tests/unit/daemon/cron-scheduler.test.ts` — 30-second tick, catch-up policy, exponential backoff (3 attempts: 1s/4s/16s).

**IFOS dependency:**

- Master brief §2.4 row 6: Night Sourcer + Spec Pitcher (Product Spec R4 + R11).
- v1.0: **No agent depends on this.** Ultraplan §3.1 row 6: "This is for the Night Sourcer in v1.1, not v1.0. Defer the question."
- v1.1: **A11 Night Sourcer** (Ultraplan §8.2, weeks 9-10) is the canonical use case — "8-12 reviewed candidates per brief every morning at 06:30" (Product Spec §2.2 R4).
- v1.2: Spec Pitcher (R11). v2.0+: per-firm LoRA evaluation experiments could ride on the same substrate.

**Risk if flaky:** Night Sourcer becomes a daytime cron with rate-limit pain — kills the "Walk in to 27 reviewed candidates across your live briefs every morning" pitch (Product Spec §10 line 525). Per Ultraplan §10 Risk #6: "LinkedIn rate limits via Proxycurl are tighter than expected → defer Night Sourcer to v1.2 if needed" — overnight autoresearch is also the budgeting layer for the LinkedIn rate limit (Ultraplan §8.2 A11 gotcha: "Build the rate-limit budget allocator carefully; this is where £40-60/mo of the £200 per-tenant compute cost lives").

**Verification method (against our `ifos-v2` instance):**

```bash
# 1. Create a test experiment + verify lifecycle persistence
cortextos-ifos add-agent probe-analyst --template analyst --org test-org

cortextos-ifos bus create-experiment probe-analyst \
  --metric inbox_response_time --hypothesis "shorter draft is better"
ls ~/.cortextos/ifos-v2/orgs/test-org/agents/probe-analyst/experiments/
# expect: a JSON file matching the Experiment schema

# 2. Approval gate integration
echo '{"approval_required": true}' \
  > ~/.cortextos/ifos-v2/orgs/test-org/agents/probe-analyst/experiments/config.json
cortextos-ifos bus create-experiment probe-analyst \
  --metric x --hypothesis y
# expect: blocks until an approval in pending/ is approved

# 3. Theta-wave cycle (the cron-driven path)
cortextos-ifos bus add-cron probe-analyst theta-wave "0 22 * * 1-5" \
  "Read .claude/skills/theta-wave/SKILL.md and run the cycle."
ls ~/.cortextos/ifos-v2/state/probe-analyst/crons.json    # cron persisted
# from dashboard /workflows/probe-analyst/theta-wave press Test Fire
# expect: agent receives the prompt; experiment lifecycle artefacts appear

# 4. Evaluation + decision capture
cortextos-ifos bus evaluate-experiment <id> \
  --result-value 0.82 --decision keep --learning "shorter is better"
# expect: experiment status flips to completed, decision recorded
```

---

## Primitive 7 — Multi-agent orchestrator

**Master-brief description:** Orchestrator template + file-bus handoff contract; supervisor agent watches the others, escalates jams, balances load (master brief §2.4 row 7).

**Status:** `shipped and tested`

The orchestrator template ships in full (17 files), the daemon's `AgentManager` recognizes a per-org designated orchestrator and gives it special privileges (activity-channel callback poller, only-orchestrator-polls-Telegram opt-out via `telegram_polling: false`), and the file-bus handoff substrate is the same primitive-3 message bus already verified. Documented production trade-off but no Day-0 brittleness; not on the v1.0 critical path.

**Evidence (code):**

- `templates/orchestrator/` — 17 files including a 238-line `CLAUDE.md` plus `IDENTITY.md`, `SOUL.md`, `GOALS.md`, `GUARDRAILS.md`, `HEARTBEAT.md`, `MEMORY.md`, `USER.md`, `SYSTEM.md`, `TOOLS.md`, `ONBOARDING.md`, `AGENTS.md`, `config.json`, `goals.json`, plus `experiments/`, `memory/`, `skills/` directories. Mirror set for `agent`, `analyst`, `agent-codex`, `hermes`, `m2c1-worker` templates.
- `src/daemon/agent-manager.ts:478-575` — `maybeStartActivityChannelPoller()`. Only the agent named in `orgs/<org>/context.json:orchestrator` field starts a second `TelegramPoller` for the activity-channel bot (line 497-504). The activity-channel poller uses `offsetFileSuffix='activity'` (line 536) to coexist with the agent's own Telegram poller — directly using primitive 5's two-poller mechanism.
- `src/daemon/agent-manager.ts:312-315` — `config.telegram_polling: false` lets specialist agents skip Telegram polling: "Set telegram_polling: false in config.json to prevent a specialist agent from running its own poller (only the designated orchestrator agent should poll)."
- `src/pty/agent-pty.ts:126-137` — every PTY gets a `CTX_ORCHESTRATOR_AGENT` env var (read from `context.json:orchestrator`), so agents can route to the orchestrator via `cortextos bus send-message $CTX_ORCHESTRATOR_AGENT ...` without hard-coding.
- `src/daemon/agent-manager.ts:47-78` — `discoverAndStart()` is the daemon's "bring up every enabled agent" entrypoint; `stopAll()` at line 639 writes the `.daemon-stop` markers that primitive 1's `handleExit` reads (cross-primitive integration).
- `src/daemon/worker-process.ts` (126 lines) + the `m2c1-worker` template — supports the "spawn an ephemeral worker, monitor via bus, collect output" pattern referenced in the orchestrator skill set.
- `src/daemon/agent-manager.ts:465-472` — documented production trade-off: "Polling coupled to orchestrator lifecycle is a known trade-off accepted in `task_1776053707166_292` — follow-up `task_1776054009969_099` tracks migrating to a dedicated singleton or Telegram webhook if the coupling ever causes real operator pain." This is operationally honest — not active brittleness, but a known architectural choice with a tracked migration path.

**Tests cited:**

- `tests/unit/daemon/agent-manager.test.ts` (448 lines) — covers discoverAndStart, stopAll, and the orchestrator-only activity-channel poller branch.
- `tests/unit/daemon/worker-process.test.ts` (162 lines) — m2c1-worker lifecycle.
- `tests/integration/multi-agent-crons.test.ts` (922 lines) — multi-agent coordination via the bus.
- `tests/integration/fleet-health-mixed-agents.test.ts` and `tests/integration/fleet-health-mixed-codex-claude.test.ts` — fleet-level health across mixed agents (the supervisor's "what is the fleet doing" view).

**IFOS dependency:**

- Master brief §2.4 row 7: Brief Decoder's 4-agent pipeline; T5 Supply Chain Auditor's daily recalc.
- v1.0: **No agent depends on this.** Ultraplan §3.1 row 7: "This is for v1.1+. Defer."
- v1.1: **A8 Brief Decoder** (Ultraplan §8.2 weeks 5-6) is the load-bearing test — it's the canonical "Brief Decoder → Sourcing Scout → Concierge" 4-agent handoff. Ultraplan §3.1 row 3 already names this as the bus's load-bearing test ("This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2").
- v1.1 parallel: T5 Supply Chain Auditor uses it for daily-recalc supervision.

**Risk if flaky:** Brief Decoder slips to v1.2 — the documented contingency in Ultraplan §3.1 row 3. Loses the "shortlist in 90 minutes" demo for the Growth tier. The "orchestrator-coupled Telegram polling" trade-off (`agent-manager.ts:465-472`) means if the orchestrator agent itself crashes, the activity-channel callbacks stop until restart — primitive 1's crash-loop alert covers that case.

**Verification method (against our `ifos-v2` instance):**

```bash
# 1. Orchestrator template scaffolds cleanly
cortextos-ifos init orch-test
cortextos-ifos add-agent boss --template orchestrator --org orch-test
ls ~/.cortextos/ifos-v2/orgs/orch-test/agents/boss/         # 17 template files copied
cat ~/.cortextos/ifos-v2/orgs/orch-test/context.json | jq .orchestrator   # must be "boss"

# 2. CTX_ORCHESTRATOR_AGENT env propagation
cortextos-ifos add-agent worker --template agent --org orch-test
# After daemon starts the worker:
pm2 logs ifos-daemon | grep "CTX_ORCHESTRATOR_AGENT"
# From inside the worker, `echo $CTX_ORCHESTRATOR_AGENT` must print "boss"

# 3. Inter-agent handoff (proves bus + orchestrator wiring)
cortextos-ifos bus send-message boss high "worker handoff test" --from worker
ls ~/.cortextos/ifos-v2/inbox/boss/    # one new message
# boss's fast-checker picks it up within ~1s, injects to PTY

# 4. Orchestrator-only activity-channel poller
cat > ~/.cortextos/ifos-v2/orgs/orch-test/activity-channel.env <<EOF
ACTIVITY_BOT_TOKEN=<token>
ACTIVITY_CHAT_ID=<chat-id>
EOF
pm2 restart ifos-daemon
pm2 logs ifos-daemon | grep -E "activity.*poller|Telegram poller started"
ls ~/.cortextos/ifos-v2/state/boss/.telegram-offset*     # both .telegram-offset and .telegram-offset-activity

# 5. Specialist opt-out
echo '{"telegram_polling": false}' > ~/.cortextos/ifos-v2/orgs/orch-test/agents/worker/config.json
pm2 restart ifos-daemon
pm2 logs ifos-daemon | grep worker | grep -v "Telegram poller started"   # worker should NOT have a poller
```

---

## Day 7 inputs

Feed these into the §6 Day 7 single-sentence test review:

- **Q2 (primitives 1, 4, 5):** all three present and tested. Primitive 1 carries Day-0 brittleness (quirks 2 + 3, prior restart storm) — closes when the verification commands above run green on `ifos-v2`. Primitive 4 + 5 are green now subject to a live round-trip.
- **Day-7 spec drifts for Codex ratification:** the chokidar mention in master brief §2.4 row 3 and the four `kb-*.sh` filenames in master brief §3.4 do not match the verified SHA. Both need a one-line correction or a §3.4 re-scoping decision.
- **Standing authorisations** (master brief §2.4 row 4) are not a cortextOS primitive at this SHA. We build them in our layer — confirm scope in the Day 5 auto-send safety policy artefact.

End of audit.
