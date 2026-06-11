# Codex ratification skill — review-policy-config

Type-specific checks for: shared product-policy / configuration YAML artefacts under `agents/_shared/` (e.g. `autosend-policy.yaml`, `action-class-registry.yaml`) and their per-tenant vault-schema example fixtures.

This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.

Authored 2026-06-11 (W2 approval-routing slice) — Codex round 20260611T140754Z-61461 finding 1 established that `review-schema-change` cannot meaningfully apply to policy/config artefacts; this skill supplies the applicable criteria.

---

## §1 — Join-key integrity (the load-bearing check)

A policy/config artefact that keys off another artefact's identifiers (e.g. a registry keyed by `autosend-policy.yaml` action_types) MUST be in exact set equality with its source unless the header explicitly documents the intended difference. Verify by parsing BOTH files and diffing key sets in both directions — never by eyeball. REJECT on any silent superset/subset.

## §2 — Row completeness + enum discipline

Every row carries every field its header schema declares; every value within its declared enum/type (booleans are booleans, durations are integers-or-null with null semantics stated). REJECT on missing fields or out-of-enum values.

## §3 — Internal invariants stated AND satisfiable

Header-declared invariants (e.g. "safe_default ⇒ a holding template exists for the register"; "red never graduates") must each be checkable against the file plus its named companions, and must actually hold. REJECT if an invariant is unsatisfiable as written or violated by any row.

## §4 — Provenance + judgement honesty

Seeded values trace to a named spec section or carry an explicit inline judgement marker (e.g. `# seed-judgement:`) with rationale. Silent invention of policy values = REJECT. Judgement calls that contradict (rather than fill gaps in) the cited spec must say so explicitly.

## §5 — Status vocabulary

The artefact header carries a status using the approved lifecycle vocabulary (Proposed / Accepted / In Force) with the flip conditions named. Marketing-register status strings without the lifecycle field = REJECT.

## §6 — Per-tenant variation rules

The header states exactly which per-tenant artefacts may vary behaviour relative to this file, where they live (vault path or Postgres store), and the direction-of-override rules (e.g. elevation-only). Structured per-tenant STATE must live in Postgres per the vault/Postgres split (boundary 3); vault files holding state must be explicitly generated/read-only snapshots.

## §7 — Boundary compliance

No forbidden third-party adapter names anywhere (adapter boundary — generic wording only); no cortextOS-submodule references as runtime dependencies; tenant isolation assumptions stated where rows imply cross-record reads.

## §8 — Consistency with cited build docs

Claims about companion documents (plan decisions, spec sections) must match those documents AS PRESENT IN THE SAME TREE. If the artefact cites a plan/spec, read it and verify the citation; flag staleness precisely (file:line on both sides).
