# @ifos/diagnostic-generator

Composes `@ifos/web-scraper` + `@ifos/companies-house` into a 12-section Markdown report for a UK recruitment firm. Called by `agents/recruitment/diagnostic/cycle.sh` after context.sh hydrates the session and before validate.sh runs Gate A.

## CLI

```bash
node packages/diagnostic-generator/dist/cli.js \
  --firm "Charterhouse Partners" \
  --tenant migration-test \
  --sector fintech \
  --target-patch /vault/migration-test/target_patch.json
```

Writes the Markdown report to stdout. `cycle.sh` captures it to `/tmp/diagnostic-draft-<slug>-<pid>.md`.

## Architecture

- **§1 Firm signal** — `companies-house` profile + officers + filing-history.
- **§2 Online footprint** — `web-scraper` HEAD check on `{slug}.com`, `{slug}.co.uk`, LinkedIn page.
- **§3 Sector mix** — stub with Companies House SIC codes; LinkedIn jobs at W4.
- **§4 Geography** — Companies House registered office; LinkedIn job-post locations at W4.
- **§5 Deal-size band** — firm-age proxy from Companies House; LinkedIn salary bands at W4.
- **§6 ICP fit** — composite score from §1/§5 vs tenant `target_patch.json`.
- **§7 Tech stack** — stub; LinkedIn skills + JD parsing at W4.
- **§8 Pain signals** — `web-scraper` careers page + 10-pattern urgency regex.
- **§9 Competitor positioning** — stub; LinkedIn profile employment-history at W4.
- **§10 Recent activity** — Companies House filings last 90 days; LinkedIn posts + Google news at W4.
- **§11 Decision-maker map** — Companies House directors as proxy; LinkedIn employee search at W4.
- **§12 Conversation opener** — deterministic anchor-based composition (LLM at W4).

## v0 limitations (explicit)

This is the **Day-13 v0 build** per `docs/operations/goal-option-c-diagnostic-end-to-end.md`. Limitations:

1. **No LinkedIn deep data.** Page-existence check via HEAD only. Full data needs Proxycurl signup (~$39/mo).
2. **No LLM-driven §12.** Conversation opener is deterministic anchor-based. W4 wires an LLM + voice classifier.
3. **No voice classifier gate.** validate.sh V3 skipped at v0 with explicit warning.
4. **No Google news search.** §10 only sees Companies House filings.

These are pre-baked into the report text so prospects + operators know what's real vs deferred.

## Failure modes

| Failure | Behaviour |
|---|---|
| Companies House API key missing | Throws CHAuthError at module init; cycle.sh exits non-zero |
| Companies House 404 (firm not registered) | Section §1 reports "no registration found"; §6+§10+§11 degrade gracefully |
| Web scraper times out / blocked | Section §2 + §8 report "no signal"; report still produces |
| LinkedIn HEAD returns 999 (bot detection) | §2 treats as "page exists, deep data via Proxycurl"; not a failure |
| Network down | All Companies House + web-scraper calls fail; report degrades to "no-data" path but still 12 sections + ≥1 citation each (V1+V2 pass) |

## Tests

```bash
pnpm test       # 3 unit tests with mocked globalThis.fetch
pnpm typecheck  # strict
```

Tests use `globalThis.fetch` replacement; no real network calls. Real-firm integration testing happens at goal Step 7 with the founder picking a firm name.

## Status

v0.1 — Diagnostic W3 pre-build per `agents/recruitment/diagnostic/agent.md` + `docs/operations/goal-option-c-diagnostic-end-to-end.md`.
