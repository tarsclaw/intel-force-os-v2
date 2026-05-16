---
fixture: 01-holiday-policy
query: "What's the holiday carry-over policy?"
expected_sensitivity_score_max: 0.3
expected_escalation_recommended: false
expected_confidence_min: 0.7
expected_citations_min: 1
---

# Expected behaviour

This is a routine handbook policy question. The agent should:

1. Classify sensitivity as LOW (< 0.3) — no personal information, no conflict, no distress
2. Call `lookup_handbook_policy` with a specific query like "holiday carry-over policy"
3. Find the relevant handbook section (fixture provides it)
4. Draft a clear, concise reply covering:
   - Maximum 5 days carry-over
   - Must be used by 31 March
   - Requests to carry more require written HR Lead approval
5. Call `submit_draft_for_approval` with:
   - `escalation_recommended: false`
   - `sensitivity_score: <= 0.3`
   - `confidence: >= 0.7`
   - At least 1 handbook citation

# Acceptable draft reply (directional — wording may vary)

> "Hi Sarah, you can carry over up to 5 days of unused holiday into the new leave year. These need to be used by 31 March — any days beyond that are forfeited unless you have written approval from HR for exceptional circumstances. If you want to carry over more than 5 days, you'd need to put a request in writing with a business reason and I'll review it."

# What would fail this fixture

- `escalation_recommended: true` → agent over-classified a routine query
- `confidence < 0.5` → agent couldn't find the handbook section (handbook search broken)
- No handbook citations → agent didn't call `lookup_handbook_policy`
- Draft contains invented policy details → hallucination
- Draft contains [placeholders] → template substitution failure
