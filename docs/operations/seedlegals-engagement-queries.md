# SeedLegals engagement — query bundle for D2 + D3 resolution

**Status:** Reference (operations playbook for D2 founder action)
**Date:** 2026-05-22
**Purpose:** Drop-in queries the founder pastes into SeedLegals (or equivalent UK SaaS legal platform) to resolve Founder Decisions D2 (external advisor identification) + D3 (PII retention) before first pilot LOI.

---

## §1 — Why SeedLegals

Per kill-criterion §3.4: external advisor is Week 1-2 must-fill. Per Risk #3: design partner LOI is 11 days from today (2026-06-03 trigger).

SeedLegals is the cheapest fastest path: UK SaaS templates exist; £200-500 covers pilot LOI template + standard clauses; 24-48h turnaround. Higher-stakes contracts later escalate to specialist firm (Bowers Anderson / Ashfords tech).

Alternative platforms: Pocketlaw (similar shape, slightly more enterprise-leaning), LawBite (UK-focused), Linklaters Sigma (heavier).

---

## §2 — Engagement scope (what to buy)

| Deliverable | SeedLegals product | Cost (approx) | Time |
|---|---|---|---|
| **Pilot LOI template** with IFOS-specific clauses | LOI / Heads of Terms template + custom amendments | £200-300 | 24h |
| **GDPR Art. 28 DPA template** for IFOS as data processor | Data Processing Agreement template | £150-200 | 48h |
| **PII retention clause** (resolves D3) | Custom clause within DPA | included | inline |
| **Mutual NDA** for pilot conversations pre-LOI | Mutual NDA template | £50 | 24h |
| **Operator-side TOS** for pilot tenants (basic terms) | SaaS subscription agreement (lite) | £300-500 | 72h |

**Recommended Tier 1 (pre-LOI minimum):** LOI template + DPA template + Mutual NDA = ~£500, all delivered within 72h.

**Recommended Tier 2 (post-pilot):** Full SaaS subscription agreement + customer-grade DPA — engage when first pilot converts to paid customer. Higher-stakes; consider specialist firm.

---

## §3 — Specific clauses to request

### §3.1 — PII retention clause (D3 resolution)

Paste into SeedLegals' query field OR send as a follow-up message to the platform:

> Please draft a Data Retention clause for a UK B2B SaaS DPA where:
>
> 1. The data subject's personal data (specifically: candidate names, contact details, salary information, free-text edits to AI-generated drafts) is processed for THREE purposes:
>    - **Operational review** by the tenant's consultant team (window: hours to days)
>    - **Voice quality drift detection** via aggregated metadata only (`edit_distance`, `tone_rule_matches`, `approval_resolution`)
>    - **AI model training corpus** for the SaaS vendor's voice fine-tuning pipeline (per-tenant fine-tuning, not cross-tenant)
>
> 2. Default retention for **raw text bodies** is 90 days, with bounded purge after that.
>
> 3. **Aggregated metadata** is retained indefinitely (no PII; only edit-distance integers, enum classifications, timestamps).
>
> 4. **Per-tenant override** allows tenants to extend raw-text retention to 365 days via TOS amendment, OR shorten to 30 days (regulatory minimum for our use case).
>
> 5. Right-to-erasure (GDPR Art. 17) requests purge raw text within 30 days of receipt + flag the metadata row as "subject-purged" (metadata can stay; PII is gone).
>
> Specific questions:
>   - Is 90 days the right floor under UK GDPR Art. 5(1)(e) data minimisation for this use case?
>   - Should the AI training-corpus consent be opt-in or opt-out for pilot tenants?
>   - What's the lawful basis for the AI-training retention — legitimate interests + consent in TOS, or explicit Art. 6(1)(a) consent at moment-of-edit?
>   - Does the metadata-only retention (post-purge) need GDPR Art. 4(5) pseudonymisation safeguards or is it sufficient that no PII is present?

### §3.2 — Pilot LOI specific clauses (D2 resolution)

Paste into SeedLegals' LOI template customisation:

> Please customise the LOI template for our use case with the following:
>
> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
>
> 2. **Pilot duration:** 8 weeks from LOI signing. Either party may exit with 14-day notice during pilot.
>
> 3. **Liability cap (mutual):** capped at £10,000 for pilot period; recap on full-customer conversion.
>
> 4. **Auto-send liability allocation:** SaaS vendor responsible for false-positive auto-sends (e.g., a payment reminder sent to a settled invoice); tenant responsible for content of approved sends (e.g., consultant approved a draft that contained an error).
>
> 5. **PII jurisdiction:** UK only. SaaS vendor processes data within UK + EEA only; no transfer to US or other adequacy-decision-uncovered jurisdictions. Bullhorn data centre = UK per pilot agreement.
>
> 6. **Dispute forum:** English courts; tier 1 = direct negotiation between founders; tier 2 = LCIA mediation if unresolved 30 days.
>
> 7. **Insurance:** SaaS vendor maintains £1m professional indemnity + £1m public liability minimum throughout pilot.
>
> Specific questions:
>   - Is the £10,000 cap defensible for a recruitment-data SaaS pilot in UK courts?
>   - Should the auto-send liability split be calibrated against a specific incident definition (e.g., "false-positive" needs a definition)?
>   - Does insurance need to be in place BEFORE LOI signing or BEFORE first pilot agent deployment?

