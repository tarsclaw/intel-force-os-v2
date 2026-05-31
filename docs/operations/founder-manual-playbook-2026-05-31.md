# Founder manual playbook — W4 (2026-05-31)

**For:** Maddox (founder)
**Window:** today → end-of-W4 (~2026-06-05)
**Total time investment:** ~55 minutes for the 3 blocking items; rest are deferrable.
**Path A discipline:** API keys and passwords NEVER paste into chat. They go from web → vault file → never echoed. Every command in this guide respects that.

---

## How to use this guide

Each task is **self-contained**: exact URL, exact commands, exactly what to confirm back to me. Read top to bottom. Skip nothing. Do them in the **order listed** (the first three are the priority unlock chain; the rest are deferrable).

When you finish a task, reply with **the exact one-liner shown** (e.g. `"v0.3 applied; tenancy audit 12/12"`). That's how I know to act on the next dependency.

---

## ⚡ PRIORITY 1 — Apply v0.3 migration to live VPS (~30 min)

**Why first:** unblocks all v0.3 schema usage (Cash Conductor tables, Janitor dedup config, blocked_recipients, etc.). Without this, every downstream W4 build is just writing code against schema that doesn't exist on the live database.

### Step 1.1 — Pre-flight (~2 min)

In your terminal, from the repo root:

```bash
cd ~/code/CortexOS
echo "CTX_INSTANCE_ID=$CTX_INSTANCE_ID"          # must print: ifos-v2
shellcheck scripts/run-v0.3-migration.sh && echo OK
```

If `CTX_INSTANCE_ID` is empty, run `source .envrc` first.

### Step 1.2 — Retrieve the ifos_app password (~1 min)

Open 1Password → search for **"IFOS Postgres ifos_app — production"** → copy the password to clipboard. Keep it on the clipboard for the next step.

### Step 1.3 — Dry run (no writes; ~5 min)

```bash
bash scripts/run-v0.3-migration.sh --dry-run
```

It will prompt: `Enter password for ifos_app:` — paste the password (you won't see it as you paste; that's intentional — `read -s` silent input). Press Enter.

**Expected output (the last few lines):**
```
✓ Pre-flight OK; v0.2 present; v0.3 NOT yet applied
✓ Tunnel + auth confirmed
✓ DRY RUN COMPLETE — no writes made
```

If you see any `✗` line, **STOP** and paste the failure to me; I'll triage.

### Step 1.4 — Live apply (~10 min)

Only after dry-run is clean:

```bash
bash scripts/run-v0.3-migration.sh
```

Same password prompt. Expected 6 green acceptance steps + an audit row written.

### Step 1.5 — Verify the 12 tenancy invariants (~5 min)

```bash
bash scripts/run-tenancy-audit.sh
```

Same password prompt. **Expected: `12/12 invariants PASS` (across 11 tenant-data tables).**

If anything goes red, paste the failing line to me. If all green, you're done.

### Step 1.6 — Confirm back to me

Reply in chat with **exactly**:
```
v0.3 applied; tenancy audit 12/12
```

(Or if any step failed: paste the failing step output and I triage immediately.)

**What I do on your reply:** mark W4 backlog item #1 closed; flip the deferred-rollback re-ratification note to "next natural touch is now this VPS apply — schedule a cluster E re-run."

---

## ⚡ PRIORITY 2 — API keys + Diagnostic live smoke (~25 min)

**Why second:** closes Trigger 2 (DIAGNOSTIC-NO-RENDER-W3 fires 2026-06-14 — 14 days from today). Two registrations + one command.

### Step 2.1 — Companies House API key (~15 min)

1. Open **https://developer.company-information.service.gov.uk/** in a browser.
2. Click **"Sign up"** (or sign in if you already have an account). Free.
3. After verifying email + signing in: navigate to **"My Applications"** → **"Create an application"**.
4. Choose **"REST API"** for the application type.
5. Application name: **`IFOS Diagnostic`**. Description: `Sales-research tool — fetches UK company filings via the public API`.
6. After creating: click into the application → reveal the **API Key**. Copy it.
7. Save it to the local vault (NOT the VPS — Diagnostic runs locally for now):

