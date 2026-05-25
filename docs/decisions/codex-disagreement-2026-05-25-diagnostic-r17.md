# Codex disagreement — Diagnostic R16 Finding 3 (multi-line misread)

**Date:** 2026-05-25 (Day 20)
**Artefact:** `agents/recruitment/diagnostic/agent.md`
**Codex round:** R16 (`logs/codex-ratification/20260524T130117Z-63874/`)
**Disposition:** **REJECT-CODEX** (finding does not apply to current file state)

## Codex's finding (verbatim)

> 3. §4 Gate-A failure signature is incomplete. Lines 117-119 say `validate_gate_a_fail` carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`, but §6 line 171 lists `ESC_VOICE_DRIFT` and `validate.sh` lines 253-255 can emit it. Fix the workflow text to include `ESC_VOICE_DRIFT` in the validation-failure audit-row signature.

## Why this is REJECTED

Codex's quote stops at line 119 ("...carries only `ESC_AGENT_OUTPUT_SHAPE` or `ESC_PII_LEAKAGE_RISK`"), but the file's statement spans lines 117-121 — and ESC_VOICE_DRIFT IS listed at lines 119-120. The full text (verbatim from the file at R16 close commit `4854b37`, unchanged at R17):

```
117  → on fail: validate.sh emits hh_decision_action("validate_gate_a_fail", ...)
118    with payload carrying specific ESC code (ESC_AGENT_OUTPUT_SHAPE for
119    section count / citation / length failures; ESC_VOICE_DRIFT for V3
120    voice-classifier-score-low failures; ESC_PII_LEAKAGE_RISK for PII
121    boundary breaches) and exit 1
```

Lines 119-120 explicitly include `ESC_VOICE_DRIFT for V3 voice-classifier-score-low failures`. The signature is complete; this was already addressed at R15 commit `23f8c14` ("voice-classifier honesty + ESC_VOICE_DRIFT routing + LinkedIn-stub honesty + recent_edits signature").

This is a Codex multi-line-statement parsing error — the reviewer truncated its read of the source artefact mid-statement.

## Action

No edit to the agent.md or validate.sh. R17 dispositions cover the other 4 findings; this disagreement is recorded per master brief §10.3 step 4 ("Claude Code reads Codex's feedback; incorporates it or counter-argues explicitly in `docs/decisions/codex-disagreement-{date}.md` (the disagreement IS the signal — write it down, don't dissolve it)").

If Codex repeats this same finding at R18 against the unchanged text, escalate to founder per §10.3 step 5.

## Related

- ADR-006 — Diagnostic Gate A hybrid (Accepted Day 19, Cat-1/Cat-ζ structural close)
- R15 commit `23f8c14` — original ESC_VOICE_DRIFT routing add
- R16 commit `4854b37` — final R16 cleanups (Finding 3's signature unchanged from R15)
