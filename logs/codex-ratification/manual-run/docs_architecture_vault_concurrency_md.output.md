REJECTED

1. The reference introduces a schema change without a migration citation. Lines 117-124 require `entities.version INT NOT NULL DEFAULT 0`, and lines 431-439 add it as a Day-4 prerequisite, but no migration file path is cited. Fix by referencing the exact Day-4 SQL/runbook section that creates `version`, or add a migration companion.

2. New ESC codes are introduced before the implementation dependency is satisfied. Lines 397-407 define five `ESC_VAULT_*` codes and state `_shared/hook-helpers.sh` must wire them later. Fix by citing the committed `agents/_shared/escalation-codes.md` entries and helper implementation, or mark the document Proposed instead of Reference until wiring lands.
