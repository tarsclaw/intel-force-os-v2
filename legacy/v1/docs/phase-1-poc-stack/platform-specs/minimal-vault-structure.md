# Minimal Vault Structure
**The starting directory layout and seed content every new tenant vault ships with. Provisioning System clones this as the initial commit on the tenant's GitHub vault repo.**

> **Audience:** the engineer implementing the vault-seeding step of the Provisioning System (CC4). Also useful as reference for anyone debugging a new-tenant vault.
>
> **Status:** v1.0. Seeds 10 agents worth of scaffolding + brand + SOPs + clients skeleton.

---

## 1. Purpose

When a new tenant signs up and the Configuration Wizard finishes collecting their setup, the Provisioning System creates their private vault repo at `github.com/intelforce-vaults/{client_slug}` and pushes this skeleton as the initial commit. The vault is then cloned into `/tenant/vault/` inside their container on boot.

The goal of the minimal vault is: **agents can run immediately, with sensible defaults, even before the client has added any of their own content.** As the client (or the Client Onboarder agent) adds material, the vault fills out organically.

---

## 2. Full directory tree

```
vault/
├── .obsidian/                      # Obsidian app config
│   ├── app.json
│   ├── appearance.json
│   ├── graph.json
│   ├── workspace.json
│   ├── community-plugins.json      # Empty by default; client can add
│   └── themes/                     # Empty
│
├── .obsidian-templates/            # Obsidian core plugin "Templates" folder
│   ├── daily-note.md
│   ├── meeting-note.md
│   ├── proposal-frontmatter.md
│   └── escalation-frontmatter.md
│
├── CLAUDE.md                       # The brain stem — ALWAYS loaded first
│
├── brand/
│   ├── voice-profile.md            # SEED with placeholders + onboarding prompts
│   ├── pricing.md                  # SEED with placeholders; Wizard fills this
│   ├── service-catalogue.md        # SEED with template; Wizard fills this
│   ├── positioning.md              # Empty template
│   ├── case-studies/
│   │   └── _template.md
│   └── style-guide.md              # Empty template
│
├── clients/                        # Per-prospect & per-client folders
│   └── _template/                  # Template folder, copied per new prospect
│       ├── 00-context.md
│       ├── calls/
│       ├── proposals/
│       ├── contracts/
│       ├── delivery/
│       └── notes/
│
├── content/                        # Marketing content
│   ├── long-form/
│   ├── social/
│   └── email/
│
├── sops/                           # Standard operating procedures
│   ├── _index.md
│   └── README.md                   # How SOPs work in IntelForce vaults
│
├── daily/                          # Librarian generates one note per day
│   └── README.md                   # What this folder is for
│
├── reports/                        # Reporting Engine writes here
│   └── README.md
│
├── archive/                        # Superseded material — still searchable
│   └── README.md
│
└── _meta/                          # IntelForce-system metadata
    ├── agent-outputs.md            # Rolling log of agent activity summaries
    ├── retrieval-index.md          # Notes on what's indexed in pgvector
    └── schema-version.md           # So we can migrate old vaults later
```

---

## 3. Seed file contents

Below are the contents of the seed files that ship non-empty. Everything else is an empty `.md` with just a heading so Obsidian shows it in the file tree.

### 3.1 `CLAUDE.md` — the brain stem

```markdown
# {{client.name}} — Context Root

This file is loaded at the start of every Claude Code session. It is the
single most important file in this vault. Keep it short. Keep it current.

## Who we are

{{client.name}} — {{client.industry_short}}.
Primary contact: {{sales_lead.name}} ({{sales_lead.email}}).

{{one_paragraph_about_the_business}}

## How we write

See `/brand/voice-profile.md` for the full voice profile.
Key rules at-a-glance:
- Voice: {{voice_headline}}
- Banned phrases: see `/brand/voice-profile.md` §5
- Signature block: see `/brand/voice-profile.md` §6

## How we price

See `/brand/pricing.md` for the pricing framework.
Minimum engagement: {{pricing.minimum_engagement_value}}.
Deals ≥ {{pricing.human_drafting_threshold}} escalate to a human.

## Who does what

Agents available in this vault:
- **Proposal Builder** — drafts proposals from Fathom calls
- **Lead Hunter** — compiles prospect lists
- **Follow-Up Pilot** — unconverted enquiry nurture
- **Content Creator** — long-form pieces in our voice
- **Repurposer** — atomises long-form into social/email
- **Caption Writer** — short-form social captions
- **Client Onboarder** — kickoff collateral + welcome sequences
- **Reporting Engine** — monthly client reports
- **SOP Writer** — writes + maintains SOPs
- **Librarian** — tidies the vault nightly

## Current priorities

Auto-updated nightly by the Librarian. Editable by humans any time.

- {{current_priority_1}}
- {{current_priority_2}}
- {{current_priority_3}}

## What not to do

- Do NOT invent services that aren't in `/brand/service-catalogue.md`.
- Do NOT invent metrics, statistics, or case study outcomes.
- Do NOT send anything to a client without human review — everything drafts, nothing sends.
- Do NOT write in a voice other than the one in `/brand/voice-profile.md` §2.

## Escalation

When in doubt, escalate. Write to `/outbox/escalations/` and notify {{sales_lead.slack_handle}} in `{{slack.escalations_channel}}`.

---

*Last updated by: {{last_editor}} on {{last_updated_iso}}*
*Schema version: 1.0*
```