### §3.3 — Mutual NDA template

Paste into SeedLegals' Mutual NDA template:

> Please tailor the Mutual NDA template for:
>
> - **Both parties:** UK companies (or UK-registered branches of foreign companies)
> - **Information to be protected:**
>   - SaaS vendor: source code, fine-tuning data, voice corpus, customer pipeline
>   - Tenant: candidate data, client relationships, internal financials, deal pipeline
> - **Permitted disclosures:** to professional advisors (lawyers, accountants, insurers); to acquirer in M&A diligence (with prior notice + executed NDA chain)
> - **Term:** 5 years post-engagement OR until information enters public domain through no breach by recipient
> - **Carve-outs:** information already known to recipient; independently developed; obtained from a third party without confidentiality obligation; required by law to disclose

---

## §4 — Engagement workflow

```
Day 0 (today): Founder logs into SeedLegals platform; creates new matter
                "IFOS pilot legal infrastructure"
Day 0+5min:    Pastes §3.1 (PII retention clause) — DPA template selected
Day 0+10min:   Pastes §3.2 (LOI clauses) — LOI template selected
Day 0+15min:   Pastes §3.3 (Mutual NDA) — NDA template selected
Day 0+20min:   Submits engagement; pays ~£500 total

Day 1 (24h):   Mutual NDA draft delivered
Day 2 (48h):   LOI template + DPA template + PII clause delivered
Day 3-5:       Founder reviews drafts; submits clarification queries via platform
Day 5-7:       Final versions delivered
Day 7+:        Templates ready for first pilot signing
```

Total wall-clock: ~1 week. Total cost: ~£500.

---

## §5 — What this resolves

| Decision | Resolution path |
|---|---|
| **D2** — External advisor identification | SeedLegals templates + delivered LOI + DPA become the "external advisor input" per kill-criterion §3.4. Founder retains right to escalate to a specialist firm for higher-stakes contracts. |
| **D3** — PII retention | SeedLegals' DPA + PII retention clause defines the retention period. Default 90 days unless their advice changes it. Implementation already pre-written (`scripts/ifos-pii-purge.sh` + v0.2-to-v0.3-pii-purge.sql); just needs deployment. |
| **R3** in `architecture-cohesion-review.md` §8 | Closes (D3-bound; resolves with D3). |
| **Risk #10** | Mitigation path complete once SeedLegals returns + cron deploys. |

---

## §6 — Post-engagement actions

When SeedLegals returns (~1 week from now):

1. **Review delivered templates** — founder reads + flags any concerns
2. **Update `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D3** with the confirmed retention period
3. **If retention period is NOT 90 days:** update default in `scripts/ifos-pii-purge.sh` + the `pii_retention_days` in `docs/runbooks/pii-purge-operational-pattern.md` §2
4. **Apply v0.2-to-v0.3-pii-purge.sql** against live VPS via `run-live-migration.sh` pattern (or direct psql one-shot)
5. **Deploy `/usr/local/bin/ifos-pii-purge.sh`** + cron entry on VPS
6. **First cron run** — verify decision_log audit row + zero rows purged (because no recent_edit data exists yet)
7. **Update RISK-REGISTER Risk #10 status** to "mitigated"
8. **Update RISK-REGISTER for the D2 advisor confirmation**

---

## §7 — Open questions to track (post-SeedLegals)

If SeedLegals raises questions Claude can't answer, surface them in a new founder briefing OR ADR-005 follow-up:

- Lawful basis for AI-training retention beyond 90-day operational window
- Whether per-tenant retention override needs notification to data subjects
- Cross-border data processing if any pilot tenant has international hiring (UK→EU candidate flows)
- Bullhorn's own DPA terms — does our customer's DPA conflict with Bullhorn's processor agreement?

---

## §8 — Cost-of-delay

If founder doesn't engage SeedLegals this week:
- Q1 LOI could land before legal templates exist → founder signs without legal cover
- Risk #10 stays at "candidate" status indefinitely
- D2 + D3 stay open in current-priorities.md (D2 explicitly flagged as kill-criterion §3.4 Week 1-2 must-fill)
- 2026-06-03 (Trigger 1) date approaches; LOI process accelerates without legal infrastructure

Cost: <£500, <1 week. Value: structural protection for the foundation of the business.

---

## §9 — Status

**Reference.** Drop-in queries ready for SeedLegals platform. Founder action: ~20 min to paste; 1 week wall-clock for delivery.

When complete: D2 + D3 resolved; Risk #10 mitigation pathway closed; ready for first pilot LOI signing.

*End of SeedLegals engagement queries.*
