# 02b — Landing Page: Notes, Deployment, Upgrade Path

**The `02-landing-page-hero.html` file is a complete, shippable landing page. Single HTML file, Tailwind via CDN, no build step required. Deploy it today.**

---

## Deploy it in 15 minutes

### Option 1 — Cloudflare Pages (recommended, free, fast)

1. Create a GitHub repo called `intelforce-marketing`
2. Drop `02-landing-page-hero.html` into the repo renamed `index.html`
3. Go to Cloudflare Pages → Create project → Connect to GitHub → Select repo
4. Framework preset: **None**. Build command: *(leave blank)*. Build output directory: `/`
5. Deploy. You get a `*.pages.dev` URL in ~60 seconds.
6. Add custom domain: Cloudflare Pages → Custom domains → Add `intelforce.ai`
7. Cloudflare auto-provisions SSL. Done.

**Total time: 15 minutes. Total cost: £0.**

### Option 2 — Vercel (same time, same free tier)

Same workflow as Cloudflare Pages but via Vercel's GitHub integration. Use if you prefer Vercel's analytics dashboard.

### Option 3 — Just Netlify drop

1. Go to app.netlify.com → Sites → "Drag and drop your site output folder here"
2. Drop the HTML file
3. You get a `*.netlify.app` URL
4. Add custom domain in Netlify dashboard

**Only use this if setting up GitHub feels like friction today. You'll want GitHub anyway later.**

---

## Before deploying, replace these placeholders

In the HTML file, find and replace:

| Placeholder | Replace with |
|---|---|
| `https://cal.com/intelforce/intro` | Your actual Cal.com booking link (appears 3 times) |
| `REPLACE_WITH_LOOM_VIDEO_ID` | The Loom video ID from the URL (e.g. `abc123def456`) |
| `hello@intelforce.ai` | Your actual contact email — set up the Gmail/Workspace inbox first |

