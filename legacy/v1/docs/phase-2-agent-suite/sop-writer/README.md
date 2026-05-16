# SOP Writer

**Purpose:** Convert ad-hoc process descriptions (chat logs, emails, verbal walkthroughs) into versioned, actionable SOPs saved in the vault.

**Trigger:** Manual — user asks "write an SOP for X" via dashboard or chat.

**Output:** Formal SOP in `/vault/sops/` following the standard SOP template, plus a change-log entry if revising an existing SOP.

**Tier availability:** Scale+.

---

## What it does

Every business has processes they keep in people's heads — "how we onboard a new team member," "how we escalate a delayed client deliverable," "what to do when a payment bounces." SOP Writer is the tool for turning those implicit processes into explicit, versioned, assignable ones.

The agent takes unstructured input — a Slack thread, an email exchange, a transcript from a voice note — and produces a formal SOP with: clear trigger, named owner, ordered steps, inputs/outputs per step, escalation path, success criteria. It saves with a version number and a change-log entry if it's revising existing.

## What it needs

- The raw process description (text, from the trigger payload)
- `/vault/sops/_index.md` — so it can check whether the SOP already exists
- `/vault/brand/voice-profile.md` — even SOPs should sound like the client (some use bureaucratic register, some casual)

## What it doesn't do

- Write SOPs for processes that are too vague to be formalised (escalates)
- Enforce SOPs — just writes them; compliance is a human matter
- Override an existing SOP without flagging the change (creates v2 alongside, doesn't silently replace)

## Cost per run

~£0.30 per SOP.

## Related

- **Librarian** (tags and indexes SOPs for retrieval)
- Other agents can reference SOPs in their workflow outputs ("per SOP 03-client-escalation")