### 3.2 `brand/voice-profile.md` — the voice definition

```markdown
# Voice Profile — {{client.name}}

> **This file is the single source of truth for how {{client.name}} writes.** Every agent reads this. The Voice Profile is extracted during onboarding from 20–50 pieces of existing client writing. It is updated continuously by the Librarian as new writing is observed.
>
> **Completeness status:** {{voice_profile_completeness}}.

---

## 1. One-line voice description

{{one_line_voice_description}}

*(Placeholder. Example for the onboarding task: "Warm, direct, slightly Northern English. Uses short sentences. Prefers concrete examples to abstractions.")*

## 2. Tone

- **Formality level:** {{formality_level}} *(e.g. "semi-formal — uses first names but never casual slang")*
- **Humour:** {{humour_style}} *(e.g. "dry asides, never jokes out loud")*
- **Emotion:** {{emotion_register}} *(e.g. "understated — 'this is a big deal' not '🚀 HUGE news'")*
- **Pace:** {{pace}} *(e.g. "quick — short sentences, active verbs, minimal nesting")*

## 3. Vocabulary preferences

**Words they use a lot:**
- [List populated during onboarding]

**Words they avoid:**
- [List populated during onboarding]

**Words they use in a non-standard way:**
- [e.g. "partner" (never client), "session" (never meeting)]

## 4. Sentence-level patterns

- Preferred sentence length: {{sentence_length_pref}}
- Uses semicolons? {{semicolon_usage}}
- Uses bullet points in prose? {{bullets_in_prose}}
- Uses em dashes? {{em_dash_usage}}
- Contractions? {{contractions}}
- Rhetorical questions? {{rhetorical_q_usage}}

## 5. Banned phrases (UNIVERSAL AI-TELL bans + client-specific bans)

### Universal bans (enforced by validate.sh on every agent)
- "In today's fast-paced world"
- "In the ever-evolving landscape of..."
- "cutting-edge solution"
- "revolutionise your..."
- "game-changing"
- "synergise / synergies / synergistic"
- "leverage our..."
- "best-in-class"
- "state-of-the-art"
- "Let's dive in"
- "It's worth noting that"
- "We are excited to..."
- "Thank you for the opportunity to..."
- Any phrase starting with "Unleash the power of..."

### Client-specific bans
{{client_specific_banned_phrases}}

*(Populated during onboarding. Examples from real clients: one agency bans the word "solution" entirely. One consultancy bans "we" in favour of always using the principal's first name. One coaching firm bans exclamation marks.)*

## 6. Default signature block

```
{{sales_lead.signature_block}}
```

## 7. Example paragraphs (anchors for voice match)

Three verified-in-voice paragraphs from past {{client.name}} writing. Agents reference these when drafting. These are read-only; new examples are appended by the Librarian as new verified-in-voice pieces land in the vault.

### Example 1 — [Source: {{source}}]
> {{example_paragraph_1}}

### Example 2 — [Source: {{source}}]
> {{example_paragraph_2}}

### Example 3 — [Source: {{source}}]
> {{example_paragraph_3}}

---

## 8. Metadata

- **Completeness:** {{voice_profile_completeness}}
- **Last updated:** {{last_updated}}
- **Last verified against live writing:** {{last_verification}}
- **Updated by:** {{last_editor}}
```

### 3.3 `brand/pricing.md` — the pricing framework

