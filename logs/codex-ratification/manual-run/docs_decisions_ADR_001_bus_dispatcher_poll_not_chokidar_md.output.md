REJECTED

1. ADR-specific decision subheadings are missing. Lines 28-53 have a `## Decision` section, but the required explicit `Decision 1 — <terse summary>` subheading is absent; the content uses bold numbered paragraphs instead. Fix by converting the two decisions at lines 32 and 42 into `### Decision 1 — Correct master brief bus mechanism` and `### Decision 2 — Accept 1000ms poll latency floor`.

2. Status evidence conflicts with author metadata. Line 4 says founder review is pending, while lines 7 and 76 say the founder decision is logged and the ADR is Accepted. Fix by either removing the pending-review author qualifier or changing Status back to Proposed until founder approval is actually recorded.
