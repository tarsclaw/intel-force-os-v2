REJECTED

1. The v1.0 tier semantics remain contradictory. The policy says every governed action falls into exactly one tier at execution (lines 41-43) and orange requires a cortextOS approval gate before send (lines 57-60), but §9 still says v1.0 ships "green + red only" and handles "needs approval" outside the policy pipeline (lines 474-481). The later Q6 note accepts an ad-hoc helper (lines 612-618), but that does not reconcile the binding tier model.
   Proposed fix: choose and encode one v1.0 behavior. Either D1-A: mark all orange action_types red in v1.0; D1-B: update §9 to say orange approval is in scope via the bridge; or D1-C: model ad-hoc approval as a named v1.0 tier/policy path with exact helper semantics.

2. The legal placeholder remains explicitly unusable for pilot LOIs. The document warns not to use §10 as binding language (lines 498-500) and leaves jurisdiction, liability cap, dispute forum, cyber insurance, and PII liability open (lines 578-584).
   Proposed fix: mark first pilot LOI signing blocked until counsel-reviewed language replaces §10, or move the placeholder out of the ratified policy into a non-binding appendix with the blocker tracked in the kill criterion.
