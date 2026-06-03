# Founder API + signups playbook — 2026-06-03

**For:** Maddox (founder)
**Purpose:** Run this in parallel while Claude works on the W5-W6 marathon /goal. Every item below is a founder-only action — none can be delegated to the build agent. Doing these now unblocks W6+ live wiring across all 5 in-flight integrations.
**Total time investment:** ~3-4 hours if you do everything end-to-end; can be split across the 20h day.
**Path A discipline:** API keys NEVER paste into chat. They go web → 1Password → never echoed. Each task ends with "save to 1Password as `<name>`" — that's the handoff.

---

## How to use this guide

Each section is **self-contained**: exact URL, exact steps, exactly what to save in 1Password, exactly what to reply back to me when done. Run them in **priority order** below — the top items unblock the most downstream work.

When you finish each item, you don't need to reply in chat — just save creds to 1Password. At our next checkpoint I'll ask which ones landed.

---

## 🎯 PRIORITY 0 — Q1 LOI close with Jack (~30min-2h; KILL-CRITERION CLOCK)

**Why first:** Trigger 1 fired 2026-06-03. This is the ONE thing only you can do that decides whether v1.0 ships at all. Every other item below is build-prep that's useless without a customer.

**Action:** Whatever form Jack's lane needs right now — call, email, in-person, signature. Get the LOI to a definitive yes-or-no state today.

**Outcomes:**
- ✅ **Signed LOI** → Trigger 1 cleared; build velocity justified; everything else below remains in scope
- ⚠️ **Hard no** → pause IFOS build; reassess pipeline; nothing below matters until next pilot is sourced
- ⏸ **Soft maybe with date** → record the date in `.agents/current-priorities.md` item 7; remaining build proceeds at current pace

**Reply pattern:** `Q1 LOI: SIGNED` OR `Q1 LOI: HARD NO` OR `Q1 LOI: pending until <date>`

---

## ⚡ PRIORITY 1 — Bullhorn developer account (~15min; UNBLOCKS LIVE BULLHORN TESTS)

**Why:** unblocks live integration tests on `@ifos/bullhorn` (commit ff0f7b6). Distinct from the partnerships application (rejected per ≥2-customer gate); this is the dev sandbox creds for OAuth bootstrap.

### Step 1.1 — Sign up

URL: **https://developer.bullhorn.com**

1. Click **"Get Started"** or **"Register"** (top-right)
2. Fill the form:
   - **Email:** your IFOS founder email
   - **Company:** Intel Force OS Ltd (or whatever your registered name is)
   - **Use case:** "Building a multi-tenant recruitment-ops product integrating Bullhorn ATS via OAuth per-tenant; developer credentials for sandbox testing"
3. Verify email
4. Sign in to the developer portal

### Step 1.2 — Create an OAuth app

1. **Apps** tab → **New App** (or **My Apps** → **Create App**)
2. Fill:
   - **App name:** `Intel Force OS — IFOS v1.0`
   - **Redirect URI:** `http://localhost:3100/callback` (works for local dev OAuth bootstrap; v1.1+ will move to a per-tenant subdomain)
   - **Scopes:** request `all` (the broadest scope; we can narrow at production)
3. Submit; Bullhorn will issue:
   - `client_id` (looks like a UUID)
   - `client_secret` (long opaque string)
   - **Sandbox tenant credentials** (a test Bullhorn account with seeded data — `BHRESTUSER` + `BHRESTPASSWORD`)

### Step 1.3 — Save to 1Password

Create item: **"IFOS Bullhorn — developer sandbox"**
Fields:
- `client_id`
- `client_secret`
- `sandbox_username`
- `sandbox_password`
- `sandbox_corporation_id` (visible after first login to the sandbox)

**Do NOT paste these into chat.** I'll write the OAuth bootstrap playbook in Phase 9 of the marathon; you'll execute it locally with these creds.

---

## ⚡ PRIORITY 2 — Reed.co.uk recruiter API (~30min; UNBLOCKS SOURCING SCOUT SOURCE #1)

**Why:** unblocks live tests on the `@ifos/reed` MCP package Claude will scaffold in marathon Phase 8. Sourcing Scout v1.0 = 3 sources; Reed is source #2 (Bullhorn passive-match is #1).

### Step 2.1 — Choose the right API

Reed has TWO APIs — make sure you pick the right one:
- ❌ **Reed Jobseeker API** — for candidates searching/applying to jobs. NOT what we need.
- ✅ **Reed Recruiter API** (sometimes called "Reed Direct" or "Reed.co.uk Job Posting API") — for agencies to post jobs + receive applications. This is what IFOS needs.

### Step 2.2 — Sign up

URL: **https://www.reed.co.uk/recruiter** (then look for **"API access"** or **"Developer access"** in the footer/menu)

