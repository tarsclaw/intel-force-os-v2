# harvest/ — staged for the new estate repo

Everything CortexOS hands to the new repo, arranged in the shape it lands in. **Nothing here is a new artefact
except the four `.md` files**; the rest are verbatim copies or a schema dump derived and verified offline.

Governed by `docs/handoff/HARVEST-MANIFEST.md` (what moves) and `docs/handoff/MIGRATION-PLAN.md` (how).
Verification results: `VERIFICATION.md`.

| Directory | Contents | Destination in new repo | Mechanic |
|---|---|---|---|
| `actions/` | `autosend-policy.yaml`, `action-class-registry.yaml`, join contract, `hook-helpers.sh` (reference only) | `actions/` + read by `packages/authoriser` | **re-home, zero edits** |
| `migrations/` | `0000_baseline.sql` (v0.4), `0001_reconciliation_writeback.sql` + rollback | `migrations/` | derived + verified |
| `sql/` | 5 standalone RLS-scoped query artefacts, 400 lines | called by the rebuilt agents | verbatim |
| `registers/` | escalation catalogue + harvest reconciliation appendix | `docs/registers/` | verbatim + appendix |
| `specs/` | 6 × `agent.md` + 6 × `tools.yaml`, 3,978 lines | reference for authoring action definitions | verbatim |
| `scripts/` | `setup-local-dev-db.sh` + 2 runbooks | `scripts/` | verbatim |

**Not staged here:** the nine connectors (Phase B — they move directly when the phase opens; staging 14,000 lines
twice serves nothing) and the bundle shell (rebuilt, not moved — `specs/` carries the specification).
