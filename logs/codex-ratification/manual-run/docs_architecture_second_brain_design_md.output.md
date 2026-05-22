REJECTED

1. The status value is invalid. Line 4 says `Design specification (not a decision record)`, which is not one of the allowed status values. Fix by changing it to `Status: Reference` and leaving the non-binding recommendation note as prose.

2. The design proposes adding escalation codes without proving the catalogue contains them. Lines 974-975 add `ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_CONCURRENCY`, `ESC_HUMAN_EDITING_LOCK`, and `ESC_VAULT_RENAME_RACE`; the ratification rule requires new ESC codes to be confirmed in `agents/_shared/escalation-codes.md`. Fix by citing the catalogue entries or moving the codes into a follow-up implementation artefact.
