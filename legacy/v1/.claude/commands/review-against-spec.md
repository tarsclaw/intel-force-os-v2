---
description: Check whether current code or a specific change is faithful to the spec. Useful before committing significant work.
---

# /review-against-spec

Compare the current implementation (or a specific file or PR) against the relevant spec section. Surfaces gaps between "what we planned" and "what we built."

## Usage

```
/review-against-spec                                 # review all uncommitted changes against specs
/review-against-spec src/cards/approval.ts           # review one file
/review-against-spec --pack=teams-hr-agent           # broad review of Teams HR Agent implementation
/review-against-spec --stage=E                       # review build stage E (Relevance AI integration)
```

## What I do

1. Identify the relevant spec file(s) for the code in question
   - From CLAUDE.md (current build stage → spec section)
   - From file path (`src/cards/approval.ts` → `02-component-design.md §3`)
   - From pack argument (`--pack=X` → all files in that pack)
   
2. Read the relevant spec section

3. Read the current code (uncommitted changes OR the named files)

4. Compare on:
   - **Shape conformance:** does the data shape match the spec?
   - **Behaviour conformance:** does it do what the spec says?
   - **Invariants:** are the non-negotiables preserved?
   - **Missing pieces:** what's in the spec but not yet implemented?
   - **Extra pieces:** what's in the code but not in the spec?

5. Output a structured review

## Output format

```
REVIEW: src/cards/approval.ts vs docs/teams-hr-agent/02-component-design.md §3.1

✓ MATCHES SPEC
  - Data shape: ApprovalCardData matches _template_data_shape exactly
  - Uses adaptivecards-templating.Template.expand() as specified
  - All 8 required fields present

⚠ DIVERGES FROM SPEC  
  - Spec §3.1 requires citations rendered as TextBlocks with the "Small" size
    Code uses default size (looks the same visually but spec says small)
    → suggest: change to `size: 'Small'`
  
  - Spec §3.1 says submittedAt should be ISO 8601
    Code uses `new Date().toLocaleString('en-GB')` 
    → suggest: use `new Date().toISOString()`

✗ MISSING FROM CODE (but in spec)
  - Spec §3.1.5 describes the Edit ShowCard action
    Code does not include Edit button
    → suggest: add Edit action per spec; it's a key feature

✗ EXTRA IN CODE (not in spec)
  - Code adds a "View in KB" button with Action.OpenUrl
    Not mentioned in spec
    → ask: is this intentional? should spec be updated?

INVARIANT CHECK
  ✓ Card does NOT auto-send any reply
  ✓ HR Lead is the trust anchor (approver, not employee)
  ✓ No PII logged at INFO level

SUMMARY
  Severity: MEDIUM
  2 minor divergences + 1 missing feature
  Recommended: address missing Edit before declaring stage F complete
```

## When to use

### Proactively
- Before committing a significant chunk of work
- Before marking a build stage complete (`CLAUDE.md` tracker)
- When you've been heads-down for hours and want a sanity check

### Reactively
- When something's not working and you suspect implementation drift
- When a behaviour isn't what you expected (spec says one thing, code does another)
- Before a demo (so you don't show something specced but not working)

## What this command is NOT

- **Not a linter.** Doesn't check code style, formatting, or language conventions.
- **Not a test.** Doesn't execute anything. Review only.
- **Not authoritative.** If spec and code disagree, sometimes code is right (specs can be wrong). I'll surface the divergence; you decide.

## The "spec is wrong" path

If review finds code is correct but spec is wrong:

1. Don't silently "fix" the spec
2. Flag the divergence explicitly: "Code is right; spec needs update"
3. Ask whether to update the spec
4. If yes, update, commit with message: `docs: align spec with implementation — §X.Y`
5. If no, add to open questions list

This preserves auditability. Specs are source of truth by default; explicit overrides are documented.

## Cross-references

- Spec files all live in `docs/` — see `MASTER-INDEX.md`
- The phase skills have "when to consult" sections that help locate the right spec
- `/phase-status` shows build stage, which implies spec focus
