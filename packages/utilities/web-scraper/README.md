# @ifos/web-scraper

IFOS web scraper utility for Diagnostic agent §4 Step 3 + 6 + 8 per `agents/recruitment/diagnostic/tools.yaml`.

## API surface

- `headCheck(url, options?)` — HTTP HEAD; returns `{ status, lastModified, contentType, finalUrl }` or `null` on failure
- `fetchFirstNLines(url, n, options?)` — HTTP GET, captures first N lines of body; returns `{ status, lines, contentType, finalUrl }` or `null`
- `googleSearch(query)` — stub for v0; W4 polish wires SerpAPI or alternative

## Constraints

- **No JavaScript execution.** Lightweight HTTP only. JS-heavy sites return their server-rendered HTML (often a "JavaScript required" placeholder) — graceful degradation per Diagnostic gotcha §6.1.
- **robots.txt respected** via `robots-parser`. URLs disallowed for our user-agent are skipped.
- **Cache:** 1-hour TTL for careers pages (matches `tools.yaml` cache config); disk-backed at `~/.ifos-cache/web-scraper/`. Override via `IFOS_WEB_SCRAPER_CACHE_DIR` env var.
- **Rate limit:** 30 requests / 60 seconds (matches `tools.yaml`).
- **Timeout:** 10s default; configurable per call.
- **User agent:** `Mozilla/5.0 (compatible; IFOS-Diagnostic/0.1; +https://intelforce.io/bot)`. Identifies us; not deceptive.

## Failure modes

- **Timeout / connection refused** → returns `null`; logs warning; caller treats as "no signal" per Diagnostic gotcha §6.1.
- **HTTP 4xx** → returns the response shape with status; caller decides what to do.
- **HTTP 5xx** → returns `null`; logs warning.
- **robots.txt blocks the URL** → returns `null`; logs info; caller treats as "site requires authentication".
- **Rate limit hit** → returns `null`; logs warning. Caller should batch + retry later.

## Usage

```typescript
import { headCheck, fetchFirstNLines } from "@ifos/web-scraper";

const head = await headCheck("https://charterhouse-partners.com/careers");
// → { status: 200, lastModified: "...", contentType: "text/html", finalUrl: "..." }

const body = await fetchFirstNLines("https://www.linkedin.com/company/charterhouse-partners/", 200);
// → { status: 200, lines: ["<!DOCTYPE html>...", ...], ... }
```

## Tests

```bash
pnpm test           # unit tests (mocked fetch)
pnpm typecheck      # strict mode
```

Integration tests require live network and are skipped by default; set `IFOS_WEB_SCRAPER_LIVE_TESTS=1` to enable.

## Status

v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
