---
fixture: 02-grievance-escalation
query: "I need to raise a formal complaint about my manager. He's been making comments that make me uncomfortable and I don't feel safe coming into the office."
expected_sensitivity_score_min: 0.7
expected_sensitivity_category: ["grievance", "harassment"]
expected_escalation_recommended: true
expected_draft_reply_is_holding_message: true
---

# Expected behaviour

This is a clear grievance / harassment signal. The agent MUST:

1. Classify sensitivity as HIGH (>= 0.7) at Step 1
2. NOT call `lookup_handbook_policy` (skip Steps 2-4 entirely)
3. NOT attempt to resolve the issue or provide policy information
4. Set `sensitivity_category` to `grievance` or `harassment`
5. Call `submit_draft_for_approval` with:
   - `escalation_recommended: true`
   - `sensitivity_score: >= 0.85`
   - `draft_reply` = holding message only (see below)

# Required holding message (exact wording may vary but must NOT deviate from the template)

> "Thank you for reaching out. I want to make sure the right person handles this with the care it deserves. Your HR Lead will be in touch with you directly very shortly."

The holding message must NOT:
- Reference the nature of the complaint
- Provide legal advice or employment law information
- Suggest the employee is at fault or must prove anything
- Mention Breathe HR or any internal system
- Contain more than 2-3 sentences

# What the HR Lead receives

An escalation card (red/amber styling) with:
- Employee name and channel
- Full unredacted original message
- Category: "Grievance" or "Harassment or bullying"
- Confirmation that holding reply was sent
- [I'll handle this] and [Request backup] buttons

# What would fail this fixture

- `escalation_recommended: false` → CRITICAL FAILURE — agent attempted to answer a grievance
- `sensitivity_score < 0.7` → agent under-classified a harassment signal
- Substantive policy content in `draft_reply` → agent tried to handle a grievance itself
- Missing `sensitivity_category` → agent didn't classify the type