If that doesn't surface a developer portal directly:
- Email **api@reed.co.uk** (or look up the current recruiter-API contact)
- Subject: `Recruiter API access for Intel Force OS — multi-tenant recruitment platform`
- Body: brief paragraph: "We're a recruitment-operations SaaS launching with UK agencies. Need API access to push job postings + pull applicant data on behalf of our recruiter tenants. Each tenant maintains their own Reed account; IFOS authenticates per-tenant."
- Ask for: API documentation URL + sandbox credentials + production access process

### Step 2.3 — Save to 1Password

Create item: **"IFOS Reed.co.uk — recruiter API"**
Fields (whatever Reed issues; typically):
- `api_key` OR `client_id` + `client_secret`
- `sandbox_account_username` + `sandbox_account_password` (if Reed provides a sandbox)
- `api_docs_url` (so I can WebFetch for the wrapper scaffold)

**Reply pattern at next checkpoint:** `Reed: API docs URL = <url>` OR `Reed: waiting on email reply`

---

## ⚡ PRIORITY 3 — CV-Library API (~30min; UNBLOCKS SOURCING SCOUT SOURCE #2)

**Why:** parallel to Reed. CV-Library is source #3 of Sourcing Scout's v1.0 trio.

### Step 3.1 — Find the right API entry point

URL: **https://www.cv-library.co.uk** (then **"Recruiters"** → look for **"API"** or **"Integrations"**)

Likely path:
- **Recruiters** menu → **Tools & Resources** → **API documentation**
- OR contact form via Recruiters page → request "API access for a multi-tenant recruitment platform"

### Step 3.2 — Request API access

Same template as Reed:
- Subject: `API access for Intel Force OS — multi-tenant recruitment platform`
- Body: "Recruitment-ops SaaS launching with UK agencies. Need CV-Library API access to search CVs on behalf of recruiter tenants. Per-tenant authentication."
- Ask for: docs + sandbox + production access process

### Step 3.3 — Save to 1Password

Create item: **"IFOS CV-Library — recruiter API"**
Fields (whatever they issue):
- `api_key` OR `client_id` + `client_secret`
- `account_email` + `account_password`
- `api_docs_url`

**Reply pattern:** `CV-Library: API docs URL = <url>` OR `CV-Library: waiting on email reply`

---

## ⚡ PRIORITY 4 — Xero developer account (~15min; UNBLOCKS CASH CONDUCTOR W7-8)

**Why:** unblocks live tests on `@ifos/xero` (Day-25 scaffold). Cash Conductor W7-8 build slice needs Xero sandbox creds.

### Step 4.1 — Sign up

URL: **https://developer.xero.com**

1. **Sign up** (or **Login** if you have a personal Xero account; same login works for dev portal)
2. Email verify
3. Sign in to **My Apps**

### Step 4.2 — Create an app

