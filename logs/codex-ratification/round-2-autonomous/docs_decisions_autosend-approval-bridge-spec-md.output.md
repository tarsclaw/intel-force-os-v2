REJECTED

1. The bridge maps IFOS action_types to cortextOS approval categories that do not exist. The spec maps to `customer_message`, `email_send`, and `state_change` (lines 130-143), but the pinned cortextOS type only permits `external-comms`, `financial`, `deployment`, `data-deletion`, and `other` (`packages/harness/cortextos/src/types/index.ts` lines 116-121; validator lines 60-68). A bridge built from this spec would fail category validation on most approvals.
   Proposed fix: rewrite the mapping table to use the actual cortextOS categories, probably `external-comms` for customer/email/social messages, `financial` for payment reminders if money-moving, and `other` only as an explicit fallback.

2. The proposed bridge-state table is underspecified against the tenancy invariant set. Lines 104-121 define `autosend_approval_mappings` and RLS, but the spec does not update the tenant-data table inventory/audit script that currently expects exactly 9 tenant-data tables.
   Proposed fix: add the table to `docs/architecture/tenancy-invariants.md`, `scripts/run-tenancy-audit.sh` `TENANT_TABLES`, and the v0.3 migration acceptance criteria, or explicitly choose SQLite state to avoid a new tenant-data table.
