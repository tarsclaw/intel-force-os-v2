REJECTED

1. The top-level status value is invalid for this artefact type. Line 4 uses `Mixed`, which is not one of the allowed statuses (`Proposed | Accepted | In Force | Reference | Superseded | Deprecated`). Fix by setting the document Status to Proposed and preserving per-sub-decision statuses inside the body.

2. The document claims Week-1 implementation can proceed before the auth path is cleared. Lines 57-72 list commercial blockers for Sub-decisions A/B, but line 95 says those can remain Proposed without blocking Week-1 implementation. That weakens the Day-7 auth-path quality gate. Fix by making Bullhorn connector scaffolding explicitly conditional on A/B resolution or by narrowing Week-1 work to non-auth code only.

3. The rate-limit budget is speculative but operationally used. Lines 318-332 state Bullhorn rate limits are commercially gated, yet lines 320-330 set concrete per-agent request budgets used downstream. Fix by marking these as non-binding assumptions and adding a hard pre-flight gate that actual Bullhorn limits must replace the table before any production connector run.
