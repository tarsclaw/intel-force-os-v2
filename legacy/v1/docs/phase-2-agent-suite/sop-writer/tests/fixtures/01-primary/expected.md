---
type: sop
title: "Voice Receptionist — emergency escalation"
category: "04-incident-response"
owner: "Practice Principal (Dr Priya Shah) + Practice Manager (Laura Chen)"
frequency: "on-trigger"
trigger: "Voice Receptionist detects emergency keywords in a caller's opening statement"
version: v1
last_verified: 2026-06-10
verify_every_days: 90
drafted_at: 2026-06-10T11:32:00Z
drafted_by: sop-writer@1.0.0
status: draft-awaiting-review
tags: [sop, 04-incident-response, clinical-emergency]
---

# SOP: Voice Receptionist — emergency escalation

**Owner:** Practice Principal (Dr Priya Shah) + Practice Manager (Laura Chen)
**Trigger:** Voice Receptionist detects emergency keywords in a caller's opening statement
**Frequency:** On-trigger
**Last reviewed:** 2026-06-10

## When to run this

Voice Receptionist classifies a call as a clinical emergency when the caller mentions any of: pain, swelling, trauma, bleeding, facial swelling, inability to close mouth, tooth knocked out, or explicit "emergency" language. This SOP governs what happens next — different flows for in-hours and after-hours.

## Preconditions

- Voice Receptionist is live and configured with the emergency keyword list (maintained in `/vault/sops/assets/emergency-keywords.txt`)
- Priya's WhatsApp and Laura's SMS are registered as primary escalation endpoints in the Voice Receptionist config
- Dr Singh's SMS is registered as the backup locum endpoint
- The practice's after-hours voicemail greeting includes the NHS 111 dental line reference
- Dentally's `incidents` field is enabled (Settings → Patient Record → Custom Fields)

## Inputs

- Live phone call received and classified as emergency by Voice Receptionist
- Current practice status (in-hours vs after-hours — determined by system clock + practice calendar)

## Steps

### Business hours (08:30–17:30 Mon–Fri)

1. [ ] **Alert reception-adjacent staff** — Voice Receptionist sends a loud push to Laura's phone (priority override on Do Not Disturb), with caller's number + emergency summary pre-filled.
2. [ ] **Pick up within 2 minutes** — the nearest non-clinical person (default: Laura) takes the handoff call directly. Do NOT route through Dentally or email.
3. [ ] **Triage in 2 minutes max** — ask three questions: location of pain/injury, when it started, is there active bleeding. Note verbatim.
4. [ ] **Book emergency slot if needed** — same-day slot in Dentally under `emergency` appointment type. If no slot available, interrupt the next non-clinical admin period.
5. [ ] **Log the incident** — within 1 hour of the call ending, create a Dentally patient record with the `incidents` field populated: date/time, caller name, triage notes, outcome (booked / referred / advised).

### After hours (all other times + weekends + bank holidays)

1. [ ] **Route to emergency voicemail** — Voice Receptionist redirects the caller to the after-hours voicemail with the emergency-specific script. Script includes NHS 111 dental line number.
2. [ ] **Ping Priya (WhatsApp) and Laura (SMS) simultaneously** — message includes caller's number + emergency summary + time of call.
3. [ ] **First to see it responds** — whichever of Priya or Laura sees the alert first, respond in the channel and call the patient back within 15 minutes. Reply "got this" in the WhatsApp so the other knows it's covered.
4. [ ] **If no response within 15 minutes** — Voice Receptionist escalates automatically:
   - Calls the NHS 111 dental line and relays the caller's situation via its voice handoff script
   - Sends SMS to Dr Singh (backup locum) with caller's number and summary
5. [ ] **Log the incident** — whoever responded creates the Dentally record next business day. If Voice Receptionist auto-escalated (step 4), the platform logs a preliminary record for review.

## Outputs

- Caller has been contacted or appropriately routed within 15 minutes
- Incident logged in Dentally `incidents` field
- Escalation chain status visible in Voice Receptionist dashboard

## Success criteria

- 100% of emergency-classified calls contacted or routed within 15 minutes
- Zero instances of emergency callers reaching voicemail without human follow-up
- All incidents logged in Dentally within 24 hours of the call

## Escalation

- If Voice Receptionist fails to classify a true emergency (false negative) and it surfaces later: log in `/outbox/escalations/`, review the keyword list at the next ops review, and consider adding the missed pattern.
- If the NHS 111 dental line is unreachable: Voice Receptionist retries twice at 5-minute intervals, then SMS's Dr Singh directly as sole backup.
- If an incident involves a minor or a suspected safeguarding concern: escalate immediately to Dr Priya Shah regardless of hours.

## Related SOPs

- None currently. Sibling SOPs to be written: `04-dentally-incidents-field-discipline`, `05-dr-singh-locum-handoff-protocol`.

## Change log

- v1 (2026-06-10) — Dr Priya Shah: initial version, derived from Slack #meadowlane-ops thread 2026-06-09.
