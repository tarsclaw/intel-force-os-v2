# @ifos/companies-house

IFOS Companies House MCP connector for Diagnostic agent §4 Step 2 + 10 per `agents/recruitment/diagnostic/tools.yaml`.

## API surface

- `search(name)` — fuzzy name → list of matches with CRN + status
- `profile(companyNumber)` — CRN → full profile (incorporation, accounts, address, status)
- `officers(companyNumber)` — CRN → directors + secretaries with appointment dates
- `filingHistory(companyNumber, sinceDays?)` — CRN → filings (default last 90 days)

## Auth

Companies House uses HTTP Basic auth with the API key as username + empty password. Per their docs:
- Get a key: register at https://developer.company-information.service.gov.uk/ (verified 2026-05-24)
- Set `COMPANIES_HOUSE_API_KEY` env var
- Connector reads from env automatically

Path A discipline: never log the key, never write to disk except `/vault/<tenant>/_secrets.env` mode 600.

## Constraints

- **Rate limit:** 600 requests / 5-minute window per IP (Companies House documented). Connector pre-emptively backs off at 80% capacity.
- **Cache:** 7-day TTL per `(company_number, capability)` (matches `tools.yaml`). Companies House data changes slowly; 7 days is safe.
- **Timeout:** 8s default per call.
- **Pagination:** `officers` and `filingHistory` paginate at 35 items/page (CH default); connector fetches first page only for v0 (sufficient for §1 + §10 needs).

## Failure modes

| Status | Behaviour | Escalation code |
|---|---|---|
| 401 | API key invalid; fail-fast | ESC_SCHEMA_VIOLATION |
| 404 | Company not found; return null + log | none |
| 429 | Rate limited; back off 60s, retry once | ESC_RATE_LIMIT_HIT |
| 5xx | Server error; fail-fast | ESC_SCHEMA_VIOLATION |

## Usage

```typescript
import { search, profile, officers, filingHistory } from "@ifos/companies-house";

const matches = await search("Charterhouse Partners");
// → [{ company_number: "08732145", title: "CHARTERHOUSE PARTNERS LTD", ... }]

const prof = await profile("08732145");
// → { company_number, company_name, incorporation_date, registered_office_address, ... }

const dirs = await officers("08732145");
// → [{ name: "BOWEN, Sarah", officer_role: "director", appointed_on: "...", ... }]

const filings = await filingHistory("08732145", 90);
// → [{ category: "annual-accounts", date: "2026-04-21", ... }]
```

## Tests

```bash
pnpm test           # unit tests (mocked fetch); 12 tests
pnpm typecheck      # strict mode
```

Integration tests against live Companies House API are skipped unless `COMPANIES_HOUSE_API_KEY` env is set.

## Status

v0.1 — Diagnostic v1.0 dependency per `agents/recruitment/diagnostic/tools.yaml`.