```bash
# Create the local vault tenant dir if it doesn't exist yet
mkdir -p ~/.ifos-local-vault/migration-test
chmod 700 ~/.ifos-local-vault/migration-test

# Append the key (one line; replace <key> with the actual key on the clipboard)
echo 'COMPANIES_HOUSE_API_KEY=<paste-key-here>' >> ~/.ifos-local-vault/migration-test/_secrets.env
chmod 600 ~/.ifos-local-vault/migration-test/_secrets.env
```

**Path A reminder:** the `<paste-key-here>` text above is the only place the key touches anything other than the secrets file. Don't paste it in chat, in commits, in Slack, in commit messages, ever.

### Step 2.2 — Anthropic API key (~5 min)

1. Open **https://console.anthropic.com/** in a browser.
2. Sign in (or sign up + verify email — free; pay-as-you-go billing required to use the key in production).
3. **Settings → API Keys → "Create Key"**.
4. Key name: **`IFOS Diagnostic §12 (conversation opener)`**.
5. Copy the displayed key (you only see it once — copy immediately).
6. Save to the same vault file:

```bash
echo 'ANTHROPIC_API_KEY=<paste-key-here>' >> ~/.ifos-local-vault/migration-test/_secrets.env
```

Permissions are already 0600 from Step 2.1.

### Step 2.3 — Verify the saved secrets (no echo of values) (~30 sec)

```bash
# Lists the KEY NAMES only, never the values
grep -oE '^[A-Z_]+=' ~/.ifos-local-vault/migration-test/_secrets.env
```

You should see:
```
COMPANIES_HOUSE_API_KEY=
ANTHROPIC_API_KEY=
```

### Step 2.4 — Dry-run the smoke wrapper (~30 sec)

```bash
cd ~/code/CortexOS
bash scripts/run-diagnostic-smoke.sh --dry-run
```

Expected:
```
✓ Vault tenant dir present: ...
✓ Secrets file present: ...
✓ COMPANIES_HOUSE_API_KEY present (length=<N>)
✓ ANTHROPIC_API_KEY present (length=<N>)
✓ Diagnostic packages built
✓ All pre-flight checks passed; no API calls made
```

### Step 2.5 — Live smoke against Hays plc (~3 min)

```bash
bash scripts/run-diagnostic-smoke.sh --firm "Hays plc" --sector recruitment
```

This makes real API calls to Companies House (free; <10 calls) and Anthropic (~$0.05). Expected: ~2-3 minute runtime, then a 12-section Markdown report at:
- Vault: `~/.ifos-local-vault/migration-test/diagnostic-reports/hays-plc-*.md`
- Archive: `docs/artefacts/diagnostic-hays-plc-*.md`

### Step 2.6 — Confirm back to me

Reply with **exactly**:
```
Smoke run complete; report at <archive path>; <N>-section <M>-word
```

(The script prints the section count + word count at the end — copy them.)

If Gate A failed: paste the cycle.sh output around the failure line. I'll triage.

**What I do on your reply:** open the archived report, sanity-check the 12 sections + per-section citations + the LLM §12 conversation opener voice quality; flag any quality issues; mark Trigger 2 CLOSED in current-priorities.

---

## ⚡ PRIORITY 3 — Accept ADR-007 (~10 seconds)

Reply with exactly:
```
Accept ADR-007
```

**What I do on your reply:** flip ADR-007 Status from "Proposed (...) The ULTRAPLAN amendments below are applied PROVISIONALLY..." → "Accepted (founder-arbitrated 2026-05-31). ULTRAPLAN amendments are permanent." + remove the "reverts if rejected" clause + commit. Concierge §10 Proposed→Accepted blocker satisfied.

---

## 🟡 PRIORITY 4 — Bullhorn A+B chase (~5 min)

**Why this priority:** Bullhorn partnerships form was submitted 2026-05-24 (7 days ago). The 2-5 business-day response window is past. Force-fallback fires 2026-06-10 (10 days). Chase now.