### Before you launch
- [ ] Cal.com account set up with a **30-minute** event type called "Intel Force OS intro"
- [ ] Cal.com event description: *"30 mins. We'll look at your HR inbox together and see if Intel Force OS is a fit. No pitch deck."*
- [ ] Cal.com availability: UK business hours, max 3 slots/day (scarcity is legitimate here — you're solo)
- [ ] Loom demo recorded and unlisted-public (from artifact 01)
- [ ] Email `hello@intelforce.ai` active and monitored (Google Workspace, £6/user/mo, 15 min setup)
- [ ] `/privacy` and `/terms` pages exist (even as stubs saying "legal pack coming soon, contact hello@ for questions")

---

## Why the page is written the way it is

### H1: "Your HR inbox, handled."
Three words plus one. Specific (HR inbox, not "your team"), outcome-oriented ("handled," not "powered by AI"). The line reads like something the prospect wishes they could say to a colleague.

Rejected alternatives:
- ~~"AI for your HR team"~~ — generic, indistinguishable
- ~~"The smartest HR assistant ever built"~~ — superlative, doesn't pass the smell test
- ~~"HR, automated"~~ — spooky for HR leaders; automation is what they fear, not what they want

### Subhead
States what it does (*reads, drafts, flags*) and who it's for (*UK SMEs on Breathe HR*). Named platform constraint — "on Breathe HR" — is counterintuitively good: it excludes non-ICP prospects (saves your time) and signals credibility to ICP prospects ("oh, they know our stack").

### Primary CTA: "Book a 30-minute call"
Not "Get started" (too SaaS-generic). Not "Try free" (you have no self-serve). Not "Request demo" (bureaucratic). "Book a 30-minute call" is specific and honest: the action the prospect takes next.

### Microcopy under CTAs
*"UK-based · GDPR-compliant · Built on Claude · Nothing sends without you"*

These are the four objections an HR leader will have in the first 5 seconds:
- **"Is this some US startup that'll disappear?"** → UK-based
- **"Is this GDPR-safe?"** → GDPR-compliant
- **"Is this OpenAI junk that hallucinates?"** → Built on Claude (you can argue this is the most recognised premium AI brand among B2B buyers)
- **"Will it send something stupid to my employees?"** → Nothing sends without you

Four phrases, three seconds, most objections pre-handled.

### "Founding customers — 10 places" badge
Scarcity is legitimate (you are solo; you can only onboard ~10 customers manually before the service layer breaks). It creates urgency without being fake — you're not inventing a timer. Remove the badge once you have 7 customers.

### Three-card "How it works"
01-Reads, 02-Drafts, 03-Flags — middle card is highlighted as "core." This subtly teaches the prospect what to remember: **the draft-but-don't-send principle is the thing**, not the reading or flagging. On a call, you want the prospect to say "oh, the thing that drafts everything but doesn't send, right?" — not "the AI HR bot." The design does teaching work for you.

### Final CTA section
Repeats the offer with softer positioning. *"If it's not a fit, you've seen the fastest-improving AI in production — worthwhile either way"* removes the fear of wasting their time. It's essentially saying: this isn't a hard sell. That framing converts better than any superlative.

### Dark mode default
Most B2B SaaS landing pages are white. Dark-mode-default signals technical sophistication and product-led (not marketing-led) identity. Pairs with the Phase 5 brand spec. Also: your ICP (HR ops leaders, 20–200 person UK SMEs) are mostly on laptops in the evening checking Slack — dark mode feels more friendly to that moment.

### What's deliberately missing from v1
- **No testimonials.** You don't have any. Fake or vague testimonials ("Incredible product!" — anon) reduce trust below zero.
- **No logos carousel.** Same reason. Don't put Apple logos on a page if Apple doesn't use your product.
- **No pricing.** Pricing on the landing page pre-customer is premature anchoring and filters out prospects who'd pay more than you're guessing at. Hold pricing for the call.
- **No feature list.** Features belong on a product page built later. Hero + demo + three-card "how" is enough for the founder-led sales phase.
- **No chatbot widget.** Nothing more ironic than a clunky chatbot on the page of an AI company. Inbox → reply within 24 hours is a better experience.

---

## Upgrade path (post-first-customer)

When you have 2–3 paying customers, the landing page needs to evolve. Plan for these upgrades:

### v1.1 — Add real proof (week 2 after first customer)
- Testimonial quote from first customer (with name + company, short)
- "Customers include" bar with 1–3 logos (permission-granted)

### v1.2 — Add case study (month 2 after first customer)
- Case study page built from the Phase 5 case study playbook
- Link from landing page: *"How [Customer] saves 5 hours/week on HR admin"*

### v2.0 — Proper Next.js marketing site (month 3)
- Migrate from static HTML to `apps/marketing/` Next.js app per Phase 5 landing page spec
- Adds: pricing page, about page, blog, proper legal pages, individual case studies, customer quotes section
- When to do this: when the static HTML file becomes genuinely limiting (you need a blog, you need multiple case study pages, you need A/B testing). Not before.

### v2.1 — Paid traffic (month 4+)
- Once organic inbound from LinkedIn is saturated, Google Ads for "Breathe HR integration," "HR chatbot UK SME," etc.
- LinkedIn ads to HR leaders at 20–200 employee UK companies
- Before paid: you need a landing page that converts >2% of visitors to calls. Measure first.

---

## SEO — what to care about, what to ignore

### Care about
- Title tag is set correctly (it is)
- Meta description is set correctly (it is)
- Open Graph tags for LinkedIn/Twitter sharing (they are)
- Mobile responsive (it is — Tailwind handles this)
- Fast loading: Tailwind CDN + one web font = under 1s on 4G (it is)

### Don't care about (yet)
- Keyword research
- Backlinks
- Blog-driven SEO content marketing
- Schema.org structured data

**SEO is a 6-month effort. Outreach is a 6-hour effort that produces calls next week. Do outreach first.**

---

## Analytics

Add **one** analytics script before launch. Pick one:

### Plausible (recommended — £9/mo, cookieless, GDPR-native)
Insert before `</head>`:
```html
<script defer data-domain="intelforce.ai" src="https://plausible.io/js/script.js"></script>
```

### Fathom (alternative — £14/mo, similar profile)
Insert before `</head>`:
```html
<script src="https://cdn.usefathom.com/script.js" data-site="YOUR_SITE_ID" defer></script>
```

### What to track in month 1
- Daily uniques (target: 5-15/day from LinkedIn outreach)
- Cal.com booking conversion rate (target: >3% of visitors)
- Demo video play rate (target: >30% of visitors)

Don't add Google Analytics. GA4 is a dark pattern that makes prospects mistrust your page and requires cookie consent. Plausible/Fathom don't, because they're cookieless.

---

## Legal minimum

Before the page is live with a public domain:

- [ ] Privacy policy page (`/privacy`) — can be a stub for 72 hours while solicitor finalises, but must exist
- [ ] Terms of use page (`/terms`) — same
- [ ] Company address in footer (Intel Force Ltd registered address — legally required in UK)
- [ ] VAT number in footer if VAT-registered

Use the Phase 5 Privacy & Terms spec as the starting point. A stub saying *"Our privacy policy is being finalised by our solicitor and will be posted here by [date]. In the meantime, contact hello@intelforce.ai for any data-protection questions."* is defensible for 2–3 weeks. Longer than that and it starts to look sus.

---

## Once deployed

- [ ] Open in 5 browsers: Chrome, Safari, Firefox, Chrome-mobile, Safari-mobile. Everything renders correctly?
- [ ] Cal.com link works end-to-end (book a test call as yourself)
- [ ] Loom video plays embedded
- [ ] Lighthouse score in Chrome DevTools: >90 on Performance, Accessibility, SEO
- [ ] Send the URL to Jack for a design review
- [ ] Send to one HR leader friend (you must know at least one, even informally) for a gut check
- [ ] Share to your LinkedIn profile as the website URL

And then — **stop editing**. Iterate with real traffic data, not more thinking.