```markdown
# Pricing Framework — {{client.name}}

> **Every proposal sourced from this file.** Do not invent prices not derivable here. If a proposed scope doesn't map to this framework, that's an escalation — not a fudge.

---

## 1. Engagement boundaries

- **Minimum engagement value:** {{minimum_engagement_value}} *(deals below this escalate as `BUDGET_BELOW_MINIMUM`)*
- **Human-drafting threshold:** {{human_drafting_threshold}} *(deals at or above this escalate as `HIGH_VALUE_HUMAN_DRAFT`; partners draft, agents don't)*
- **Currency:** {{client.currency}}
- **VAT treatment:** {{client.vat_treatment}}

## 2. Service tiers

### {{tier_1_name}}
- **Monthly:** £{{tier_1_monthly}}/month
- **Setup:** £{{tier_1_setup}} one-off
- **Includes:** {{tier_1_includes}}
- **Typical client shape:** {{tier_1_client_shape}}

### {{tier_2_name}}  *(most common — recommend by default)*
- **Monthly:** £{{tier_2_monthly}}/month
- **Setup:** £{{tier_2_setup}} one-off
- **Includes:** {{tier_2_includes}}
- **Typical client shape:** {{tier_2_client_shape}}

### {{tier_3_name}}
- **Monthly:** £{{tier_3_monthly}}/month
- **Setup:** £{{tier_3_setup}} one-off
- **Includes:** {{tier_3_includes}}
- **Typical client shape:** {{tier_3_client_shape}}

## 3. Add-ons (non-tier)

Line items that can be added on top of any tier:

| Add-on | Price | Notes |
|---|---|---|
| Ad management (paid media) | £{{ad_mgmt_price}}/month + min £1,000 spend | Separate from ad spend itself |
| SEO programme | £{{seo_price}}/month | Includes 4 pieces/month + technical audit |
| Website build | £{{web_build_price}} one-off | Excludes hosting |
| Conference/event content | £{{event_content_price}} per event | 3 deliverables |

## 4. Payment structure

- **Setup fees:** 50% on signature, 50% on kickoff call. Non-refundable once kickoff completes.
- **Monthly retainers:** Billed on 1st of month, in advance, via Stripe or bank transfer.
- **Minimum term:** {{minimum_term}} (default: 3 months).
- **Notice period:** {{notice_period}} (default: 30 days).

## 5. Discounts

- **6-month prepay:** {{six_month_discount}}% *(default: 5%)*
- **12-month prepay:** {{twelve_month_discount}}% *(default: 10%)*
- **Founding member (first 5 clients):** -15% on monthly for 12 months, locked

Do not offer discounts outside this list without human approval.

## 6. Edge cases

- **Non-profit rate:** Case-by-case; escalate.
- **Multi-entity client:** Each entity counts as a separate tenant; discount 10% on second and each subsequent entity.
- **White-label (agency reselling to their clients):** See `/brand/agency-partner-pricing.md` (Enterprise-tier material).
```

### 3.4 `brand/service-catalogue.md`

```markdown
# Service Catalogue — {{client.name}}

> **The list of things {{client.name}} actually sells.** If a prospect asks for something not in this catalogue, that's an escalation (`OUT_OF_STANDARD_SCOPE`). Do not extend. Do not invent combinations.

---

## Services

### 1. {{service_1_name}}
- **Description:** {{service_1_desc}}
- **Tier availability:** {{service_1_tier_availability}}
- **Typical deliverable cadence:** {{service_1_cadence}}
- **Measurable outcomes:** {{service_1_outcomes}}

### 2. {{service_2_name}}
...

### 3. {{service_3_name}}
...

*(Wizard collects 3–10 services depending on client's breadth.)*

---

## Explicitly NOT offered

The following are NOT services {{client.name}} provides. If a prospect asks, that's an escalation — refer them out.

- {{not_offered_1}}
- {{not_offered_2}}
...
```

### 3.5 `clients/_template/00-context.md`

```markdown
# {{prospect.company}} — Context

> **This file is the per-prospect CLAUDE.md.** When agents work on this prospect, this is loaded alongside the root CLAUDE.md. Keep it current.

## Basics

- **Company:** {{prospect.company}}
- **Domain:** {{prospect.domain}}
- **Industry:** {{prospect.industry}}
- **Size:** {{prospect.size}}
- **Primary contact:** {{prospect.primary_contact_name}} ({{prospect.primary_contact_role}})
- **First contact date:** {{first_contact_date}}
- **Source:** {{prospect.source}}
- **Current stage:** {{prospect.current_stage}}

## Their world

{{one_paragraph_about_the_prospect}}

## What they told us they want

{{stated_wants}}

## What we think they actually need

{{inferred_needs}}

## Our commitment

{{commitment_summary}}

## Key history

| Date | What happened | Link |
|---|---|---|
| {{date}} | Discovery call | {{fathom_url}} |

## Flags

- {{flag_1}}
- {{flag_2}}

---

*Last updated by: {{last_editor}} on {{last_updated}}*
```

### 3.6 `sops/README.md`

