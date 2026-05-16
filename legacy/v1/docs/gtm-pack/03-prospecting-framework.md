# 03 — Prospecting Framework: How to Build Your First 20

**Goal: a list of 20 UK SMEs on Breathe HR with HR/Ops leaders findable on LinkedIn, ranked by fit, with contact paths for each.**

**Time required: one focused afternoon (4–5 hours). This is the single highest-leverage 5 hours of the month. Do it properly once; it feeds outreach for 6 weeks.**

---

## The ICP (Ideal Customer Profile)

This is narrower than the Phase 5 spec's ICP because solo-founder sales economics demand tight targeting. Widen it after your first 3 customers teach you what actually fits.

### Primary ICP (must-haves)

| Attribute | Spec |
|---|---|
| Country | UK (England / Scotland / Wales / NI). Not Ireland. Not Channel Islands. |
| Employees | 20–200 headcount |
| HR system | Breathe HR (strongly preferred) or BambooHR / PeopleHR / CharlieHR (adjacent) |
| HR structure | 1 dedicated HR person OR an Ops/Admin person doing HR as part of their job |
| Industry | Professional services, tech/SaaS, agencies, healthcare (non-NHS), manufacturing |
| Revenue | £1M–£20M (rough proxy for HR volume that justifies £400/mo) |
| Buying signal | Recent HR hire, recent HR tool purchase, or LinkedIn post about being overwhelmed |

### Anti-ICP (do not pursue)

- **<20 employees** — not enough HR volume to justify £400/mo
- **>500 employees** — have a real HR tech stack, probably Workday/BambooHR/HiBob, won't consider a solo-founder product
- **NHS / public sector** — procurement cycle is 9–18 months, you'll starve before closing
- **US companies / international** — you can't service them manually across timezones
- **Recruitment agencies** — their "HR" is actually recruitment; different workflow
- **Companies where CEO is the HR lead** — CEOs don't adopt tools for their own workflow; they delegate
- **Companies <£500k revenue** — can't afford £400/mo without material pain
- **Regulated industries with heavy compliance needs (law firms, financial services)** — will need enterprise-grade compliance evidence you don't have yet

### Ideal prospect profile — the "wave hand" archetype

> Sarah Chen, People & Operations Manager at a 65-person Manchester tech consultancy on Breathe HR. Joined 18 months ago. Posts on LinkedIn occasionally about HR tools and "wearing many hats." Reports to the COO. Handles everything from onboarding to engagement surveys to answering "what's the sickness policy" twenty times a week. Has tried one or two HR tools before and has opinions about them. Would take a 30-minute call with a credible-sounding UK founder about AI for HR — mainly out of curiosity, partly because the inbox is genuinely eating her Fridays.

**If the prospect on your list doesn't broadly match this archetype, cut them.**

---

## Where to find them

### Channel 1 — LinkedIn Sales Navigator (primary, £80/mo)

**Worth subscribing for the 30-day trial even if you cancel after.** Filters you can't get on free LinkedIn:

