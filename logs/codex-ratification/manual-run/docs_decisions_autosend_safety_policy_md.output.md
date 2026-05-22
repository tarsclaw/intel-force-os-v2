REJECTED

1. v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. Fix by separating "policy taxonomy" from "v1.0 enforcement subset" and making would-be-yellow/orange execution rules explicit.

2. Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0. Lines 96-110 classify high-risk sends as orange, while lines 630-632 say Diagnostic/Concierge orange cases fall back to ad-hoc approval. Fix by making v1.0 default for these actions red-unless-ad-hoc-helper is explicitly invoked, or by moving orange implementation into v1.0 prerequisites.

3. The legal placeholder is load-bearing for pilot readiness but unresolved. Lines 498-500 warn not to use the liability language as-is, and lines 578-584 leave jurisdiction, liability cap, dispute forum, insurance, and PII liability open. Fix by marking pilot LOI signing blocked until counsel-reviewed language replaces §10.