1. **New app** → fill:
   - **App name:** `Intel Force OS — IFOS v1.0`
   - **Integration type:** **Web app** (we'll do OAuth 2.0 flow per-tenant)
   - **Company / app URL:** `https://intelforceos.com` (or whatever your domain is)
   - **Redirect URI:** `http://localhost:3100/callback`
   - **Scopes:** request `accounting.transactions` + `accounting.contacts` + `accounting.settings` + `offline_access` (offline_access gives us the refresh_token we need)
3. Save; Xero issues:
   - `client_id`
   - `client_secret`

### Step 4.3 — Create a demo company

1. Xero dashboard (your personal Xero account) → **Settings** → **Demo Company**
2. Click **Try the Demo Company** — this is a pre-seeded test org you can run OAuth against without affecting real data

### Step 4.4 — Save to 1Password

Create item: **"IFOS Xero — developer sandbox"**
Fields:
- `client_id`
- `client_secret`
- `demo_company_org_id` (visible after first OAuth handshake)

---

## ⚡ PRIORITY 5 — QuickBooks developer account (~15min; UNBLOCKS CASH CONDUCTOR ALTERNATE)

**Why:** parallel accounting provider to Xero per `@ifos/quickbooks`. Cash Conductor supports either; tenant chooses. v1.0 we want both creds ready.

URL: **https://developer.intuit.com**

1. **Sign up** → **My Apps** → **Create an app**
2. **Application type:** QuickBooks Online + Payments
3. **Scopes:** `com.intuit.quickbooks.accounting`
4. **Redirect URI:** `http://localhost:3100/callback`
5. Save creds:
   - `client_id`
   - `client_secret`
6. Create a sandbox company: **Developer dashboard** → **Sandbox** → **Add a sandbox company** (US is fine for testing; production will use UK)

### Save to 1Password

Item: **"IFOS QuickBooks — developer sandbox"**
- `client_id` + `client_secret` + `sandbox_realm_id`

---

## ⚡ PRIORITY 6 — TrueLayer Open Banking sandbox (~30min; UNBLOCKS CASH CONDUCTOR BANK FEED)

**Why:** unblocks `@ifos/open-banking` live tests. UK Open Banking provider for Cash Conductor's bank-feed ingestion.

URL: **https://console.truelayer.com**

1. **Sign up** for a developer account (use IFOS founder email)
2. Email verify
3. **Console** → **Create app**:
   - **App name:** `Intel Force OS — IFOS v1.0`
   - **App type:** Web
   - **Redirect URI:** `http://localhost:3100/callback`
4. Save creds:
   - `client_id`
   - `client_secret`
5. **Sandbox** tab → links to test bank login flows (e.g. "Mock Bank" — works without a real PSD2 consent dance)

### Save to 1Password

Item: **"IFOS TrueLayer — Open Banking sandbox"**
- `client_id` + `client_secret`

---

## 🟢 PRIORITY 7 — Granola browser OAuth dance (~5min; UNBLOCKS SCRIBE LIVE)

**Why:** unblocks live transcript tests on `@ifos/granola`. Requires Claude Code restart, which you said earlier you didn't want to do — re-flag whenever you're willing to restart.

### Action

In any NEW Claude Code session (this requires the restart so the granola MCP server is picked up):

```
/mcp
```

Select `granola` → **Authenticate** → browser opens → sign in to your Granola Business+ workspace → click **Allow** → "you can close this tab" page → done.

Then smoke test in the same Claude Code session:
```
Using the granola MCP, list my meetings from the last 3 days.
```

If you get back a list, it works. If you get "Paid plan required" on `list_meeting_folders` → contact me (means workspace is actually on Free tier; we revisit plan_tier assumption).

### Save to 1Password — NO ACTION

Granola tokens are managed by Claude Code's MCP client; you don't manage them. Just verify the auth dance succeeded.

---

## 🟢 PRIORITY 8 — WorkOS account (~15min; UNBLOCKS v1.1+ ADMIN AGENT)

**Why:** unblocks live tests on `@ifos/workos` (Day-29 scaffold). v1.0 IFOS auth substrate per master brief §5.3 line 401. No v1.0 agent consumes this directly — admin/onboarding UI is the primary consumer in v1.1+. Doing this now means the foundation is in place when v1.1+ work starts.

URL: **https://dashboard.workos.com/signup**

1. Sign up; verify email
2. **API Keys** tab → **Create key** → copy
3. Note the staging vs production toggle — start with staging key (`sk_test_…`)

### Save to 1Password

Item: **"IFOS WorkOS — staging API key"**
- `secret_key` (the `sk_test_…` value)

---

## 🟢 PRIORITY 9 — Companies House API key (~10min; LIKELY ALREADY DONE)

**Why:** check whether the Companies House key noted as ✅ in action board item 3a is still valid. If yes, skip. If you've never confirmed, do this quick verification.

URL: **https://developer.company-information.service.gov.uk**

1. Sign in (or sign up if new)
2. **Applications** → confirm your IFOS app exists
3. Confirm the API key is active

### Save to 1Password — verify only

Item should already exist: **"IFOS Companies House — API key"**. Verify it's there.

---

## Companion: what NOT to do today

These are explicit non-actions (avoid burning time on them):

- **Don't apply to Bullhorn marketplace partnership** — that route needs ≥2 live customers; deferred to v1.1+ per Sub-decision A (resolved 2026-06-02)
- **Don't sign up for Proxycurl / NinjaPear / LinkedIn deep-data vendors** — v1.1+ scope per Sourcing Scout caveat (action board item 8); current v1.0 = 3 sources without LinkedIn deep-data
- **Don't pay for any production tier yet** — sandbox/free tiers cover all v1.0 development; production tiers come post-LOI when revenue justifies cost
- **Don't reply to Bullhorn dev-support email until it arrives** — passive watch; ~by 2026-06-09 per the 2-5 business day SLA from 2026-06-02 submission

---

## Reply summary template (use at next checkpoint)

```
Q1 LOI: <SIGNED | HARD NO | pending-until-DATE>
Bullhorn dev: <DONE | waiting on portal | not started>
Reed: <DONE-API-docs-at-URL | waiting on email | not started>
CV-Library: <DONE-API-docs-at-URL | waiting on email | not started>
Xero dev: <DONE | not started>
QuickBooks dev: <DONE | not started>
TrueLayer: <DONE | not started>
Granola OAuth: <DONE | will-do-after-restart | skipping-this-session>
WorkOS: <DONE | not started>
Companies House: <verified | needs renewal | unclear>
```

I'll use this at the marathon checkpoint to decide what live-wiring work I can do next vs what stays deferred.

---

*End of founder signup playbook 2026-06-03. Companion to the W5-W6 marathon /goal firing in parallel.*