- **Location:** United Kingdom
- **Company size:** 11–50, 51–200 (two buckets, run separately)
- **Job title:** HR Manager, People Manager, People & Culture, Head of People, HR Business Partner, People Operations, People Ops, Office Manager *(UK SMEs often have Office Managers doing HR)*, Operations Manager *(same reason)*
- **Industry:** Computer Software, Marketing & Advertising, Management Consulting, Professional Training, Staffing & Recruiting *(careful — excludes most but a few SaaS-for-recruiters fit)*, Hospital & Health Care *(filter out NHS manually)*
- **Seniority:** Entry, Associate, Mid-Senior *(filter out Director/VP for SME-sized targets)*
- **Years in current role:** 1+ years *(filters out people just starting who won't buy anything for 6 months)*

**Expect:** 2,000–5,000 results after filters. You're looking for 20 good ones. Export 100 into a sheet, qualify down to 20.

### Channel 2 — Breathe HR customer case studies (secondary, free)

Go to **breathe.hr/customers** (or whatever their case studies page is). Read 20 case studies. Each case study names the company + typically the HR contact. That's 20 pre-qualified prospects who are:
- Literally on Breathe HR (the integration is validated)
- Willing to talk publicly about their HR systems (suggests receptivity)
- UK-based (Breathe HR is UK-focused)

**This is the richest, most-overlooked prospecting source you have.** Most founders don't think to mine their integration partner's customer list.

### Channel 3 — LinkedIn posts search (tertiary, free)

LinkedIn search → Posts → last 30 days → queries:
- `"HR inbox" overwhelmed`
- `"people ops" drowning`
- `Breathe HR` (surfaces people talking about Breathe)
- `HR tools small business UK`
- `too many HR questions`

People who post about the problem are qualifying themselves. These are warm prospects.

### Channel 4 — Warm connections (tertiary but highest conversion)

List everyone you know who:
- Is a founder at a 20–200 person UK company
- Has a People/HR leader reporting to them
- Would take your call as a favour

For each, send a short DM: *"Hey, working on something in HR ops for small UK companies. Any chance I could pick your HR lead's brain for 20 minutes? I can send context in advance so it's not a waste of their time."*

**Conversion rate from warm intros: ~60%. From cold LinkedIn: ~5%. Don't skip the warm list.** Even 3–4 warm intros is a significant head start. Maddox — your network through the economics course, Jack's agency clients, and Rigby Group connections probably contains 5–10 warm paths.

### Channel 5 — Industry groups / communities (free, slow-burn)

Lurk for a week, then contribute, then reach out. Useful:
- **CIPD** members (Chartered Institute of Personnel and Development) — UK HR professional body, LinkedIn groups active
- **People Collective** (Slack community, 20k+ UK/EU people ops folks)
- **HR Grapevine** (UK HR news site, has a community layer)

**Not useful in month 1** (too slow) but good to seed for month 3+.

---

## The qualification test — apply to every prospect

For each name on your long list, answer these five questions. Only prospects with 4+ yeses go on the final 20.

1. **Is the company 20–200 employees?** (LinkedIn says so)
2. **Is there a named HR/People/Ops person I can identify?** (LinkedIn profile visible, title matches)
3. **Is the HR person findable for DM?** (2nd-degree connection OR Sales Nav InMail works OR their email is inferable)
4. **Is the company plausibly on Breathe HR or similar?** (tech stack tools like BuiltWith/Clearbit can tell you; Breathe HR case studies confirm; LinkedIn "Tools we use" posts sometimes; otherwise, guess from company size + UK + modern feel)
5. **Does the company look alive?** (recent LinkedIn posts, recent hires, website looks 2024+, Glassdoor reviews recent)

**Bin prospects with <4 yeses.** It feels like wasted research — it isn't. A list of 20 good prospects beats a list of 50 mediocre ones for solo-founder outreach.

---

## Building the tracker

Use the CSV template (`03-prospect-tracker-template.csv`). Import into Google Sheets, Airtable, or Notion — whichever you'll actually check daily. My vote: **Google Sheets**. Frictionless, sharable with Jack, works on phone.

Columns (already in the CSV):

| Column | What to put | Example |
|---|---|---|
| `company` | Company name | Northcoders Ltd |
| `employees` | Headcount from LinkedIn | 45 |
| `industry` | LinkedIn industry | Computer Software |
| `location` | UK city/region | Manchester |
| `hr_system_guess` | What HR system they're likely on | Breathe HR (confirmed from case study) |
| `contact_name` | Target person's name | Sarah Chen |
| `contact_title` | Their job title | People & Operations Lead |
| `contact_linkedin` | URL to LinkedIn profile | linkedin.com/in/... |
| `contact_email` | Inferred email if possible | sarah@northcoders.com |
| `warmth` | cold / warm (via warm intro) / 1st-degree connection | cold |
| `fit_score` | 1-5, your gut feel | 4 |
| `outreach_status` | not_started / connection_sent / connected_no_msg / msg_sent / replied / booked / closed_won / closed_lost | not_started |
| `last_action_date` | Date of last thing you did | 2026-05-01 |
| `next_action_date` | When to do the next thing | 2026-05-04 |
| `notes` | Any context, personalisation hooks, reasons for/against | Posted about HR tool evaluation 2 weeks ago |

### Pro tips on the tracker

- **Sort by `fit_score` DESC** when choosing who to message today. Always message best prospects first — your outreach energy is highest in the first 30 minutes.
- **Use `next_action_date` religiously.** Outreach fails because of followup neglect, not because of weak first messages. Set `next_action_date` for every prospect after every action.
- **The `notes` column is the most valuable column.** One personalisation hook per prospect is the difference between 5% and 15% reply rates. Examples of hooks:
  - "Recently posted about going through HR tool evaluation"
  - "Company just hit £5M Series A — likely scaling HR now"
  - "Posted frustration about answering holiday questions"
  - "Promoted to head of people 3 months ago — new person in seat often evaluates new tools"

---

## How to find someone's email (legally, ethically)

Cold email is higher-friction than LinkedIn but higher-conversion once sent. Worth doing in parallel.

### Email finding tools (pick one, free tier fine)
- **Hunter.io** — free tier: 25 searches/month. Gives confidence score.
- **Apollo.io** — free tier: 50 credits/month. Also has phone numbers (don't call).
- **Anymail Finder** — free tier: 100 searches/month

### When tools fail, infer by pattern
UK SMEs most commonly use:
- `firstname@company.com` (smaller companies)
- `firstname.lastname@company.com` (more formal companies)
- `flastname@company.com` (rarer, usually US-influenced companies)

Test with a single non-spammy email. If it bounces, try the next pattern.

### Validate before sending
Use **NeverBounce** or **EmailListVerify** to check an email address is real and active before sending. Bouncing an email hurts your sender reputation for weeks.

### What's legal under UK GDPR
Cold B2B email to a named individual at a business address for a genuinely relevant business purpose is **permitted** under the UK GDPR "legitimate interest" basis, provided:
- You name yourself and your company clearly
- You explain why you're contacting them specifically
- You offer an opt-out in every message (*"Let me know if you'd prefer I don't follow up"*)
- You don't send to personal email addresses (gmail.com, hotmail.com, etc.)

This is why you target `sarah@company.com`, not `sarah.chen@gmail.com`.

---

## Example — one fully-worked prospect

*This is an illustrative example. The company is fictional; use it as a shape.*

### Acme Consulting Ltd

- **company:** Acme Consulting Ltd
- **employees:** 58
- **industry:** Management Consulting
- **location:** Bristol
- **hr_system_guess:** Breathe HR (featured in a Breathe case study from 2024)
- **contact_name:** James Patel
- **contact_title:** People & Culture Lead
- **contact_linkedin:** linkedin.com/in/jamespatel-acme
- **contact_email:** james@acmeconsulting.co.uk (Hunter.io confidence 85%)
- **warmth:** cold (no 1st-degree overlap)
- **fit_score:** 5 (ideal size, on Breathe HR confirmed, named person, active on LinkedIn, company healthy)
- **outreach_status:** not_started
- **last_action_date:** —
- **next_action_date:** 2026-05-01 (today)
- **notes:** Posted 2 weeks ago about "trying to work out if AI has a real place in HR or if it's all hype." Perfect hook for outreach message. Featured in Breathe HR 2024 case study discussing their onboarding process. Promoted from HR Advisor to People & Culture Lead in Jan — new seat, likely evaluating.

**On this prospect you'd:**
- Day 1: Send LinkedIn connection request using template A (referencing his "AI in HR" post)
- Day 2–5: If accepts connection, send template B with Loom link
- Day 7: If no reply, follow up with template C
- Day 14: If still no reply, follow up with template D
- Day 25: Break-up message, template E

Realistic outcome on a 5-fit prospect like this: ~30% book a call. So 20 prospects of average 3–4 fit = ~3 bookings. Volume matters.

---

## The week 1 targets

By end of your prospecting session:

- [ ] **20 prospects** in the tracker, all scored 3+
- [ ] **All 20 have a `contact_linkedin` URL**
- [ ] **At least 12 have an inferred email**
- [ ] **Top 5 have personalisation hooks written in notes**
- [ ] **Tracker backed up to Google Sheets / Airtable / Notion, accessible on phone**
- [ ] **Warm-intro list: 3–5 prospects from your personal network identified**

Once you have this, you're ready for outreach (artifact 04).

---

## The realistic expected outcome

20 prospects, messaged consistently over 3 weeks:

| Stage | Count | Rate |
|---|---|---|
| LinkedIn connection requests sent | 20 | 100% |
| Connections accepted | 12 | 60% |
| Replies to post-connection message | 4 | 20% of accepts |
| Discovery calls booked | 2–3 | ~15% of accepts |
| Second calls | 1–2 | 50% of first calls |
| Paying customers from this batch | 0–1 | 30–50% of second calls |

**Plan for: 0 customers from batch 1, 1 customer from batch 2 (weeks 5–8), 1 more from batch 3 (weeks 9–12).**

If batch 1 produces a customer: you got lucky, or your positioning is stronger than average. Don't get cocky; keep sending.

If batch 1 produces 0 customers but 5 informative conversations: you're on track. Conversations compound into referrals and eventual closes over the next 90 days.

**If batch 1 produces 0 conversations:** something is off. Likely suspects: positioning too abstract, demo video too long, profile doesn't build trust. Regroup.
