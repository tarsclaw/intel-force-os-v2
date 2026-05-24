# Diagnostic report — Hays plc

**Generated:** 2026-05-24 by Intel Force OS Diagnostic agent (v0 — pre-W3 build).
**Tenant:** migration-test
**Sector hint:** recruitment
**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).


## Firm signal

No active Companies House registration found for **Hays plc**. Diagnostic proceeded against publicly visible non-CH signals only.

Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)

## Online footprint

Primary website: [https://www.hays.com/](https://www.hays.com/) (HTTP 200).

LinkedIn page at [https://www.linkedin.com/company/hays-plc/](https://www.linkedin.com/company/hays-plc/) not reachable (HTTP n/a). Firm may use a different LinkedIn slug or have no company page.

## Sector + role-type mix

Operator-provided sector hint: `recruitment`.
No SIC codes filed (unusual; verify firm status).

**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.

Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)

## Geography

Registered office address not visible at Companies House for Hays plc.

**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).

Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)

## Deal-size band proxy

Firm-age signal unavailable without Companies House incorporation date.

**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).

Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)

## ICP fit vs target_patch

No target_patch.json loaded for this tenant — cannot score ICP fit.

Source: [tenant config](vault://target-patch)

## Tech stack signals

**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).

Companies House SIC codes give a coarse industry signal but no specific technology stack visibility.

Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)

## Pain signals

Careers page reachable at [https://www.hays.com/jobs](https://www.hays.com/jobs) but no high-urgency phrases matched the v0 regex pass. Site may use measured language or hire offline.

Source: [careers page](https://www.hays.com/jobs)

## Competitor positioning

**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.

Companies House does not surface competitor data at the firm level.

Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)

## Recent activity

No filings at Companies House in the last 90 days. May indicate quiet period OR firm is between annual cycles.

**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.

Source: [Companies House filing history](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)

## Decision-maker map

No directors on file at Companies House (firm may be dissolved or unregistered).

Source: [Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)

## Conversation opener

> Hi — looking at Hays plc's public footprint, the standard signals (CH filings, careers page, LinkedIn) aren't surfacing the usual indicators of hiring pressure. That itself is interesting — happy to compare what we're seeing across recruitment sector peers if useful.

[Source: Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=Hays%20plc)

**v0 limitation:** voice classifier ≥ 0.75 gate (per agent.md §5 V3) skipped at v0; opener is deterministic anchor-based composition. Wire LLM + per-tenant voice classifier at W4 polish.
