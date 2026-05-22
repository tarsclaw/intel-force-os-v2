REJECTED

1. Required decision-document status field is missing. Lines 3-6 provide date, audited SHA, package manifest, and method, but no top-level `Status:` with an allowed value. Fix by adding `**Status:** Reference` near the header.

2. The artefact lacks explicit Context, Decision, and Consequences sections. It has a summary table at lines 17-29 and primitive sections from line 33 onward, but not the required decision-doc shape. Fix by adding a short Context section, a Decision/Findings section that names the audit conclusions, and Consequences for Day-7 Q2/risk-register updates.
