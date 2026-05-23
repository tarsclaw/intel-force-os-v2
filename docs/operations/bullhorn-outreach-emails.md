# Bullhorn outreach — ready-to-send email drafts

**Status:** Reference (operations playbook for Bullhorn commercial conversations)
**Date:** 2026-05-23 (Day 12)
**Purpose:** Drop-in email drafts the founder sends to Bullhorn partnerships + developer support to resolve Sub-decisions A + B in `docs/decisions/bullhorn-integration-path.md`. Closes Risk #2 mitigation path; unblocks Janitor W5 build gate.

**What this is NOT:** sent on the founder's behalf. Founder must send from his own email address (commercial conversation; needs founder identity + reply-receiving capability).

---

## §1 — Context (read this before sending)

Per `bullhorn-integration-path.md` §1.3:
- **Sub-decision A** (marketplace vs direct API): both paths technically work. The choice is commercial: cost, certification timeline, per-tenant friction.
- **Sub-decision B** (OAuth flow specifics): we've verified the structural shape from Bullhorn's public docs (authorization-code + refresh-token; per-tenant `corpToken` and `restUrl`). Need confirmation of specifics: refresh-token TTL behaviour, rate-limit caps, sandbox environment availability.

**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.

**Sub-decision C** (v1.0 endpoint surface) is already Accepted in the doc — no commercial dependency.

---

## §2 — Email 1: Bullhorn Partnerships (Sub-decision A)

**To:** `partnerships@bullhorn.com`
**Subject:** Partnership programme enquiry — Intel Force OS (UK recruitment AI SaaS)

