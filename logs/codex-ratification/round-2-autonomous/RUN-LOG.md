Codex Round 2 autonomous run log

Start: 2026-05-22 Europe/London

Tenancy invariants internalised from docs/architecture/tenancy-invariants.md §2:

T1 — Every tenant-data table has `tenant_slug TEXT NOT NULL`.
T2 — Every tenant-data table has `ENABLE ROW LEVEL SECURITY`.
T3 — Every tenant-data table has a `tenant_isolation` policy.
T4 — Every app-code write to a tenant-data table calls `SET LOCAL ifos.tenant_slug` first.
T5 — `ifos_app` role has no DELETE on `decision_log` or `recent_edit` (append-only audit tables).
T6 — `/vault/<tenant>/` has restrictive permissions; no symlinks cross tenant boundaries.
T7 — Rendered agent dirs at `${frameworkRoot}/orgs/<tenant>/agents/` never cross-link.
T8 — Rendered `_secrets.env` is `chmod 0600`.
T9 — Tenant slug pattern enforced (DNS-safe + Postgres role naming).
T10 — Voice corpus `is_active=TRUE` enforced unique per tenant.
T11 — Cross-tenant RLS structurally blocks reads even when app code forgets the guard.
T12 — `_shared/` helpers are tenant-agnostic (no hard-coded tenant slugs).

Protocol loaded:
- docs/operations/codex-round-2-handoff.md
- .codex/ratification/SKILL.md
- .codex/ratification/review-architecture-decision.md
- .codex/ratification/review-schema-change.md
- .codex/ratification/review-postgres-migration.md
- docs/build-brief/00-MASTER-BRIEF.md §1, §3, §10