### Step 4.1 — Send the chase email

Send this email (edit the name + reference if you have the contact). Address it to `partnerships@bullhorn.com` OR the named contact who acknowledged your original submission.

**Subject:** Following up: IFOS partner-programme enquiry submitted 2026-05-24

**Body:**

```
Hi [Name / Partnerships team],

Following up on the partner-programme enquiry I submitted via the
become-a-partner form on 2026-05-24. Reference number [if you have one]:
[insert].

We're an early-stage agency-tech product (Intel Force OS) building a
recruitment-operations automation layer on top of Bullhorn, with a pilot
agency lined up. Two questions remain blocking on our side:

  A. For production tenants reading + writing Bullhorn data on behalf of
     UK recruitment agencies via our hosted SaaS — is marketplace partner
     enrolment a hard requirement, or can per-tenant OAuth credentials
     suffice for v1.0 (≤3 tenants)? If marketplace is required, what's
     the cost + timeline to enrolment?

  B. For our integration scoping (read placement + candidate; write
     activity-log + note; per-tenant OAuth via auth-code flow) — is there
     a dev-tenant model we can use for staging, separate from the
     production tenant's data?

Happy to jump on a 20-min call if easier than email. Otherwise a quick
written response on A + B unblocks our W4-5 build sprint.

Thanks,
Maddox
[contact]
```

### Step 4.2 — Confirm back to me

Reply with:
```
Bullhorn chased
```

When the response arrives, paste their answer (full body OK; no need to redact). I'll fold it into Janitor / Scribe / Sourcing Scout / Concierge §8 build-prerequisite rows.

---

## 🔴 PRIORITY 5 — Q1 LOI status with Jack (~5 min)

**Why this priority:** Trigger 1 fires **2026-06-03 (3 days)**. If no LOI signed by then, Week 0 escalates to PAUSE per `v1.0-kill-criterion.md`. This is the single biggest external gate.

I can't help here — it's between you and Jack. But:

- Text Jack today: "Where are we on the design-partner LOI? Trigger 1 fires Wed 2026-06-03 — if we don't have something signed (even a 1-page heads-of-terms) by then, we escalate to scope-cut review per the kill-criterion doc. Are we on track or do we need a Plan B?"
- If Jack's already close: great, ride that.
- If Jack's stuck: think about Plan B (warmer outreach, scope-cut, deadline extension request).

Reply with **either**:
```
LOI on track; expected signed by <date>
```
**or**
```
LOI at risk; need to discuss Trigger 1 mitigation
```

If "at risk", I'll draft a 1-pager covering the founder-decision options per the kill-criterion §3 authority structure.

---

## 🟢 PRIORITY 6 — Commercial signups (deferrable — do as bandwidth allows)

These don't block this week's work. Knock them out as time allows over the next 2-3 weeks; ordered by when they unblock the build sequence:

### 6.1 Xero developer account (~15 min) — unblocks live Cash Conductor test

