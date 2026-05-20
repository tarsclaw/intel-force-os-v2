# ADR-001 — Bus dispatcher is poll-based, not chokidar-watched

**Date:** 2026-05-16 (Week 0, Day 1)
**Author:** Claude Code, founder decision logged 2026-05-16
**Surfaced by:** `docs/architecture/cortexos-primitive-status.md` — Primitive 3
**Submodule SHA:** `c21fbfe991a0030ea055bd8e2389a0801a424383`
**Status:** Accepted — Option A. Founder decision logged 2026-05-16.

---

## Context

Master brief §2.4 row 3 describes Primitive 3 (Inter-agent file bus) as:

> "`bus/` shell wrappers + `chokidar` watcher in the daemon"

This is wrong against the verified SHA `c21fbfe`. Concrete code state:

- `grep -rn chokidar packages/harness/cortextos/src/` returns **zero** hits.
- `chokidar@^5.0.0` in `packages/harness/cortextos/package.json:47` is real, but `grep -rn chokidar packages/harness/cortextos/` shows the only application code use is `packages/harness/cortextos/dashboard/src/lib/watcher.ts:5` (`import { watch, type FSWatcher } from 'chokidar';`) — the **dashboard UI's file-change feed**, not the inter-agent bus.
- The actual bus dispatcher is `FastChecker` (`src/daemon/fast-checker.ts:75`): `this.pollInterval = options.pollInterval || 1000;`. Each agent's `FastChecker` calls `checkInbox(paths)` (`src/bus/message.ts:96-164`) every `pollInterval` ms, reads the inbox directory, moves files inbox→inflight, returns parsed messages, and injects them into the PTY.
- `checkInbox` uses `readdirSync` + filename-sort (line 111-113) on each call — pure synchronous directory scan. No watcher, no event, no `chokidar`. The "drop a file → other agent sees it" semantics still hold, but with a polling floor.

Operational consequence: end-to-end latency of an N-hop agent pipeline is **bounded below by N × `pollInterval`**. At the default 1000ms with the 4-agent Brief Decoder → Sourcing Scout → Concierge pipeline (3 hops), the floor is ≥3 seconds. The current master brief §3.2 / Ultraplan §3.2 narrative ("four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes") is technically consistent with this floor at 1000ms — but only just, and a customer-facing claim of "sub-second handoff" would be wrong.

This drift surfaced during the Day-1 primitive audit. It has no Day-0 quirk attached and no real-world brittleness — the bus itself ships and is tested (`tests/unit/bus/message.test.ts`, `tests/integration/multi-agent-crons.test.ts`, `tests/e2e/lifecycle.test.ts`). Only the master brief's mechanism description is wrong.

## Decision

Two things in one ADR:

**1. Correct master brief §2.4 row 3.** Replace:

> "Inter-agent file bus | `bus/` shell wrappers + `chokidar` watcher in daemon"

with:

> "Inter-agent file bus | `bus/` shell wrappers (47 shims execing `node dist/cli.js bus <command>`) + `FastChecker` poll loop in daemon (default 1000ms via `pollInterval` in agent config, configurable per agent)"

Recommend a one-paragraph footnote in §2.4 that names the substrate: messages are JSON files under `${ctxRoot}/inbox/<to>/{pnum}-{epochMs}-from-{sender}-{rand5}.json`, three-directory lifecycle (`inbox → inflight → processed`), HMAC-SHA256 signed (Quirk 5), stale-inflight recovery at 5 minutes.

**2. Founder decides which path for the pipeline-latency claim.** Two options:

| Option | Action | Cost | Implication |
|---|---|---|---|
| **A. Accept the floor** | Leave `pollInterval` at the 1000ms default. Rewrite Ultraplan §3.2's "four-agent pipelines complete in seconds" to "four-agent pipelines complete in 3-5 seconds end-to-end" and remove any "sub-second handoff" framing from the closing-demo deck | Zero engineering | Honest signal; Concierge's "30-min lifecycle event → drafted comms" SLA is unaffected (3-5s is rounding error against 30 minutes); Brief Decoder's "90-min brief-to-shortlist" is also unaffected. Only sales narrative changes. |
| **B. Reduce to 250ms** | Set `pollInterval: 250` in the IFOS agent template's `config.json`. Re-measure daemon CPU on a 6-agent fleet under load (master brief §6 Day 4 stress-test addition). Keep the existing "complete in seconds" framing | ~0.5 day to add the config + re-baseline; ongoing 4× CPU per FastChecker poll (still negligible — `readdirSync` on a typically-empty inbox dir is sub-millisecond, so 4× sub-ms is still sub-ms). The risk is `bus-signing-key` HMAC verification cost × 4 if inbox traffic spikes | Pipeline floor drops to ~750ms — restores headroom for the sales narrative while leaving CPU comfortable. |

**Recommendation: Option A.** Three reasons:

1. The honest-signal Rule 5 (master brief §1) makes "rewrite the claim" cheaper than "tune the substrate to fit the claim".
2. The user-visible SLAs (Concierge 30-min lifecycle event, Brief Decoder 90-min shortlist, Triage 60-second response) all have ≥30× headroom against a 3-5 second pipeline floor. The pipeline-latency claim is sales narrative, not product SLA.
3. Option B's "still negligible" assertion is unverified at our pinned SHA on a 6-agent fleet. Re-baselining CPU is work we don't need to do this week. If a customer ever asks for it, we can move to Option B without changing the substrate — it's a single config field per agent.

## Consequences

**If founder accepts Option A:**
- Single edit to master brief §2.4 row 3 (the correction itself).
- Single edit to Ultraplan §3.2: rewrite "four-agent pipelines complete in seconds, not the 15-second cold-start tax Lambda imposes" → "four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound."
- Day 7 Q2 ratification gate on the file bus passes cleanly because the description matches the code.
- No sales-deck claim of "sub-second handoff"; Brief Decoder demo opens with "intake-to-shortlist in 90 minutes", not "agents handing off instantly".

**If founder accepts Option B:**
- Add `"pollInterval": 250` to `packages/agents-runtime/_shared/config.json` (the shared agent config base — not yet built; this becomes a Day-2-onwards artefact).
- Master brief §2.4 row 3 still gets corrected — but says "poll loop (250ms in IFOS, 1000ms cortextOS default)".
- Day 4 infra stress-test (master brief §6) gains a new sub-task: measure daemon CPU on a synthetic 6-agent fleet at 250ms poll vs 1000ms baseline.
- Risk: if the daemon CPU pattern is non-linear on real-load inbox traffic, we discover that during the stress test rather than in a pilot. Caught here is fine; caught after a pilot signs is not.

**Either way, irrespective of A vs B:**
- The "no chokidar" finding propagates to two other places that referenced the old mechanism: `docs/build-brief/00-MASTER-BRIEF.md` §2.4 row 3 + footnote, and the `docs/specs/ULTRAPLAN.md` §3.2 wording. Both edits are part of the same atomic correction.
- Codex-ratification list (master brief §10.5) needs an entry: bus-dispatcher mechanism change = master brief edit = always-ratify.
- The brain-replacement seam (§3.4) is unaffected by this ADR. ADR-002 covers that separately.

## Status

**Accepted — Option A.** Founder decision logged 2026-05-16. The master brief §2.4 row 3 + Ultraplan §3.2 edits are deferred to a single atomic "spec drift reconciliation" commit that lands alongside whatever ADR-002 dictates for §3.4. Codex ratifies the combined commit on Day 7 with the other Week 0 artefacts.
