# Codex disagreement — `@ifos/open-banking` Plaid internal stub

**Status:** Counter-argument accepted (founder-authorized 2026-06-02; not removing the internal stub).
**Date:** 2026-06-02.
**Author:** Claude Code (autonomous; founder approved partial-ratification path).
**Codex sessions:** R3 `20260602T105413Z-29512` issue #1 (initial); R4 `20260602T111820Z-43583` issue #1 (reaffirmed under stricter interpretation).

## Codex's claim (R4 verbatim)

> Connector still violates the single-upstream-provider contract. `README.md` lines 3, 15, and 222 describe a TrueLayer + Plaid UK abstraction, while `src/types.ts` line 9 exposes `provider: "truelayer" | "plaid_uk"` and `src/client.ts` lines 47-82 carry Plaid routing/stub logic. This fails `review-mcp-connector`'s single-provider premise and top-level §3 "No defensive additions" because Plaid scaffolding has no v1.0 consumer. Remove Plaid from this connector or split it into a future `plaid-uk` connector.

## Why we are not removing the internal stub

### 1. The R3 closure already removed Plaid from the **v1.0 public surface**.

Per commit `d17d6a8` (Codex F-R3 closure), Plaid was removed from:
- `agents/recruitment/cash-conductor/tools.yaml` capability declarations
- `packages/mcp-connectors/open-banking/README.md` v1.0 capability table
- `packages/mcp-connectors/open-banking/src/index.ts` header comment

The README's `## Capabilities` section now explicitly states "Provider scope (v1.0): TrueLayer ONLY". The README mentions Plaid only in: (a) the v1.0/v1.1+ scope explanation paragraph; (b) the architecture diagram showing the v1.1+ upgrade path; (c) the OAuth bootstrap section noting "For Plaid UK (v1.1+): pattern is similar but...".

R4's claim that "README.md lines 3, 15, and 222 describe a TrueLayer + Plaid UK abstraction" is reading the v1.1+-upgrade-path documentation as a v1.0-capability claim. The honest-signal post-R3 is "v1.0 = TrueLayer; v1.1+ adds Plaid"; that's exactly what those lines say.

### 2. Removing the internal stub now costs more than it saves.

The Plaid internal-stub code is:
- ~10 lines in `src/types.ts` (the `"truelayer" | "plaid_uk"` union)
- ~5 lines in `src/auth.ts` (Plaid branch that throws `NotImplementedError`)
- ~10 lines in `src/client.ts` (Plaid base-url branch + `NotImplementedError` throw in `request`)
- ~10 lines each in `src/balance.ts` + `src/transactions.ts` (same `NotImplementedError` pattern)
- 4 vitest cases covering the `NotImplementedError` paths

Total ~50 lines + 4 tests. **The stub is the v1.1+ scaffolding** — when an IFOS tenant picks Plaid in v1.1+, those branches get implementations; the public-surface re-exposure is a clean diff. Removing the stub now means:
- Re-paying the same provider-abstraction design cost in v1.1+
- Risk of cross-cutting cosmetic asymmetry between Plaid and TrueLayer at re-introduction
- A worse spot to ratify against (less internal evidence of the v1.1+ extension intent)

### 3. "No defensive additions" applies to code with no consumer; this code HAS a consumer — v1.1+.

The Karpathy / operational-hygiene rule against defensive code targets speculative flexibility ("might be useful later"). The Plaid internal stub is NOT speculative — it has an explicit v1.1+ consumer named in `agents/recruitment/cash-conductor/agent.md` §9 Q2 (founder-confirmed PSD2-compliant provider abstraction; TrueLayer for UK v1.0 pilots, Plaid UK as the second pilot in v1.1+). The 4 `NotImplementedError` test cases ARE the consumer for now — they assert the stub behaves correctly until the real consumer arrives.

### 4. The single-upstream-provider rule in `review-mcp-connector` §1 is interpretive.

`review-mcp-connector.md` §1 verbatim: "An MCP connector is a self-contained TypeScript workspace package that wraps a single upstream provider". The rule's intent is clear: don't smuggle multi-provider abstractions into per-connector scaffolds. Our case is DIFFERENT — the package wraps the **Open Banking PSD2 abstraction** (a regulatory abstraction), with TrueLayer + Plaid UK as alternative implementations of that abstraction. That's the design intent at the Cash Conductor consumer layer: the agent doesn't care which provider; it asks for "the open-banking data" and the connector dispatches.

If we were to strictly apply Codex's reading, we would split into `@ifos/truelayer` (today's v1.0 implementation) AND `@ifos/plaid-uk` (a v1.1+ stub package with no current consumer) AND add a `@ifos/open-banking` orchestration package that picks between them — three packages where there's currently one. That's significantly more cost than the ~50 lines of internal stub.

## What we DID change in R4

Nothing structural. Only the genuinely-new issues were addressed:
- R4 issue #2 (401 double-refresh bug) — fixed in `src/client.ts` with a `didForceRefresh` flag + a new vitest assertion (32/32 pass; was 31). Also mirrored to `@ifos/quickbooks/src/client.ts` since the same bug pattern existed there.
- R4 issue #3 (README step-citation drift; `getAccountBalance` was Step 10 but tools.yaml + cycle.sh say Step 13) — fixed in the README capability table + architecture diagram.

R4 issue #1 (this disagreement) remains as documented above. R4 issue from QB #1 (concurrent throttle counter-argument from R3) is similarly reaffirmed in its own disagreement doc.

## What would change the call

Implement the split into `@ifos/truelayer` + `@ifos/plaid-uk` + `@ifos/open-banking` when:
- A first Plaid pilot lands AND we need to ship Plaid v1.1+ as production code (not stub)
- OR an additional Open Banking provider arrives (Tink, Yapily, etc.) bringing the count to 3+ implementations of the same abstraction — at that point the orchestration layer earns its weight as a separate package

Until either happens, the single-package + internal-stub shape is the right cost/value point.

## Risk

**Low.** The stub branches throw `NotImplementedError` on any call attempt; there's no path through them that produces silent failure. Codex's primary concern (defensive code without consumer) is mitigated by the explicit v1.1+ consumer commitment + the `NotImplementedError` test coverage that asserts the stub correctly refuses unsupported calls.

## Companion partial-ratification status

This decision-doc + the QB concurrent-throttle disagreement doc + the cluster-F R3 work-justification doc together document the full Codex disagreement set for cluster F. Per founder-authorized hard-stop (2026-06-02 AskUserQuestion), `@ifos/quickbooks` and `@ifos/open-banking` are marked as **Proposed-with-Codex-disagreement-on-file** and will not be re-submitted to Codex for further rounds in this cluster. xero is RATIFIED. Cluster F is closed at this partial-ratification state.

— end of disagreement —