- URL: **https://developer.xero.com/**
- Cost: free (developer tier)
- Sign up → create an app called "IFOS Cash Conductor" → choose **Web App** flavour → set redirect URI to `https://migration-test.ifos.app/oauth/xero/callback` (placeholder; we'll wire properly at W4-5)
- Note the **Client ID** + **Client Secret** somewhere safe; don't save them to `_secrets.env` yet — we'll do that when the Xero MCP connector lands

Reply: `Xero dev signup done; credentials saved separately` — no key paste.

### 6.2 Fathom OR Fireflies (~10 min) — unblocks W6 Scribe build

Pick one (you can swap later):

- **Fathom**: https://fathom.video/ — $19/mo per seat; UK presence; tighter Bullhorn ecosystem ties; easier per-call webhook setup
- **Fireflies**: https://fireflies.ai/ — $29/mo per seat; broader transcript-model coverage; better international presence

Sign up → request API access (sometimes a separate step beyond the seat licence; check developer docs).

Reply: `Fathom signed up` or `Fireflies signed up`.

### 6.3 Proxycurl (~10 min) — unblocks Sourcing Scout W9 + Diagnostic LinkedIn deep data

- URL: **https://nubela.co/proxycurl/**
- Cost: $39/mo for 5,000 credits (low-volume v1.0 sufficient; scales with usage — Cash Conductor §8 estimates $20-50/day at peak per consultant)
- Sign up → grab the API key → save to the vault:

```bash
echo 'PROXYCURL_API_KEY=<key>' >> ~/.ifos-local-vault/migration-test/_secrets.env
```

Reply: `Proxycurl key saved`.

### 6.4 Reed + CV-Library (~15 min each) — unblocks W9 Sourcing Scout multi-source

These are UK-recruitment-specific; both have enterprise APIs (no self-service). Email each:

- **Reed**: https://www.reed.co.uk/recruiter-api → "Contact us for API access"
- **CV-Library**: https://www.cv-library.co.uk/recruitment-software/api → "Contact us"

Email template (adapt as needed):

```
Subject: API access enquiry — IFOS (recruitment-tech, UK)

Hi,

We're building Intel Force OS, an agency-tech product for UK recruitment
agencies. We're looking to integrate <Reed | CV-Library> candidate search
into our v1.0 Sourcing Scout agent, alongside Bullhorn + LinkedIn.

Could you share:
  - API access pricing + tier
  - Sandbox/dev access for integration testing
  - Rate limits + auth model

Happy to jump on a call.

Thanks,
Maddox
```

Reply per: `Reed enquiry sent` / `CV-Library enquiry sent`.

---

## ⏱ Daily progress sync — how to ping me

You'll be doing manual stuff at your pace; I'm working in parallel. Use these one-liners to keep me synced:

| When you finish | Reply with |
|---|---|
| v0.3 migration | `v0.3 applied; tenancy audit 12/12` |
| API keys saved + smoke ran | `Smoke run complete; report at <path>; <N>-section <M>-word` |
| ADR-007 stamp | `Accept ADR-007` |
| Bullhorn chase sent | `Bullhorn chased` |
| Bullhorn response arrives | `Bullhorn response: <paste full body>` |
| Jack/LOI update | `LOI on track; expected <date>` OR `LOI at risk` |
| Xero/Fathom/Proxycurl etc. signed up | `<service> signup done` (no key paste needed unless asked) |

For anything else (errors, questions, "is this right?"), just paste/describe and I'll triage.

---

## What I'm doing in parallel

While you work this playbook, I can either:

- **(A)** Wait for the priority-1/2/3 confirms before starting the W4 Track-1 /goal (cleaner sequencing — no risk of building against absent infra).
- **(B)** Start the W4 Track-1 /goal now in this session — Day-1 work is substrate verify + `review-mcp-connector.md` Codex skill + Diagnostic live-smoke wrapper (already done ✓). Day-2 onward is the Xero MCP connector scaffold (fixture-first; doesn't need v0.3 migration applied).

Default: **(A)** — wait for your "v0.3 applied" + "smoke run complete" + "Accept ADR-007" confirms (the 55-minute set), then I start the /goal with everything ratified, applied, and audited beneath it.

Override with `start the /goal now` and I switch to (B).

---

## Reference — file locations cited above

| What | Path |
|---|---|
| v0.3 migration wrapper | `scripts/run-v0.3-migration.sh` |
| Tenancy audit script | `scripts/run-tenancy-audit.sh` |
| Diagnostic live-smoke wrapper | `scripts/run-diagnostic-smoke.sh` |
| Local vault (your laptop) | `~/.ifos-local-vault/migration-test/` |
| Secrets file (mode 0600) | `~/.ifos-local-vault/migration-test/_secrets.env` |
| ADR-007 (don't open; I edit) | `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md` |
| D1 decision doc | `docs/decisions/2026-05-31-d1-founder-decision.md` |
| W4 Track-1 /goal | `docs/operations/goal-week-4-track-1.md` |
| Current priorities | `.agents/current-priorities.md` |

---

*End of playbook.*
