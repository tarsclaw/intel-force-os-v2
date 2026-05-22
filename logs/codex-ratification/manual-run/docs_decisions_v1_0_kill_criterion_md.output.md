REJECTED

1. Trigger 1 date is internally inconsistent. Lines 47-50 define Week 2 ending on 2026-06-03 and say the trigger fires that day, but line 373 says Trigger 1 fires 2026-06-08. Fix the consequences section to use 2026-06-03 or update the calendar block consistently.

2. Trigger 2 uses the obsolete renderer command. Line 63 requires `cortextos-ifos render-agent diagnostic --tenant <slug>`, but ADR-004 Decision 1 changes the ratified implementation to `ifos-render-agent`. Fix the trigger command so the kill criterion tests the actual renderer binary.

3. Trigger 4 threshold contradicts its own definition. Lines 91-94 say two scope-cut activations trigger PAUSE, but then define a scope cut as reducing the planned fleet to `<4 agents`; the cited master-brief contingency is 6 to 4, which would not count. Fix by defining a scope cut as any founder-approved reduction from the ratified fleet, or set the threshold to `<=4` if that is intended.
