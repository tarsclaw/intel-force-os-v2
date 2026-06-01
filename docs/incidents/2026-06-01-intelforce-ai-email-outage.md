# Incident: intelforce.ai email outage (DNS / nameserver change)

**Date:** 2026-06-01
**Status:** Fix applied, propagating, verification pending
**Severity:** High — all inbound email to @intelforce.ai down ~8 days

---

## Summary (one line)
Changing the domain's nameservers to Vercel to put the website live moved DNS authority away from GoDaddy; the new Vercel zone had the website records but **not** the Microsoft 365 mail records, so all inbound email to @intelforce.ai silently stopped.

## Symptom
- No emails received in the Outlook (M365) inbox since **2026-05-24**.
- Mailbox itself works (login OK, not deleted) — only **incoming delivery** broke.
- Mail sent to @intelforce.ai during the outage **bounced back to senders** (no MX = undeliverable), so those messages are lost, not queued.

## Environment / setup
- **Domain:** intelforce.ai
- **Registrar:** GoDaddy
- **Nameservers (set at GoDaddy):** `ns1.vercel-dns.com`, `ns2.vercel-dns.com` (custom)
- **DNS zone host:** Vercel — under account **madsrigby@outlook.com** (user `madsrigby-1086`, team id `intelforce`)
- **Email:** GoDaddy-resold **Microsoft 365 / Outlook**
  - Mailboxes: `maddox@intelforce.ai` (Email Plus, admin), `jack@intelforce.ai` (Email Essentials, admin)
  - Managed via GoDaddy **Email & Office Dashboard**
- **Website:** Vercel project `intelforce-os-web`

## Root cause
On ~2026-05-24 the GoDaddy nameservers were switched to Vercel's. This handed **all** DNS control to Vercel. Vercel auto-created the website records (ALIAS → vercel-dns) but, by design, does **not** carry over mail records — so the M365 MX/autodiscover/SPF records were absent from the new zone. With no MX record, inbound mail had nowhere to route and bounced.

Note: the DNS zone lives under the `madsrigby@outlook.com` Vercel account, but `vercel domains ls` showed 0 domains at the CLI scope, causing earlier "no permission" confusion. The zone was reachable via the **team-level** web UI: `vercel.com/intelforce/~/domains/intelforce.ai`.

## Fix applied (2026-06-01 ~11:50)
Added three records to the Vercel DNS zone for intelforce.ai:

| Name | Type | Value | TTL | Priority |
|------|------|-------|-----|----------|
| `@` (blank) | MX | `intelforce-ai.mail.protection.outlook.com` | 60 | 0 |
| `autodiscover` | CNAME | `autodiscover.outlook.com` | 60 | — |
| `@` (blank) | TXT | `v=spf1 include:spf.protection.outlook.com -all` | 60 | — |

**Website records left untouched** (these keep the site live):
- ALIAS `*` → `cname.vercel-dns-017.com`
- ALIAS `@` → `f072c0ec90b3555f.vercel-dns-017.com`
- CAA records → `pki.goog`, `sectigo.com`, `letsencrypt.org`

Only one `v=spf1` TXT record present (no SPF conflict).

## Open TODOs / verification
1. **Confirm MX priority = 0** (verify in Vercel DNS UI).
2. **Verify propagation:** mxtoolbox.com → MX Lookup on `intelforce.ai` should return `intelforce-ai.mail.protection.outlook.com`.
3. **Send a test email** from an external account to `maddox@intelforce.ai`; confirm receipt.
4. **Confirm exact MX hostname** against GoDaddy Email & Office Dashboard → Manage → "Set Mail Destination" (standard M365 pattern used; should match).
5. **Optional (outbound deliverability):** add DKIM (selector1/selector2 CNAMEs) + a DMARC TXT record. Pull exact DKIM values from the M365 admin / GoDaddy dashboard.
6. **Damage control:** every inbound email 2026-05-24 → 2026-06-01 bounced. Proactively re-contact any time-sensitive senders from a working address. Known affected: Bullhorn partnership reply (form re-submitted; see `docs/operations/bullhorn-outreach-emails.md`).
7. **Low-priority security check:** Upwork "unknown device" / "password reset" alerts dated 2026-05-23 were noted; root cause turned out to be the DNS change, not a breach, but worth a glance at M365 sign-in activity + enabling 2FA to be safe.

## Lesson / guardrail
When changing a domain's nameservers, the new DNS host's zone starts empty of mail config. **Migrate ALL existing DNS records (MX, autodiscover CNAME, SPF/DKIM/DMARC TXT) to the new host before or immediately after the cutover** — not just the website's A/ALIAS/CNAME records. Back up the old zone first.
