REJECTED

1. The Week-1 gate wording remains substantively ambiguous after the claimed remediation. `bullhorn-integration-path.md` still says Sub-decisions A+B can remain Proposed "without blocking Week-1 implementation" and that "connector code can be scaffolded against direct-API as the default" while the auth module changes later (line 95). That is not the narrowed "Week-1 prereq code only; no Bullhorn connector/auth work" wording proposed in the disagreement doc.
   Proposed fix: replace line 95 with the explicit prereq-code-only text from `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md` lines 64-70, and state that any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
