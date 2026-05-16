# Bullhorn integration path — decision document

**Date:** 2026-05-16 evening / 2026-05-17 (Week 0, Day 2)
**Status (top-level):** Mixed — Sub-decision C **Accepted**; Sub-decisions A and B **Proposed pending commercial verification per §1.3**
**Author:** Claude Code, with founder commercial verification pending
**Surfaced by:** Master brief §6 Day 2 (lines 466-467) — "Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev." Plus Ultraplan §11 Day 2 (lines 847-849).
**Submodule SHA referenced:** `c21fbfe991a0030ea055bd8e2389a0801a424383`

**Reading order:** master brief §6 Day 2 + §8.2 (agent dependencies) + §3.2 (adapter boundary first-party MCP list) first; then this document end-to-end; then `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` §2.4.2 + `agent-bundle-renderer-design.md` §2.1 spec gap §2.1-C for the credential storage substrate this decision feeds into.

---

## Section 1 — Context and commercial blockers

### 1.1 — What we're deciding

Three sub-decisions, named in master brief §6 Day 2 line 466 and extended in Ultraplan §11 Day 2 lines 847-849.

**Sub-decision A — Bullhorn integration path.** Marketplace partner programme membership (with its access tier, scope, certification, ongoing fees) versus direct API access (per-tenant Bullhorn-account-admin authorisation of IFOS as a connected app). Master brief §6 Day 2 line 466 explicitly names this as the day's decision. The path chosen determines whether `packages/mcp-connectors/bullhorn/` ships as a marketplace-registered connector or a direct-API connector — the *code* in either case is similar OAuth + REST plumbing, but the *operational, commercial, and rate-limit* surfaces differ materially.

**Sub-decision B — OAuth flow.** Master brief §6 Day 2 line 466 pre-states a recommendation: "browser dance for production, service-account for dev." This is the authorization-code grant (per-tenant browser dance, refresh-token cycle) for production tenants, plus client-credentials grant (service account) for IFOS-internal sandbox/dev work. Sub-decision B verifies that recommendation against Bullhorn's actual OAuth implementation and pins the per-tenant token storage path (per `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution: `/vault/<tenant>/_secrets.env`, mode `0600`).

**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.

### 1.2 — Why this matters now

Master brief §12 Risk #2 (Bullhorn auth path) — "Bullhorn MCP build takes longer than 1 week" — names this as one of the four risks that could kill v1.0. Tripwire: "End of week 3 status not 'core read endpoints working'" (master brief §12 row #2, Ultraplan §10 row #2). The mitigation is "Week 0 Day 2 on Bullhorn auth research" — i.e. this document. Without Sub-decisions A and B answered, Week 1 cannot begin scaffolding `packages/mcp-connectors/bullhorn/` because the connector's authentication path determines its scope and shape.

**Bullhorn dependency count for v1.0 agents:**

| Agent | Bullhorn dependency in v1.0 | Source |
|---|---|---|
| A1 Diagnostic | No (LinkedIn + Companies House + web scrape) | Master brief §8.2 line 601; Ultraplan §8.1 A1 line 495 |
| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
| A3 Scribe | **Yes — write** (post-call structured-field write-back + tacit-note attach) | Master brief §8.2 line 603; Ultraplan §8.1 A3 line 518-522 |
| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
| A5 Sourcing Scout | **Yes — read** (ATS passive-match lookup) | Ultraplan §8.1 A5 line 547-551 |
| A6 Concierge | **Yes — read state + write activity log** (lifecycle event triggers) | Master brief §8.2 line 606; Ultraplan §8.1 A6 line 561-564 |

**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.

This is also the Day 2 critical-path artefact for the §6 Day 7 single-sentence test (master brief §6 lines 494-502, Ultraplan §12 lines 887-895), question 3: "Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?" A Yes answer requires this document plus the Sub-decision A and B confirmations to land before Sunday review.

### 1.3 — What we know vs what we don't

Honest accounting of which sub-decisions can land tonight from technical analysis alone versus which require commercial verification before the Status flips from Proposed to Accepted.

**Technically grounded (Claude Code can analyse tonight from Bullhorn public documentation + master brief / Ultraplan / product spec context):**