> Hi Bullhorn Partnerships team,
>
> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
>
> Before we build the connector, I want to understand the right path forward and would appreciate clarity on a few questions:
>
> **1. Marketplace partner programme vs direct API access:**
> Is membership in the Marketplace Partner Programme required for production tenants to connect Intel Force OS to their Bullhorn instances? Or can pilot tenants authorise us as a connected app via the standard developer-tier path (support-ticket-issued client_id/client_secret per https://bullhorn.github.io/Getting-Started-with-REST)?
>
> **2. Cost + timeline at pilot scale:**
> If marketplace membership is required (or recommended), what is the annual partner fee at our expected 3-6 pilot tenant volume in 2026 H2? Is there a one-time certification fee, security review, or other upfront cost? What is the typical application-to-listing timeline?
>
> **3. Scope deltas:**
> Are there API rate-limit, scope, or endpoint deltas between marketplace-tier and direct-tier access at small pilot volume? Specifically: do marketplace partners get elevated rate limits, write access to entity types not available to direct-tier, or webhook subscription endpoints that the documented REST API doesn't expose?
>
> **4. Per-tenant onboarding friction:**
> If marketplace tier grants Intel Force OS application-level credentials (one client_id per IFOS app), per-tenant onboarding could be reduced to a single OAuth dance per pilot tenant. Confirming this is the marketplace model (vs each tenant raising their own support ticket as documented for direct-tier).
>
> Happy to jump on a call if useful.
>
> Best,
> Maddox Rigby
> Founder, Intel Force Ltd
> [your email]
> [your phone if comfortable]

**Expected response time:** 2-5 business days. If no response by Wednesday 2026-05-28: nudge with a one-line follow-up referencing the original message.

**What to do with the response:**
- If they confirm direct-tier works for pilot scale → Sub-decision A flips to **Direct API**; Status: Accepted. Update `bullhorn-integration-path.md` §5.
- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
- If they offer a Bullhorn Developer Program intermediate tier → that's likely the right path for 2026 H2 pilots; defer marketplace to v1.1+.
- Save the response to: `docs/operations/bullhorn-partnerships-response-2026-05-XX.md` (date the day it arrives) so we have audit trail.

---

## §3 — Email 2: Bullhorn Developer Support (Sub-decision B)

**To:** Use the Bullhorn Developer Portal contact form at `https://developer.bullhorn.com/` (redirects to https://bullhorn.github.io/docs). If no contact form, ask partnerships rep (Email 1) to introduce you to developer support.
**Subject:** OAuth flow specifics + sandbox availability — Intel Force OS pre-build verification

> Hi Bullhorn Developer Support,
>
> I'm Maddox Rigby, building Intel Force OS — an AI agent integration for UK recruitment agencies. Before we scaffold the OAuth + REST connector, I want to verify a few specifics that aren't fully covered in the public documentation at https://bullhorn.github.io/Getting-Started-with-REST.
>
> Our architecture: per-tenant OAuth (authorization-code grant) with refresh-token rotation. Each pilot tenant authorises Intel Force OS as a connected app via Bullhorn's standard OAuth flow. We store the refresh_token per-tenant, exchange it for access_tokens + BhRestToken on demand.
>
> Questions:
>
> **1. Refresh-token TTL and rotation:**
> What is the documented refresh-token TTL? When a refresh_token is exchanged for a new access_token, does the refresh_token itself rotate (single-use) or remain valid (long-lived)? Our connector polls Bullhorn every 5 minutes per pilot tenant — we need to plan for graceful refresh-token renewal under that cadence.
>
> **2. Concurrent-refresh behaviour:**
> If two parallel processes for the same pilot tenant attempt token refresh concurrently (race condition), what's the expected server behaviour? Does Bullhorn invalidate the older refresh_token on a successful exchange, or accept both?
>
> **3. Sandbox environment:**
> Is there a sandbox / staging Bullhorn environment we can use for development without consuming production-tier API budget? If yes, what's the access path (separate credentials, sandbox-only client_id, or in-production with a "test corpToken")?
>
> **4. Client_credentials grant:**
> Does Bullhorn's OAuth 2.0 implementation support the client_credentials grant type for service-account-style access (against our own developer-tier tenant, not pilot tenants)? We want to use this for IFOS-internal CI testing and connector unit-test fixtures. The public docs reference only authorization-code grant.
>
> **5. Rate limits at small pilot scale:**
> Public REST docs reference HTTP 429 + "wait 1 second" but don't name caps. At 3-6 pilot tenants polling every 5 minutes (peak ~72 calls/minute aggregate), are we comfortably within rate-limit budget, or do we need to negotiate elevated limits?
>
> **6. Webhook / event subscription:**
> Public REST docs describe pull-only model. Is there an undocumented webhook or event-subscription mechanism available to integration partners? If not, we'll proceed with the polling model (already designed); if yes, we'd prefer to subscribe to placement-state-change events directly.
>
> All these answers go into our pre-build architecture decision document. Happy to share the relevant section once we have your input.
>
> Best,
> Maddox Rigby
> Founder, Intel Force Ltd
> [your email]

**Expected response time:** 2-5 business days (often faster for technical-tier developer support than partnerships).

**What to do with the response:**
- Refresh-token rotation behaviour determines `packages/mcp-connectors/bullhorn/src/auth.ts` design. If single-use rotation → atomic refresh logic with lock around `_secrets.env`. If long-lived → simpler.
- Sandbox available → use it for CI tests + W5 build. Save credentials to your local 1Password as "IFOS Bullhorn Dev sandbox".
- Save response to `docs/operations/bullhorn-developer-response-2026-05-XX.md`.
- Update `bullhorn-integration-path.md` §6 (refresh-loop architecture) with the confirmed numbers.

---

## §4 — Tracking the responses

When responses land, do this in this order:

1. **Save response** as a dated file under `docs/operations/` (don't paste into chat — long messages clutter the conversation).
2. **Tell Claude:** "Bullhorn partnerships responded — saved at `docs/operations/bullhorn-partnerships-response-2026-05-XX.md`"
3. Claude will update `bullhorn-integration-path.md` §5 (Sub-decision A) or §6 (Sub-decision B) Status from Proposed → Accepted (or document any new findings).
4. Risk #2 in `RISK-REGISTER.md` updates from High → Medium → Low as A + B both flip Accepted.

---

## §5 — If Bullhorn doesn't respond within a week

Escalation path:
1. **Wednesday 2026-05-28** — one-line nudge ("just bumping this — any update?")
2. **Monday 2026-06-01** — second nudge with explicit deadline reference ("we're targeting Janitor build W5; need clarity by then")
3. **Wednesday 2026-06-03** — LinkedIn outreach to a named Bullhorn employee in partnerships or developer relations. Search "Bullhorn partnerships" or "Bullhorn developer advocacy" on LinkedIn; aim for a UK-based person if available.

**Hard cutoff:** if no response by 2026-06-10 (3.5 weeks from today), Sub-decision A is forced to **Direct API** (lowest-friction path; commercial verification deferred to post-pilot) and the connector scaffolds against that — per the §2.3 §1.4 fallback architecture in `bullhorn-integration-path.md` which was designed for exactly this scenario.

---

## §6 — Status

**Reference.** Two drop-in email drafts ready for founder to send. Expected wall-clock: 1 week for both responses. Outcome: Sub-decisions A + B flip Accepted; Risk #2 mitigated; Janitor W5 build unblocked.

*End of Bullhorn outreach emails.*
