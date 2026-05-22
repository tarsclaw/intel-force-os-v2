REJECTED

1. `voice_classifier_score` is bounded but no v0.1 enforcement is named. Lines 141-145 define candidate `voice_classifier_score` as range `[0, 1]`; the schema-change rubric requires a CHECK constraint or trigger for bounded scores. Fix by citing the migration/trigger that enforces the bound or remove the bounded field from v0.1 until v0.2.

2. Non-v1.0 entities do not use the required explicit access wording. Lines 497 and 536 use empty arrays for `v1_0_agent_access`, but the rubric requires explicit `none (v1.1+ exercise)` or equivalent. Fix `opportunity` and `timesheet` to state the explicit none/default exercise text.

3. The versioning summary is stale. Lines 878-879 say there are 10 open questions, but the file contains Q1 through Q12 at lines 793-866. Fix the v0.1 versioning text to state the actual count and list which are resolved/deferred.
