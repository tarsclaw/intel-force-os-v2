REJECTED

1. The top-level status value is invalid and predictive. Line 4 uses `Drafting — will land Accepted`, which is not an allowed status and asserts a future acceptance. Fix by setting Status to Proposed until founder approval is recorded, then Accepted with a decision date.

2. The decision introduces `decision_log.phase` values before proving the live schema supports them. Lines 351, 371, and 376 require `agent_handoff` and `gating_failed`; lines 424-430 say the Day-4 provisioning script still needs the CHECK constraint update. Fix by either citing the migration that already landed the enum extension, or keeping the document Proposed and making the phase extension a prerequisite.