- The structural shape of Bullhorn's OAuth flows (authorization code vs client credentials) and which scenarios each is suited to.
- The endpoint surface area available via the public REST API at `https://rest.bullhornstaffing.com/rest-services/<corpToken>/` (the documented entry pattern).
- Token lifecycle outline: short-lived REST sessions, long-lived refresh tokens, periodic re-auth dance via the Bullhorn login URL.
- Pagination / rate-limit *shape* (per-second + per-minute + per-day caps in some accounts).
- Per-tenant credential storage location (resolved by `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C: `/vault/<tenant>/_secrets.env`).
- The per-agent endpoint surface in Sub-decision C — fully derivable from master brief §8.2 and Ultraplan §8.1 agent specifications.

**Commercially gated (founder must verify before final Status flip to Accepted on Sub-decisions A and B):**

- Whether Intel Force Ltd is currently a member of the **Bullhorn Marketplace Partner Programme** (or what the application timeline + cost would be). The marketplace partner application process is publicly known to involve a technical review, security audit, and ongoing partner fees — but the specifics for IFOS's tier and tenant volume are commercial-confidential and need a direct conversation.
- Whether **marketplace-tier API access differs from direct-API access** in rate limits, available scopes (e.g. write to JobOrder, write to Note, webhook subscription), or sandbox availability. Bullhorn's public docs are sparse on the deltas; partner reps know the actuals.
- Whether the marketplace-tier cost structure works at IFOS's volume (3-6 tenants v1.0; 100 by end of 2027 per Product Spec §5.4 line 369-373). Partner fees may be flat or per-tenant; this matters at scale.
- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.

**Commercial-blocker table** — specific question, specific contact path, specific timing:

| Sub-decision | Commercial gate question | Who answers | When | Notes |
|---|---|---|---|---|
| A | "Is Intel Force Ltd in the Bullhorn Marketplace Partner Programme, or what's the application timeline + first-year cost?" | Bullhorn partnerships team — `partnerships@bullhorn.com` is the public alias; founder may have a named partner manager contact from prior conversations | Sunday outreach (likely Monday response given UK weekend) | If founder has no existing partner-rep relationship, this is a cold inbound; ETA on first response 2-5 business days |
| A | "What are the API rate-limit / scope deltas between marketplace tier and direct API at our expected 3-6 tenant pilot volume?" | Same Bullhorn partnerships team, or escalation to developer support | Same conversation | The answer determines whether direct-API can serve v1.0 or marketplace registration is a v1.0 blocker |
| A + C | "Which ATS does design partner #1 use — Bullhorn, Vincere, Voyager Infinity, or another?" | **Founder** — Sunday design-partner conversation 2 per master brief §6 Day 2 line 467 | Sunday/Monday | If Bullhorn: Sub-decision A path proceeds as analysed. If non-Bullhorn: the v1.0 ATS anchor changes, this document's Sub-decisions are scoped to "Bullhorn is the second-tenant ATS" rather than "v1.0 first-tenant ATS" |
| B | "Does Bullhorn's OAuth implementation support client_credentials grant against the sandbox environment?" | Bullhorn developer support — `developer.bullhorn.com` portal contact form, or via the partnerships rep once Sub-decision A's contact path is open | Monday-Tuesday | Used to verify that the §6 Day 2 line 466 recommendation ("browser dance for production, service-account for dev") is implementable end-to-end |
| B | "Refresh-token TTL and rotation behaviour specifics" | Same | Same | Affects renderer §3.3.2 `.env` materialisation: how often does per-tenant `_secrets.env` need rotation? Documented Bullhorn behaviour varies by account; partner-rep gives the canonical numbers |

The Sunday design-partner conversation 2 is the most time-sensitive: it can flip the entire premise of Sub-decisions A and C. Founder cadence per master brief §6 Day 2 (line 467) and §11.2 line 791 ("Day 2 — Tuesday — Bullhorn integration path... — Design-partner conversation 2") puts this as a parallel-to-Claude-Code track.

### 1.4 — Tonight's scope

Stated explicitly so the founder knows what's landable tonight vs what waits for commercial answers:

- **Tonight (this document):**
  - Sub-decision C in full — technical analysis, per-agent endpoint table, webhook-vs-poll decisions, rate-limit budget allocation. **Status: Accepted** on Sub-decision C alone, no commercial gating.
  - Sub-decisions A and B — full technical analysis (Sections 2 and 3 of this document), with explicit Status: Proposed flags pointing at the §1.3 commercial-blocker table.
  - Recommendation block (§5) names the technical preference, the commercial-answer conditions that flip Status to Accepted, and the documented v1.0-scope-cut contingency if commercial answers go badly.
- **Sunday (2026-05-17):**
  - Founder runs design-partner conversation 2 — primary gate is "which ATS does the first pilot use?". Result lands as a one-line update to this document's §1.3 row 3.
  - Founder runs Bullhorn partnerships outreach — likely email to `partnerships@bullhorn.com` or named contact if any. Result may not come back same-day.
- **Monday (2026-05-18):**
  - Founder runs Bullhorn developer-support outreach for Sub-decision B specifics if not already covered by partnerships rep.
  - Final Status flip on Sub-decisions A and B based on commercial answers landed.
  - Document is re-committed with Status: Accepted on A and B once founder logs the decision.
- **Day 7 review (master brief §6 Day 7 Sunday):**
  - Single-sentence test Q3 ("Have we cleared the auth path?") answered Yes iff Sub-decisions A and B are Accepted.
  - This document joins the first Codex ratification run alongside the other Week 0 artefacts per master brief §10.6.

If commercial answers don't land by Monday — i.e. the partnerships outreach response is slow — Sub-decisions A and B can stay Proposed without blocking Week-1 implementation, because Sub-decision C is already Accepted and the v1.0 endpoint surface is fully specified. The connector code can be scaffolded against direct-API as the default; if Sub-decision A subsequently lands as marketplace-required, the connector's authentication module is the only piece that changes (a few hundred lines, isolated). This is the documented honest signal per master brief §1 Rule 5.

---

## Section 2 — Sub-decision A: marketplace vs direct API

### 2.1 — Bullhorn marketplace partner programme

Bullhorn's public surfaces for the partner programme are deliberately thin. Three URLs surveyed Day 2 (2026-05-16 evening):

- `https://www.bullhorn.com/marketplace/` — consumer-facing directory of "300+ pre-integrated technology partners" filterable by category / location / platform. The only partner-programme reference on the page is the line: **"Become a partner — Are you a supplier to the recruitment space? Join the Marketplace today."** This routes to `/become-a-partner/`.
- `https://www.bullhorn.com/become-a-partner/` — landing page. Main CTA: **"Fill out the form to learn more about our partner programs."** References three external resources (FAQs, Bullhorn Developer Program, Fair Use Policy) but the page itself contains **no specific information** on application process, tiers, certification, security review, fees, ongoing costs, or timeline. The only substantive description on the page is: **"The Bullhorn Marketplace gives our customers the choice, confidence, and customization they need to innovate with agility."**
- `https://www.bullhorn.com/marketplace/partners/` — returns HTTP 404 (verified 2026-05-16).

**What is publicly stated:**

- The programme exists and admits "suppliers to the recruitment space."
- Bullhorn Marketplace currently lists 300+ partner integrations (the headline number on the marketplace page).
- There is a separately-named **Bullhorn Developer Program** distinct from the Marketplace partner programme (linked from `/become-a-partner/`) — implying a possible two-tier structure: developer-tier access to APIs (lighter) vs marketplace-listed partner (heavier).

**What is NOT publicly stated** (confirmed commercially gated to founder verification per §1.3):

- The application process (forms to fill, technical review steps, security audit requirements).
- Whether the programme has tiers (e.g. Standard / Premier / Strategic) and what gates each tier.
- Whether marketplace-tier partners get different API scope, rate-limit ceilings, or webhook access vs direct-API/developer-tier.
- Annual partner fees, certification costs, MRR thresholds, revenue-share or referral economics.
- Application-to-approval timeline.
- Co-marketing benefits, listing visibility on the marketplace page, lead-routing programmes.

**Source citation for this section:** the three URLs above, all accessed 2026-05-16.

**Inference (clearly marked as inference, not Bullhorn's stated position):** the gap between "free developer account" and "marketplace-listed partner" is structurally common across enterprise SaaS platforms (Salesforce AppExchange, HubSpot Marketplace, ServiceNow Store all follow this pattern). The plausible IFOS path through this commercial space is: register for the Bullhorn Developer Program first (which usually grants API access for a tenant the developer controls or for sandbox dev), then apply for marketplace listing once an integration is shippable. Whether either path is required for IFOS production tenants — the actual gate — is the §1.3 partnerships@bullhorn conversation.

### 2.2 — Direct Bullhorn API access

Two URLs surveyed:

- `https://developer.bullhorn.com/` — redirects to `https://bullhorn.github.io/docs` (301 Moved Permanently).
- `https://bullhorn.github.io/docs` — Bullhorn's developer documentation landing. Names three API surfaces: REST API, OAuth, SOAP (legacy). The REST and OAuth links are the operative ones for v1.0.

**The technical model verified from Bullhorn's "Getting Started with REST" documentation (cited inline below):**

- **Two-step auth.** Step 1: OAuth 2.0 authorization-code grant against `https://auth-{loginInfo}.bullhornstaffing.com/oauth/authorize` returns an auth code; POST to `/oauth/token` exchanges code for an access_token + refresh_token. Step 2: REST login at the per-tenant `restUrl` exchanges the access_token for a `BhRestToken` (the REST session token) plus a per-tenant base URL.
- **`BhRestToken` (REST session token)** is presented on each subsequent REST call in three accepted forms: URL query parameter, HTTP header (`BhRestToken` or `BHRestToken`), or cookie. On expiry, REST calls return 401 — application must re-run /login. (Bullhorn doc verbatim: "When the current session key expires, your query will return a 401 response.")
- **Per-tenant model.** Each tenant has its own `corpToken` and its own per-tenant `restUrl` returned by /login. Operations are scoped by the corpToken; IFOS must hold per-tenant token state. This maps cleanly to the per-tenant credential model already pinned in `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution (`/vault/<tenant>/_secrets.env`, mode `0600`).
- **client_id / client_secret acquisition.** Bullhorn doc verbatim: **"Bullhorn customers can obtain OAuth keys for developing applications...by creating a support ticket via the Bullhorn Resource Center."** This is not a self-service developer signup — there is a Bullhorn-side gate even for the developer-tier path. Implication: every IFOS pilot tenant must open a support ticket with Bullhorn to authorise IFOS as a connected app, or IFOS must hold a single set of client credentials at the IFOS-application level and route per-tenant auth through it. The structural distinction here is exactly what Sub-decision A pivots on — partnerships@bullhorn confirms whether marketplace status grants application-level credentials.
- **Documented rate limit signal:** Bullhorn's REST docs name **HTTP 429** as "Rate Limited — Wait 1 second then retry request. Repeat until successful." That's the only rate-limit reference in the public docs surveyed; specifics (per-second/minute/day caps, per-corpToken or per-application) are not documented and are commercially gated to verification per §1.3.
- **Sandbox environment availability:** not addressed in any public doc surveyed. Commercially gated.

**Citations:**

- `https://bullhorn.github.io/docs` — landing page naming REST/OAuth/SOAP API surfaces.
- `https://bullhorn.github.io/rest-api-docs/` — REST API reference, named two-step auth and 429 rate-limit handling.
- `https://bullhorn.github.io/Getting-Started-with-REST` — auth flow specifics (endpoint URLs, token TTLs, refresh-token rotation, credential acquisition path).

### 2.3 — Comparison rubric

Eight criteria. Cells marked **CG** (commercially gated) require founder verification per §1.3 before flipping from inference to confirmed.

| Criterion | Marketplace | Direct (Developer Program) |
|---|---|---|
| Time-to-first-call (greenlight → working API call against a tenant) | **CG.** Inference: marketplace certification + security review typically 4-12 weeks for enterprise SaaS programmes of this maturity. Bullhorn-specific timeline not stated publicly. | **CG.** Confirmed from public docs: customer raises Bullhorn support ticket per /Getting-Started-with-REST to obtain client_id/client_secret. ETA per ticket cycle — likely 1-5 business days per pilot tenant. |
| Per-tenant onboarding friction (admin auth, scope review) | **CG.** If marketplace tier grants IFOS application-level credentials, per-tenant friction may reduce to "tenant clicks Authorise from marketplace listing." | Each pilot tenant raises a Bullhorn support ticket + tenant admin authorises IFOS as a connected app via per-tenant OAuth screen. Per-tenant friction: 1 support ticket + 1 OAuth dance per pilot tenant. |
| Co-marketing benefit | Listed in the 300+ partner directory on bullhorn.com/marketplace; potentially Bullhorn-sales-rep co-selling motion. **CG** on specific benefit terms. | None. |
| Cost at 3-tenant pilot scale (2026 H2, Boutique tier per Product Spec §3.1) | **CG.** Public docs do not name partner fees. Inference based on comparable enterprise SaaS marketplace programmes: annual partner fee typically $5K-$25K + possibly per-listing or per-referral revenue-share. | **CG.** Public docs do not name developer-program fees. Inference: likely zero or nominal for the developer-tier API access. Per-tenant cost zero — the tenant pays Bullhorn, IFOS pays nothing per call. |
| Cost at 100-tenant target scale (Product Spec §5.4 end-2027 target) | **CG.** May or may not scale linearly with tenant count. Some marketplace programmes have flat annual fees; others meter on tenant or revenue volume. | **CG.** If developer-tier cost is zero or nominal, scales fine. Risk: per-tenant Bullhorn support tickets at 100 tenants become operational drag at IFOS-Customer-Success layer (Product Spec §5.4 line 373 names ≤8 hours of human time per customer onboarding — Bullhorn ticket may consume a meaningful fraction). |
| Scope / rate-limit deltas | **CG.** Marketplace tier may grant elevated rate limits, write access to additional entities (e.g. JobOrder write), webhook subscription endpoints not available to direct-tier. Public docs do not state. | Public REST API documentation lists all REST endpoints uniformly — no tier-gated endpoints stated in public docs. Inference: all entity reads/writes are available to authenticated direct-tier callers, subject to per-corpToken scope at the tenant-account-admin level. Rate limit ceiling **CG**. |
| Founder operational overhead (per tenant + ongoing) | **CG.** If marketplace handles per-tenant auth: low per-tenant overhead. Annual partner-programme obligations: technical review responses, security questionnaire renewals, marketplace listing maintenance — non-trivial ongoing. | Per-tenant: one Bullhorn support ticket request from the tenant admin per pilot. Ongoing: zero programme obligations; only IFOS-side OAuth token refresh management. |
| **Switching cost later** (start direct, move to marketplace at v1.1+) | n/a (this is the destination) | **Low if the connector code treats auth as a swap-point per §1.4 fallback architecture.** The connector's REST endpoint calls (Sub-decision C surface) are identical between paths. The auth module — `packages/mcp-connectors/bullhorn/src/auth.ts` and the `_secrets.env` materialisation in the renderer — is the only differing surface. Bounded to ~200-400 lines of code per the design in `agent-bundle-renderer-design.md` §3.3.4. |

The **Switching cost** row is the load-bearing design constraint. It validates the §1.4 fallback architecture: the connector can scaffold against direct-API in Week 1-2 without locking in the wrong long-term path. If Sub-decision A lands as marketplace-required in Week 1-2 founder commercial verification, the swap is a Week-2-3 task scoped to the auth module.

### 2.4 — Technical recommendation (Proposed)

**Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes.**

Three justifications:

1. **The §1.4 honest-signal fallback architecture demands it.** With Bullhorn commercial answers slow-rolling (likely Monday at earliest, possibly later), Week 1 connector scaffolding cannot block on partnerships@bullhorn responses. Scaffolding against the documented direct-API auth flow lets the connector progress; the §2.3 Switching-cost analysis shows the auth-module swap is bounded.
2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
3. **Marketplace is a commercial decision, not a technical one, at v1.0 scale.** At 3-6 pilot tenants, the marketplace's primary benefit (co-marketing, listing visibility, possibly elevated rate limits) is dominated by the per-tenant pilot economics. The marketplace partnership is appropriate when IFOS has shippable product and 10+ tenants — i.e. v1.1+ commercial timing.

**Commercial answers that flip the recommendation:**

| Commercial finding | Effect on recommendation |
|---|---|
| Marketplace tier is **required** for production tenant onboarding (partnerships@bullhorn answer) | Connector scaffolds against direct-API on a Bullhorn-sandbox tenant for IFOS internal dev; marketplace registration becomes Week-1 critical-path commercial work; v1.0 build slips by the marketplace certification timeline (potentially 4-12 weeks per §2.3 row 1 inference). This is a v1.0 blocker scenario and feeds master brief §12 Risk #2 directly. |
| Marketplace adds material per-tenant cost above ~$1K/yr at 3-tenant scale (partnerships@bullhorn answer) AND direct-API scope is sufficient | Direct preferred for v1.0; marketplace deferred to v1.1+ when revenue funds the programme cost. Current recommendation stands. |
| Direct-API requires per-tenant Bullhorn support ticket that slows pilot onboarding by >3 business days per tenant (Bullhorn dev support answer) | Marketplace may win on time-to-first-call even if costlier. Re-evaluate based on actual ticket-cycle data from first pilot's setup. |
| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |

**Status: Proposed.** Status flips to Accepted on either: (a) partnerships@bullhorn confirms marketplace is not required for v1.0 production tenant access AND first design partner uses Bullhorn; OR (b) founder explicitly accepts the documented fallback if marketplace turns out required, and re-cuts the v1.0 timeline to absorb the marketplace certification window.

---

## Section 3 — Sub-decision B: OAuth flow

### 3.1 — Authorization-code grant (browser dance)

The flow Bullhorn documents at `https://bullhorn.github.io/Getting-Started-with-REST`. Verified specifics:

**Endpoint structure:**
- Authorise: `https://auth-{loginInfo}.bullhornstaffing.com/oauth/authorize`
- Token: `https://auth-{loginInfo}.bullhornstaffing.com/oauth/token`

The `{loginInfo}` placeholder is per-tenant-cluster — IFOS resolves it via the Bullhorn `loginInfo` lookup endpoint before kicking off OAuth. This is part of the connector's auth module.

**Standard 4-step flow:**
1. Per-tenant Bullhorn admin (or IFOS-on-behalf-of-admin if marketplace path enables it) hits the authorise URL with `client_id`, `response_type=code`, `redirect_uri`, `state`, and per-Bullhorn-docs the `username` + `password` query parameters as well (Bullhorn-specific: their authorize endpoint accepts credentials inline rather than a separate consent screen).
2. Bullhorn returns auth code to `redirect_uri`.
3. IFOS POSTs to token endpoint with `client_id`, `client_secret`, `grant_type=authorization_code`, `code`, `redirect_uri` — receives `access_token` + `refresh_token`.
4. IFOS POSTs to per-tenant REST `/login` with the `access_token` — receives `BhRestToken` + `restUrl` for that tenant.

**Token TTLs (Bullhorn doc verbatim):**

- **Access token: 10 minutes.** "The access token is valid for 10 minutes."
- **Refresh token: no fixed expiration, but rotates on each refresh.** "The refresh token has no expiration date/time, but it does expire when a new access token and refresh token are generated." Plus: "A new refresh token is returned with every new access token."
- **`BhRestToken` (REST session token):** TTL not numerically specified; expires per-session, returns 401 on expiry.

This rotation pattern matters operationally: IFOS must persist the **most recent** refresh_token after every token refresh, atomically overwriting the previous one in `/vault/<tenant>/_secrets.env`. A failure between obtaining the new refresh_token and persisting it permanently invalidates the previous one — the tenant admin must re-run the browser dance. **Spec gap §3.1-A:** the renderer + auth module need a refresh-token-persistence atomicity protocol. Recommended resolution: write to `_secrets.env.tmp` then rename, matching the atomic write pattern in `agent-bundle-renderer-design.md` §3.3.4.

**Scope of permissions requested at first auth:** Bullhorn's OAuth docs surveyed do not specify per-scope strings (e.g. `read:candidate`, `write:note`). REST API access appears to be at-tenant-admin-discretion — the admin authorises the connected app for "API access" generally, and the corpToken-scoped session inherits whatever entity permissions the admin's account holds. **Spec gap §3.1-B:** confirm with Bullhorn developer support that there is no per-entity-type scope granularity at the OAuth layer — i.e. IFOS cannot request "read-only" auth and get a token that can't write. If this is correct, then Gate A in `validate.sh` (per master brief §1 Rule 4) becomes the only enforcement layer for "this agent should never write" — the OAuth token itself does not protect.

**Failure modes documented in code by IFOS connector design:**

- Revoked token (tenant admin revokes IFOS access in Bullhorn admin UI) — REST calls return 401 indefinitely; IFOS catches, sends `ESC_BULLHORN_AUTH` escalation per master brief §8.1 Change 3 line 587 vocabulary.
- Refresh-token rotation failure (atomic persistence didn't land) — IFOS detects on next refresh call returning 400/401; same escalation, plus tenant-admin re-auth required.
- Bullhorn account suspended/cancelled — same 401 pathway; escalation routes to founder for tenant-relationship handling.
- Scope change by Bullhorn — unlikely without notice but possible; IFOS connector logs and escalates.

### 3.2 — Client credentials grant (service account)

**Bullhorn does NOT document a client_credentials grant in their OAuth specification.** Specifically verified at `https://bullhorn.github.io/Getting-Started-with-REST` — the grant types section names only the authorization-code flow. Inference from this absence (not contradicted by other surveyed docs): Bullhorn does not support client_credentials grant for tenant-scoped data access.

This forecloses one option that the master brief §6 Day 2 line 466 pre-statement contemplated — "service-account for dev." The closest substitute is one of:

- **IFOS holds a Bullhorn dev tenant** (separate from any production pilot) where IFOS performs authorization-code grant once against IFOS-internal admin credentials; the resulting access/refresh tokens serve as the "dev account" auth state. Tokens still rotate per §3.1; IFOS internal-dev tooling refreshes them.
- **Bullhorn sandbox tier** (if it exists — §2.2 noted sandbox availability is not publicly documented and is commercially gated). If Bullhorn offers a sandbox, the auth model against it is presumed identical to production: authorization-code grant. Just a different `loginInfo` cluster.

**Spec gap §3.2-A:** confirm with Bullhorn developer support whether (a) client_credentials is genuinely unsupported, or (b) it exists for specific partner-tier use cases not documented publicly. If (b), this changes the dev-loop ergonomics. Mark as **CG**.

### 3.3 — Hybrid model

Pragmatic v1.0 hybrid given §3.1 and §3.2 findings:

- **Production tenants:** authorization-code grant per §3.1. Per-tenant admin runs the browser dance during onboarding wizard Day 2 (Product Spec §5.2 OAuth + vault provisioning step). Refresh tokens persisted at `/vault/<tenant>/_secrets.env` mode 0600 with atomic-rename rotation per Spec gap §3.1-A resolution.
- **IFOS internal dev / sandbox:** authorization-code grant against IFOS-owned Bullhorn dev tenant (or against Bullhorn sandbox if §3.2-A resolves favourably). Same flow as production; the only difference is the source tenant. Tokens stored at `packages/mcp-connectors/bullhorn/.dev-tokens/` (gitignored) for IFOS dev work.
- **Strict separation:** IFOS internal dev tooling never touches production tenant refresh tokens. The renderer (per `ADR-003`) materialises tenant-scoped tokens into per-tenant `_secrets.env`; dev tooling reads from a separate gitignored path that doesn't pass through the renderer at all.

### 3.4 — Technical recommendation (Proposed)

**Recommendation:** authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement "browser dance for production"). For IFOS dev: authorization-code grant against an IFOS-owned Bullhorn dev tenant; service-account / client_credentials grant deferred (because Bullhorn doesn't document support for it per §3.2).

Three justifications:

1. **It's the only documented Bullhorn-supported production OAuth path.** Section 3.1's verified Bullhorn documentation grounds this; Section 3.2's documented absence of client_credentials closes the alternative.
2. **It composes with the §1.4 fallback architecture and §2.4 Sub-decision A recommendation.** The auth-code flow works identically against direct-API and marketplace-tier (only the `loginInfo` cluster and client_id may differ). The auth module's job is the per-tenant browser-dance kickoff and refresh-token persistence; both are path-independent.
3. **The renderer's `_secrets.env` materialisation per Spec gap §2.1-C handles the credential storage cleanly.** No new persistence layer needed; the path was already specified in `agent-bundle-renderer-design.md` §3.3.2.

**Commercial verification gates** (per §1.3 table, Bullhorn developer support row):

- Confirm authorization-code grant is the correct production path (i.e. Bullhorn doesn't have a marketplace-tier-only managed-auth path that bypasses the browser dance).
- Confirm Bullhorn sandbox availability and auth model (Spec gap §3.2-A).
- Confirm there is no per-entity-type OAuth scope granularity at the OAuth layer (Spec gap §3.1-B) — required so IFOS's Gate A enforcement model (validate.sh) is the correct safeguard.
- Confirm refresh-token rotation atomicity requirements (any Bullhorn-side timeouts that affect persistence windows).

**Status: Proposed.** Status flips to Accepted on commercial verification answers to the four questions above. Most likely outcome: confirmation of the §3.4 recommendation as stated, with one or two clarifications absorbed into the renderer's auth-module implementation.

---

## Section 4 — Sub-decision C: v1.0 endpoint surface

Fully technical. **Status: Accepted** on first pass — no commercial gating.

### 4.1 — Per-agent endpoint requirements

Drawn from master brief §8.2 lines 597-611 + Ultraplan §8.1 lines 502-570 + Product Spec §2.2 R2-R7 per-agent specs. Five rows tabled (four Bullhorn-touching + one non-touching for completeness).

| Agent | Entities Read | Entities Written | Read Cadence | Write Triggers | Error Handling | Per-tenant Scoping |
|---|---|---|---|---|---|---|
| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
| **A3 Scribe** (W-heavy; master brief §8.2 line 603; Ultraplan §8.1 line 518-526) | Candidate (resolve call-participant identity for write context); Placement (link transcript to placement if applicable); JobOrder (link to active brief if applicable) — minimal reads, only for write-context resolution | Note (call summary + tacit-note attachment; 1 Note per call); Candidate structured field updates (extraction targets per Ultraplan §8.1 line 524 — "salary expectation noted", "willing to relocate", etc.); occasionally Placement notes on placed-candidate calls | **Event-driven (webhook from Fathom/Fireflies → IFOS → Bullhorn write).** Per Ultraplan §8.1 A3 line 521: "90% of calls processed within 5 minutes of webhook." Triggered only on call-end; otherwise dormant | Fathom/Fireflies webhook arrival; IFOS parses transcript; Scribe writes within 5-min SLA | Transcript-to-structured-fields confidence ≥ 0.6 per Ultraplan §8.1 line 525 Gate A; tacit-note extraction confidence threshold separate; `ESC_PII_LEAKAGE_RISK` per master brief §8.1 Change 3 line 591 on banned-extraction patterns; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant; webhook origination URL is tenant-specific so routing is deterministic |
| **A5 Sourcing Scout** (R-only; Ultraplan §8.1 line 551) | Candidate (ATS passive matches — search by brief criteria); ClientCorporation (target-firm context); JobOrder (active brief context) | None — writes go to the IFOS-side shortlist artefact, not back to Bullhorn in v1.0 | **Request-response.** Per Product Spec §2.2 R5 + master brief §8.2 line 605: "10-15 minute turnaround on consultant ping." On-demand only — no scheduled sweep | n/a (read-only) | No candidate flagged "do not contact" per Ultraplan §8.1 line 552 Gate A; rate-limit 429 → backoff; `ESC_RATE_LIMIT_HIT` per master brief §8.1 Change 3 line 592 if LinkedIn rate-limit hit (Sourcing Scout is multi-source — Bullhorn is one input among LinkedIn/Reed/CV-Library) | Strict per-tenant |
| **A6 Concierge** (R+W; master brief §8.2 line 606; Ultraplan §8.1 line 561-568) | Candidate (lifecycle state on every event); ClientCorporation (relationship context); JobOrder (linked-brief context); Placement (lifecycle stage — week-1/month-1/month-3/month-6/month-12/month-24 nurture cadence per Product Spec §2.2 R7); Note (prior-comms history) | Note (every lifecycle-event-driven communication produces a Note linked to Candidate + Placement); Candidate state-field updates on lifecycle transitions; Placement state-field updates | **Hybrid.** Event-driven for Bullhorn webhooks where supported (per §4.2 below — likely none in v1.0 direct-tier); polling 5-minute cycle for Candidate / Placement state changes as fallback; cron-driven for time-based nurture events (week-1 check-in etc.) | ATS state-change detection + cron-driven nurture-event firing + IFOS-inbound (Triage handoff in v1.1) | Voice classifier ≥ 0.75 per Ultraplan §8.1 line 566 Gate A; correct addressee resolution; `ESC_VOICE_DRIFT` per master brief §8.1 line 586; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant. Concierge holds long-running per-tenant state (lifecycle-event-pending queue) per Primitive 1 (PTY/PM2) which carries it across restarts via Primitive 2 (71h rotation) |
| **A1 Diagnostic** (no Bullhorn) | n/a | n/a | n/a | n/a | n/a | n/a — runs against public footprint per Ultraplan §8.1 line 489 |
| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |

**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.

**Spec gap §4.1-B:** Ultraplan §8.1 A3 Scribe (line 524) names "tacit-note extraction" as the hard part with a "small taxonomy (5-10 tacit-note types)" — the taxonomy itself is unspecified. v1.0 Week 6 Scribe build defines it; out of scope for this Day-2 decision.

### 4.2 — Webhook vs polling per integration point

**Confirmed from Bullhorn public docs:** `https://bullhorn.github.io/rest-api-docs/` describes **no webhook, subscription, event-stream, or push-notification mechanism**. Operations covered: entity CRUD, query/search, file attachments, resume parsing, mass updates, entity metadata. Verified 2026-05-16.

**Implication:** Bullhorn's public-tier REST API is **pull-only**. IFOS must poll for change detection at v1.0 unless commercial verification reveals a partner-tier event-subscription mechanism. **Commercially gated: §4.2-A** — confirm with Bullhorn developer support whether webhook/event-subscription capabilities exist at marketplace/partner tier that are not documented in the public REST docs.

**v1.0 default per integration point:**

| Integration point | v1.0 mechanism | Cadence | Notes |
|---|---|---|---|
| Janitor Candidate sweep | Polling (full-table scan per sweep) | Nightly 02:00 | Initial sweep is bounded by per-tenant Candidate count; subsequent sweeps use `dateLastModified` filter to limit to changes-since-last-sweep |
| Janitor Note / ClientCorporation / JobOrder sweep | Polling | Nightly 02:00 | Same `dateLastModified` filter pattern |
| Scribe transcript-to-Note write | Push from Fathom/Fireflies → IFOS → REST write to Bullhorn | Per-call (within 5-min SLA) | The Fathom/Fireflies webhook is the trigger; Bullhorn side is REST POST |
| Sourcing Scout passive-match read | Polling (on-demand search) | Per-consultant-request | No subscription needed — read-on-demand model |
| Concierge lifecycle-state monitoring | **Polling fallback** in v1.0 (5-minute cycle) | 5-minute polling | Per Ultraplan §8.1 line 569 gotcha: "Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks." Documented v1.0 plan: polling-primary, webhook-additive when available at marketplace tier. The 5-minute cycle is the conservative v1.0 default; revisit if rate-limit budget permits faster |
| Concierge time-based nurture cadence | Cron (week-1, month-1, month-3, month-6, month-12, month-24) | Per Placement-creation anchor date | No Bullhorn webhook needed — IFOS-side cron fires; IFOS reads Bullhorn for current state then writes the comm Note back |

**v1.1+ upgrade path:** if Sub-decision A commercial verification reveals marketplace-tier event subscriptions, Concierge upgrades from 5-minute polling to webhook-primary with polling fallback. The polling cycle becomes a heartbeat-style consistency check. No agent-bundle-content changes; only `tools.yaml` MCP scope declaration and the connector's auth/subscription module.

### 4.3 — Per-tenant credential isolation

Restated from `agent-bundle-renderer-design.md` §2.1 + §3.3.2 spec gap §2.1-C resolution + §3.1 of this document:

- **On-disk per-tenant credentials:** `/vault/<tenant-slug>/_secrets.env`, mode `0600`, owner `ifos-tenant-<slug>`, group `ifos-tenants`. Filesystem isolation per Ultraplan §5.1 line 218.
- **Refresh-token persistence atomicity:** write to `_secrets.env.tmp`, rename atomically per `agent-bundle-renderer-design.md` §3.3.4 — resolves Spec gap §3.1-A of this document.
- **Access token:** in-memory only; never persisted to disk. 10-minute TTL per §3.1 does not justify disk I/O.
- **`BhRestToken`:** in-memory cache; refresh on 401 per §3.1; never persisted.
- **Per-agent token isolation:** each IFOS agent process loads only its tenant's credentials at start via the renderer-materialised `.env`. No cross-tenant token sharing — kernel-enforced via the per-tenant OS user model (Ultraplan §5.1 line 220 "agent process for tenant X runs as `ifos-tenant-{X}`").
- **Postgres `decision_log` RLS:** every Bullhorn-derived `hh_decision_*` row is tenant-scoped per ADR-002 Decision 3 (`tenant_slug` column + RLS policy per `second-brain-design.md` §2.4.2).

### 4.4 — Rate-limit budgeting

Bullhorn public docs name HTTP 429 + "wait 1 second then retry" per §2.2; specific per-second / per-minute / per-day caps **commercially gated to verification per §1.3** (Bullhorn dev support).

**Conservative v1.0 budget allocation per tenant per hour** (anchored to typical enterprise REST API patterns of 100-500 req/min ceilings; revise once Bullhorn confirms):

| Agent | Budget (req/hour per tenant) | Profile |
|---|---|---|
| Janitor (nightly sweep) | 200-400 during active sweep window (concentrated 1-2 hour burst) | Burst-tolerant; bounded by tenant Candidate-count and `dateLastModified` filter efficiency |
| Scribe (write-on-event) | 50-100 distributed | Event-rate-bounded; one call typically = 5-15 REST writes |
| Sourcing Scout (read-on-demand) | 50-200 during consultant-active windows | Search-heavy; multiple paginated reads per consultant request |
| Concierge (real-time + 5-min poll) | 100-300 distributed | Two streams: lifecycle-event-driven writes (low volume) + polling-cycle reads (continuous, bounded by entity-count) |
| **Total per tenant** | **~400-1000 req/hour ceiling (conservative)** | |

**Reserve 30% headroom** for error/retry overhead per §2.2 (429 + wait-1s retry pattern). Effective budget for first-attempt productive calls: ~280-700 req/hour/tenant.

**Spec gap §4.4-A:** confirm actual Bullhorn rate limits per tenant during commercial conversation per §1.3 table (Bullhorn dev support row). Revise this budget table when actuals land.

### 4.5 — Access-token refresh-loop architecture

**Emerged from §3.1 finding:** Bullhorn's 10-minute access token TTL is short enough that v1.0 needs an explicit refresh-loop pattern. Lazy refresh on 401 alone is insufficient for two reasons: (a) it would cause every 10-minute window's first call to take a refresh round-trip's worth of latency, breaking sub-second SLAs on Concierge real-time paths; (b) 401 detection on burst writes (Scribe's per-call sequence of 5-15 REST writes) means burst-mid-flight refresh failures lose write ordering.

**Architecture:**

- **Per-agent refresh-loop background task** starts when the agent process boots. Refreshes the access token every **8 minutes** (2-minute safety margin against the 10-minute TTL).
- **Refresh failure handling:**
  - First failure: retry once with 2-second backoff.
  - Second failure: emit `ESC_BULLHORN_AUTH` per master brief §8.1 Change 3 line 587; pause Bullhorn-touching operations; agent enters degraded mode per Ultraplan §3.5 line 110 ("drafts-only, no auto-send, scheduled retry"); founder Telegram notification.
  - Operator action: re-run authorisation if refresh-token cycle broke (per §3.1 atomic-persistence failure mode); agent picks up new tokens on next session refresh per Primitive 2.
- **Refresh-token rotation atomicity:** every successful refresh atomically writes the new refresh_token to `_secrets.env.tmp` then renames (Spec gap §3.1-A resolution per `agent-bundle-renderer-design.md` §3.3.4). The old refresh_token is unusable after the new one is generated — atomicity is mandatory.
- **`BhRestToken` cache invalidation:** when access token refreshes, the `BhRestToken` is independently maintained (it persists across access-token refreshes per Bullhorn's two-step model). On 401 from a REST call, IFOS re-runs `/login` to get a new `BhRestToken` without needing to re-OAuth.
- **State location:** refresh-loop is a goroutine-equivalent (Node `setInterval` or similar) inside the Bullhorn MCP connector process, per-tenant scoped. Multiple agents on the same tenant share the connector's token cache.

This is a real architectural decision worth its own §4 sub-section because the 10-min TTL forced the refresh-loop into the v1.0 design — it's not just an implementation detail.

---

## Section 5 — Recommended path (Status split)

Three sub-decisions, three explicit Status fields, named reduction triggers.

**Sub-decision A — Marketplace vs direct API. Status: Proposed.**

Recommendation: scaffold the Bullhorn MCP connector against direct API / Developer Program for v1.0 weeks 1-2; treat marketplace registration as a v1.1+ commercial track that the connector's auth module is designed to swap into without endpoint-surface changes (per §2.4 + §1.4 fallback architecture).

Status flips to Accepted when **all three** commercial conditions per §1.3 land:

1. Bullhorn partnerships team confirms whether marketplace is required for production tenant access (`partnerships@bullhorn.com` outreach, Sunday/Monday).
2. Cost delta between marketplace and direct at 3-tenant pilot scale clarified.
3. First design partner ATS confirmed as Bullhorn (Sunday design-partner conversation 2 per master brief §6 Day 2 line 467).

Reduction trigger for Risk #2 severity: this Status flip closes one of the two Bullhorn-auth-related gates.

**Sub-decision B — OAuth flow. Status: Proposed.**

Recommendation: authorization-code grant for production tenants (matches master brief §6 Day 2 line 466 pre-statement); authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (client_credentials grant **foreclosed** by Bullhorn OAuth docs per §3.2 — Bullhorn does not support client_credentials grant for tenant-scoped data). Refresh-loop architecture per §4.5.

Status flips to Accepted when commercial verification answers the four questions per §3.4:

1. Bullhorn dev support confirms authorization-code grant is the correct production path.
2. Sandbox / IFOS-owned dev tenant model verified.
3. Per-entity OAuth scope granularity confirmed (Spec gap §3.1-B) — required to know whether `validate.sh` is the only enforcement layer.
4. Refresh-token rotation atomicity requirements confirmed.

Reduction trigger for Risk #2 severity: this Status flip closes the second of two Bullhorn-auth gates.

**Sub-decision C — v1.0 endpoint surface. Status: Accepted.**

Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.

No commercial gating. Codex Day-7 ratification reviews the technical analysis directly.

---

## Section 6 — Consequences and integration

### 6.1 — For Week 1-2 (Bullhorn MCP connector scaffolding)

Per §2.4 + §5: connector scaffolds at `packages/mcp-connectors/bullhorn/` against direct-API auth-code flow. Auth module isolated per §1.4 fallback architecture (~200-400 lines bounded per `agent-bundle-renderer-design.md` §3.3.4). Endpoint surface from §4.1 drives the connector's exposed `tools.yaml` scopes. Refresh-loop per §4.5 ships with the connector.

Week-1 prerequisites surfaced by Day 2 that join the existing Week-1 prereq list:

- **Bullhorn client_id + client_secret obtained** via support ticket per §2.2 verified path — commercial action, founder Sunday/Monday.
- **IFOS-owned Bullhorn dev tenant provisioned** (may require partnership conversation) — commercial action, founder Sunday/Monday.
- **`_secrets.env` vault structure provisioned** per renderer §3.3.2 — already on Week-1 prereq list from ADR-003.
- **`ESC_BULLHORN_AUTH` escalation code wired** into `agents/_shared/escalation-codes.md` per master brief §8.1 Change 3 line 587 — code already named in master brief; wiring lands with `_shared/hook-helpers.sh` Week-1 prereq.

### 6.2 — For Day 4 this week (Postgres provisioning)

No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.

### 6.3 — For Day 5 this week (auto-send safety policy)

Concierge's write capability to Bullhorn (Note auto-send, status updates per §4.1) interacts with Day 5's auto-send safety policy artefact. Day 5 should reference this document's §4.1 Concierge row for the specific entities Concierge will be writing — Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI.

### 6.4 — For Week 11-13 brain build (wiki ingest)

Bullhorn entity field mapping (Candidate, JobOrder, Placement, Note, ClientCorporation) → IFOS wiki schema per `second-brain-design.md` §2.2 entity types. Out of scope for this Day-2 decision; flagged for Week 11-13 work. Concrete handoff: §4.1's per-agent read-entity list is the v1.0 minimum set the wiki ingest paths must handle.

### 6.5 — For Codex Day-7 ratification

This document joins the queue. Codex reads:

- §5 (status-split recommendations with named reduction triggers per Sub-decision)
- §1.3 (commercial-blockers table — specific contact paths)
- §7 (spec gaps consolidation)
- §6.6 (sixth atomic-correction edit, below)

Specifically Codex confirms:

- Sub-decision C Accepted status is justified by §4's technical analysis grounded in verified Bullhorn public-doc citations.
- Sub-decisions A and B Proposed status has named, measurable reduction triggers (not aspirational).
- Commercial-blockers table names specific contact paths and timelines.

### 6.6 — Atomic correction commit — sixth edit identified

§3.2 finding (Bullhorn does NOT support client_credentials grant for tenant-scoped data per public OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`) forecloses the master brief §6 Day 2 line 466 pre-statement. New sixth edit for the atomic correction commit alongside ADR-001 + ADR-002 + ADR-003 Edit C.

**Current** (master brief §6 Day 2 line 466 verbatim):

> "- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: browser dance for production, service-account for dev. Document in `docs/decisions/bullhorn-integration-path.md`"

**Proposed:**

> "- [ ] Decision: Bullhorn Marketplace vs Direct API. OAuth model: authorization-code grant for production tenants; authorization-code grant against an IFOS-owned Bullhorn dev tenant for internal dev (Bullhorn does not support `client_credentials` grant for tenant-scoped data per Bullhorn OAuth docs at `https://bullhorn.github.io/Getting-Started-with-REST`). Document in `docs/decisions/bullhorn-integration-path.md`."

Joins the atomic correction commit at end of Week 0 / early Week 1. Codex ratifies the combined commit on Day 7 per master brief §10.6.

### 6.7 — For Risk #2 (Bullhorn auth path)

**Current state after Day 2:** severity stays **High** while Sub-decisions A and B are Proposed. Status of three sub-decisions: A Proposed, B Proposed, C Accepted.

**Reduction trigger 1 (High → Medium):** Sub-decisions A and B flip to Accepted (commercial answers from Sunday/Monday conversations land + design partner ATS confirmed).

**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).

Risk register update lands with this commit.

### 6.8 — For future ADRs

This decision document explicitly defers:

- **Bullhorn MCP connector implementation details** (TypeScript module layout, request-builder pattern, error-class hierarchy) — to ADR-004 in Week 1-2 if architectural choices surface, or to the implementation PR itself if straightforward.
- **Marketplace partner programme certification** — to a v1.1+ commercial-track ADR if marketplace becomes required or commercially advantageous.
- **Webhook / event-subscription model** — deferred to v1.1+ pending Sub-decision A commercial verification (whether marketplace tier grants subscription endpoints not in public REST docs).
- **Per-entity OAuth scope model** (Spec gap §3.1-B) — deferred to Bullhorn dev support verification; result folds into connector's auth-module implementation, not a new ADR.

---

## Section 7 — Spec gaps consolidated

Four-bucket structure matching `second-brain-design.md` §5.4 and `agent-bundle-renderer-design.md` §5.4.

### Bucket 1 — Resolved inline in this design

| ID | Resolution location | Resolution |
|---|---|---|
| §3.1-A | §4.3 + §4.5 | Refresh-token persistence atomicity: write `_secrets.env.tmp`, rename atomically per `agent-bundle-renderer-design.md` §3.3.4 |
| §4.5 (architectural emergence) | §4.5 | Access-token refresh-loop: per-agent background task, 8-minute cycle, retry-once-then-`ESC_BULLHORN_AUTH` |
| Per-tenant credential isolation | §4.3 | Restated from `agent-bundle-renderer-design.md` §3.3.2 — `/vault/<tenant>/_secrets.env` mode 0600 + per-tenant OS user kernel isolation + Postgres RLS |
| Rate-limit budget allocation | §4.4 | Conservative v1.0 defaults (400-1000 req/hour/tenant total; 30% reserve); revise when Bullhorn confirms actuals |

### Bucket 2 — Master brief edits needed

| Edit | Where | What | When lands |
|---|---|---|---|
| 6th edit | Master brief §6 Day 2 line 466 | `service-account for dev` → `authorization-code grant against an IFOS-owned Bullhorn dev tenant` (per §6.6) | Joins atomic correction commit at end of Week 0 / early Week 1, alongside ADR-001 + ADR-002 + ADR-003 Edit C |

### Bucket 3 — Week 1+ prerequisites

| Prerequisite | Owner | Target |
|---|---|---|
| Bullhorn client_id + client_secret obtained via support ticket per §2.2 | Founder (commercial action) | Sunday/Monday outreach; tickets typically resolve 1-5 business days |
| IFOS-owned Bullhorn dev tenant provisioned | Founder (commercial action) | Sunday/Monday; may bundle with the same partnerships conversation |
| Bullhorn MCP connector scaffolded at `packages/mcp-connectors/bullhorn/` | Claude Code | Week 1-2 (after ADR-003 renderer impl) |
| Refresh-loop implementation per §4.5 | Claude Code | Week 1-2 (ships with connector) |
| `ESC_BULLHORN_AUTH` escalation code wired into `agents/_shared/escalation-codes.md` | Claude Code | Week 1-2 (alongside `_shared/hook-helpers.sh` Week-1 prereq from ADR-002) |
| Vault `_secrets.env` skeleton in `provision-tenant.sh` (per ADR-003 Spec gap §2.1-C) | Claude Code | Day 4 Week 0 (already scheduled) |

### Bucket 4 — Operational defaults (overridable on commercial answers)

| Default | Override trigger |
|---|---|
| §3.1-B: assume no per-entity OAuth scope granularity → `validate.sh` Gate A is the only enforcement layer | Bullhorn dev support confirms different — adjust connector auth-module to request scoped tokens |
| §3.2-A: assume `client_credentials` genuinely unsupported (not partner-tier-only) | Bullhorn dev support reveals partner-tier-only support — dev-loop ergonomics improve; production path unchanged |
| §4.2-A: assume v1.0 pull-only (no webhook coverage) per public REST docs | Sub-decision A commercial verification reveals marketplace-tier event subscriptions — Concierge upgrades to webhook-primary in v1.1+ |
| §4.4-A: conservative 400-1000 req/hour/tenant rate-limit budget | Bullhorn dev support confirms actuals — revise budget table |
| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |

End of decision document.
