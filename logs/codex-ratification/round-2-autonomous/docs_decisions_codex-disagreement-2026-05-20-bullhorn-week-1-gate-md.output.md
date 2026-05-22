REJECTED

1. The counter-argument's framing is plausible, but the promised artefact remediation did not actually land. The disagreement doc says the correct fix is wording sharpening (lines 46-48), proposes exact prereq-code-only wording (lines 64-70), and then says the change ships in the same commit (line 72). The actual `bullhorn-integration-path.md` still has the broad line-95 wording that connector code can scaffold against direct API before A+B are accepted.
   Proposed fix: either update `bullhorn-integration-path.md` line 95 to the exact text proposed here, or amend this disagreement doc to say the sharpening is still pending and the original Codex rejection remains open.

2. Because the underlying artefact remains ambiguous, Codex cannot ratify the recursive disagreement as closed. The correct gate hierarchy may be "Week-1 prereq substrate is allowed; Bullhorn auth/connector work waits until W5 gate," but that hierarchy is not yet encoded in the source decision document.
   Proposed fix: add a small "Gate hierarchy" subsection to the Bullhorn decision that distinguishes Week-1 substrate, Diagnostic W3-4, and Janitor W5 before re-running ratification.