```markdown
# SOPs — How they work in IntelForce vaults

Standard Operating Procedures are the "how to do X" docs. They live here, they get written in markdown with checklists, and the SOP Writer agent (when enabled) keeps them current.

## Structure

Each SOP has this shape:

```
# SOP: {{process_name}}

**Owner:** {{owner}}
**Frequency:** {{frequency}}
**Last reviewed:** {{date}}

## When to run this

{{trigger}}

## Inputs

{{inputs}}

## Steps

1. [ ] Step one
2. [ ] Step two
...

## Outputs

{{outputs}}

## Escalation

{{when_to_escalate}}
```

## Naming

`NN-kebab-case-short-name.md` where NN is a 2-digit prefix roughly grouping related SOPs:
- `01-xx` — Onboarding
- `02-xx` — Content production
- `03-xx` — Reporting
- `04-xx` — Incident response
- `05-xx` — Renewals / churn

## Creation

Either:
1. Write one yourself and save here.
2. Ask the SOP Writer agent: "Write an SOP for [process]." It'll draft, save here, and flag {{sales_lead}} for review.
```

### 3.7 `daily/README.md`

```markdown
# Daily notes

The Librarian generates one note per day at 04:00 UTC, summarising:
- What agents ran yesterday
- What proposals were drafted, sent, won, lost
- What content was produced and where it landed
- What escalations were raised
- What needs human attention today

These are write-only for the Librarian. Humans can read and annotate but shouldn't create files in this folder manually.

File naming: `{{YYYY-MM-DD}}.md`.
```

### 3.8 `_meta/schema-version.md`

```markdown
# Vault schema version

Current: 1.0

Changelog:
- 1.0 (2026-04-22) — Initial release. 10 agents. Git-sync default.

Migration between schema versions is managed by the Librarian's scheduled-task runner. Do not manually edit files in `_meta/` unless you know what you're doing.
```

### 3.9 `_obsidian-templates/daily-note.md`

```markdown
---
type: daily
date: {{date}}
---

# {{date:dddd, Do MMMM YYYY}}

## Today's agent summary

*(Generated by Librarian — do not edit above this line.)*

## Today's priorities

- [ ]

## Notes


## Tomorrow
```

### 3.10 `_obsidian-templates/proposal-frontmatter.md`

```markdown
---
prospect:
prospect_domain:
deal_value:
deal_value_display:
tier:
tier_count:
call_id:
call_url:
call_date:
drafted_at:
drafted_by:
status: draft-awaiting-review
sales_lead:
tags:
  - proposal
  - draft
---

# Proposal for {{prospect}}

...
```

---

## 4. What the Provisioning System does at setup

1. Create GitHub repo at `intelforce-vaults/{client_slug}`, private, initialised with README.
2. `git clone` this skeleton into a temp dir on the provisioning host.
3. Substitute all `{{...}}` placeholders using values from the Configuration Wizard output.
4. Commit as `chore: initialise vault for {{client.name}}`.
5. Push to the new repo.
6. Create a deploy key (read/write) specific to this tenant, add it to the repo.
7. Store the deploy key at `secrets://{tenant_id}/github/deploy_key`.
8. Tenant container picks it up on boot and clones into `/tenant/vault/`.

---

## 5. Files that remain empty after seeding

Not a mistake — these are deliberately empty so the client sees the scaffolding but isn't overwhelmed:

- `brand/positioning.md`
- `brand/style-guide.md`
- `brand/case-studies/` (except `_template.md`)
- `content/long-form/`, `content/social/`, `content/email/`
- `clients/` (except `_template/`)
- `sops/` (except `README.md` and `_index.md`)
- `archive/`
- `reports/`

The Client Onboarder agent is responsible for filling these out during weeks 1–2 of any new client engagement.

---

## 6. Minimum content required before agents are useful

Not strictly required, but agents degrade without these:

- [ ] `CLAUDE.md` — populated (Wizard does this)
- [ ] `brand/voice-profile.md` — at minimum §1 (one-line description) and §5 (banned phrases). Full profile ideal.
- [ ] `brand/pricing.md` — populated (Wizard does this)
- [ ] `brand/service-catalogue.md` — populated (Wizard does this)

If voice-profile.md has `voice_profile_completeness < 30%`, agents will emit a warning when running and use generic business tone until the profile is fleshed out.

---

## 7. pgvector indexing

After initial commit, the Provisioning System triggers the indexer to embed:
- `CLAUDE.md`
- Everything in `brand/`
- Any `.md` with `tags: [winning-proposal]` (once those exist)

Indexing takes 30–60 seconds for a fresh vault (100KB of content, ~50 chunks). All subsequent writes are indexed automatically by the Librarian's continuous indexer.
