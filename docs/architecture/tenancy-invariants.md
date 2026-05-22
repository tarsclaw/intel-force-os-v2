# Tenancy invariants — IFOS multi-tenant safety

**Status:** Reference (In Force on tenant-data write paths).
**Date:** 2026-05-20 (Day 9 evening — pre-Diagnostic-build architecture audit).
**Author:** Founder (Maddox) + Claude Code; consolidates Day-4 §7 RLS gate + ADRs 001-004 + v0.1 + v0.2 schemas + `_shared/` helpers + renderer.
**Authority:** This document supersedes scattered tenancy references in source artefacts. Any new tenant-touching code path is reviewed against the invariants below.

---

## §1 — Why this document exists

IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.

Tenancy is enforced by **layered defence**:

1. **Postgres RLS** is the structural last line of defence. If application code forgets to filter by tenant_slug, RLS still blocks cross-reads at the database engine level.
2. **`SET LOCAL ifos.tenant_slug`** in helper code is the upstream guard. If a path forgets to set it, RLS returns zero rows — explicit failure rather than silent leak.
3. **Vault filesystem permissions** isolate `/vault/<tenant>/` directories.
4. **Rendered agent dirs** at `${frameworkRoot}/orgs/<tenant>/agents/` are physically separate per tenant.
5. **Tenant-agnostic helpers** in `agents/_shared/` never hard-code tenant slugs; everything reads `CTX_TENANT_SLUG` at runtime.

**Meta vs tenant-data tables.** Postgres tables fall into two classes:

- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
- **Meta table** (1): `tenants` — the tenant registry itself. NO RLS by design (the registry needs to be visible to admin operations). All writes admin-only.

The 12 invariants below apply to **tenant-data tables**. The `tenants` meta table is the exception, documented separately under the verification matrix.

---

## §2 — The 12 invariants

### T1 — Every tenant-data table has `tenant_slug TEXT NOT NULL`

- **Definition:** Every row in every tenant-data table carries a non-null `tenant_slug` identifying which tenant the row belongs to.
- **Enforcement:** Migration SQL `CREATE TABLE` statement uses `tenant_slug TEXT NOT NULL` (no DEFAULT, no nullable).
- **Documentation source:** Day-4 §6.3 lines 708-797 (5 tables) + v0.2 §2-§5 (4 tables).
- **Subtle case:** `recent_edit.original_text` was originally `TEXT NOT NULL` in v0.2; v0.3 (post Round-2 remediation) drops that NOT NULL constraint to allow PII purge to set `original_text=NULL`. This does not weaken T1: `recent_edit.tenant_slug` remains `TEXT NOT NULL`.
- **Verification command:**
  ```sql
  SELECT table_name FROM information_schema.columns
  WHERE table_schema='public' AND column_name='tenant_slug' AND is_nullable='NO'
  ORDER BY table_name;
  ```
  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
- **Acceptance:** Every tenant-data table appears; `tenants` table appears only as a meta exception (which is correct — it has `tenant_slug PRIMARY KEY`).

### T2 — Every tenant-data table has `ENABLE ROW LEVEL SECURITY`

- **Definition:** Postgres RLS is enabled on every tenant-data table. Even if a policy is missing or misconfigured, RLS-enabled tables default to deny.
- **Enforcement:** Migration SQL `ALTER TABLE <name> ENABLE ROW LEVEL SECURITY` per table.
- **Documentation source:** Day-4 §6.3 lines 932-936 + v0.2 §2-§5 (4 ALTER TABLE statements).
- **Verification command:**
  ```sql
  SELECT relname FROM pg_class c JOIN pg_namespace n ON c.relnamespace=n.oid
  WHERE n.nspname='public' AND c.relrowsecurity=true ORDER BY relname;
  ```
  Expected: 9 rows (same set as T1).
- **Acceptance:** Every tenant-data table appears; `tenants` does NOT (correct exception).

### T3 — Every tenant-data table has a `tenant_isolation` policy

- **Definition:** RLS policy named `<table>_tenant_isolation` (or `tenant_isolation` for Day-4 tables) attached to every tenant-data table, using `current_setting('ifos.tenant_slug', TRUE)` as the predicate.
- **Enforcement:** Migration SQL `CREATE POLICY` after `ENABLE ROW LEVEL SECURITY`. The `TRUE` second argument to `current_setting()` returns NULL on missing setting (safe — RLS returns 0 rows).
- **Documentation source:** Day-4 §6.3 lines 951-973 + v0.2 §2-§5.
- **Verification command:**
  ```sql
  SELECT tablename, policyname FROM pg_policies
  WHERE schemaname='public' ORDER BY tablename;
  ```
  Expected: 9 rows, one per tenant-data table, policy name follows naming convention.
- **Acceptance:** Every tenant-data table has its `_tenant_isolation` policy.

### T4 — Every app-code write to a tenant-data table calls `SET LOCAL ifos.tenant_slug` first

- **Definition:** Application code (helpers, renderer, ad-hoc scripts) sets the session variable `ifos.tenant_slug` BEFORE the first INSERT/UPDATE/SELECT against a tenant-data table. `SET LOCAL` scopes the setting to the current transaction.
- **Enforcement:** `agents/_shared/hook-helpers.sh::_hh_emit_row` sets it via `SET LOCAL ifos.tenant_slug = '${tenant}';` before INSERT. `agents/_shared/voice-loader.sh::_vl_psql_query` sets it via wrapped SQL. `packages/agent-renderer/src/renderer.ts` doesn't write to tenant-data tables directly (it writes to vault).
- **Documentation source:** `agents/_shared/hook-helpers.sh` lines ~75-95 (`_hh_emit_row` live-mode SQL) + `agents/_shared/voice-loader.sh` lines ~60-70 (`_vl_psql_query`).
- **Verification command:**
  ```bash
  grep -n "SET LOCAL ifos.tenant_slug\|SET ifos.tenant_slug" agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh packages/agent-renderer/src/*.ts
  ```
  Plus adversarial: try INSERT without setting it; expect failure OR succeed-with-RLS-block-on-read.
- **Acceptance:** All write paths confirmed via grep + adversarial test in tenancy audit Step T4.

### T5 — `ifos_app` role has no DELETE on `decision_log` or `recent_edit` (append-only audit tables)

- **Definition:** The two audit tables (`decision_log` from Day-4 + `recent_edit` from v0.2) are structurally append-only. Even if app code attempted DELETE, the role lacks permission.
- **Enforcement:** Migration SQL grants exactly `SELECT, INSERT` on these two tables (no UPDATE, no DELETE).
- **Documentation source:** Day-4 §6.3 line 764 (`GRANT SELECT, INSERT ON decision_log TO ifos_app`) + v0.2 §6 line 172 (`GRANT SELECT, INSERT ON recent_edit TO ifos_app`).
- **Verification command:**
  ```sql
  SELECT grantee, table_name, privilege_type FROM information_schema.role_table_grants
  WHERE grantee='ifos_app' AND table_name IN ('decision_log','recent_edit')
  ORDER BY table_name, privilege_type;
  ```
  Expected: 4 rows total — `decision_log` × {SELECT, INSERT}, `recent_edit` × {SELECT, INSERT}. No UPDATE or DELETE.
- **Acceptance:** Adversarial DELETE attempt returns permission denied.

### T6 — `/vault/<tenant>/` has restrictive permissions; no symlinks cross tenant boundaries

- **Definition:** Per-tenant vault directories are owned by ifos system user, mode 700 (or 750 for ifos_app group access). No symlink inside `/vault/<tenant>/` points to a path outside `/vault/<tenant>/`.
- **Enforcement:** Provisioning script (`scripts/provision-tenant.sh`, currently scattered in Day-4 §6.5) creates dirs with `chmod 700`. Renderer (`packages/agent-renderer/src/renderer.ts`) never writes symlinks into vault. The only symlink IFOS creates is at `${frameworkRoot}/orgs/<tenant>/agents/<agent>/.claude/hooks/_shared → ../../../_shared/` (Decision 2 of ADR-004) — that's the org-agents dir, NOT vault.
- **Documentation source:** Day-4 §6.5 + ADR-003 §3.3.3 + ADR-004 Decision 2.
- **Verification command:**
  ```bash
  # On VPS:
  stat -c '%a %U:%G %n' /vault/migration-test
  find /vault/migration-test -type l -exec readlink -f {} \; | grep -v '^/vault/migration-test'
  ```
  Expected: mode 700, owned by ifos user. Find returns no symlinks pointing outside.
- **Acceptance:** No cross-tenant symlinks; restrictive perms.

### T7 — Rendered agent dirs at `${frameworkRoot}/orgs/<tenant>/agents/` never cross-link

- **Definition:** Rendering agent X for tenant A and tenant B produces two physically separate directories with disjoint contents. No file in tenant-A's rendered dir references tenant-B's data.
- **Enforcement:** Renderer (`packages/agent-renderer/src/renderer.ts::render`) uses `ctx.orgAgentDir = ${frameworkRoot}/orgs/<tenant>/agents/<name>/` per-render. The `_shared/` symlink resolves via `../../../_shared/` which points to `<tenant>/agents/_shared/` (per-tenant, copied not shared).
- **Documentation source:** ADR-003 §3.3.3 Option γ + ADR-004 Decision 2 + ADR-004 Decision 3.
- **Verification command:**
  ```bash
  # After rendering agent X for both test-tenant-a and test-tenant-b:
  diff -r ${frameworkRoot}/orgs/test-tenant-a/agents/<X>/ ${frameworkRoot}/orgs/test-tenant-b/agents/<X>/ \
    | grep -E "tenant_slug|test-tenant-a|test-tenant-b"
  ```
  Expected: only `config.json` differs (different tenant_slug) and `.env` differs (different secrets); no cross-references.
- **Acceptance:** Tenancy audit Step T7 confirms disjoint render output.

### T8 — Rendered `_secrets.env` is `chmod 0600`

- **Definition:** The synthesised `.env` file written to each rendered agent's directory has filesystem mode 0600 (owner read-write only). Group + other have no access.
- **Enforcement:** Renderer (`packages/agent-renderer/src/renderer.ts::render`) calls `writeFileTracked(envPath, content, 0o600, ...)`.
- **Documentation source:** ADR-003 §2.1 row 3 + renderer source `packages/agent-renderer/src/renderer.ts` line ~150 (writeFileTracked call).
- **Verification command:**
  ```bash
  stat -c '%a' ${frameworkRoot}/orgs/<any-tenant>/agents/<any-agent>/.env
  ```
  Expected: `600`.
- **Acceptance:** Every rendered `.env` returns mode 600.

### T9 — Tenant slug pattern enforced (DNS-safe + Postgres role naming)

- **Definition:** Tenant slugs match `^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$` — lowercase alphanumeric + hyphen, 3-64 chars, no leading/trailing hyphen. Compatible with: (a) Postgres role naming for `ifos_tenant_<slug>`, (b) DNS subdomain rules, (c) URL slugs, (d) filesystem paths.
- **Enforcement:** `packages/agents-runtime/_shared/common-base.json` schema validates at provision time. Future provisioning script also validates via regex match before any side effects.
- **Documentation source:** `common-base.json` line 11 (`pattern` field on `tenant_slug` property).
- **Verification command:**
  ```bash
  python3 -c "import json, re; s=json.load(open('packages/agents-runtime/_shared/common-base.json')); print(s['properties']['tenant_slug']['pattern'])"
  ```
  Expected: `^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$`.
  Adversarial: provisioning attempts with `../etc/passwd`, `Tenant_With_Capitals`, `tenant with spaces` — all rejected.
- **Acceptance:** Schema validation rejects malformed slugs.

### T10 — Voice corpus `is_active=TRUE` enforced unique per tenant

- **Definition:** Each tenant has at most one active voice_corpus row. The `hh_load_voice_samples` helper queries `WHERE is_active=TRUE` and would return ambiguous results if two were active simultaneously.
- **Enforcement:** Partial unique index in v0.2 migration §2: `CREATE UNIQUE INDEX voice_corpus_one_active_per_tenant ON voice_corpus (tenant_slug) WHERE is_active=TRUE`. Postgres enforces — duplicate INSERT fails.
- **Documentation source:** `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` lines ~57-60.
- **Verification command:**
  ```sql
  SELECT indexname, indexdef FROM pg_indexes
  WHERE tablename='voice_corpus' AND indexname='voice_corpus_one_active_per_tenant';
  ```
  Expected: 1 row with partial UNIQUE on `tenant_slug WHERE is_active=true`.
  Adversarial: insert two `is_active=TRUE` rows for same tenant; second insert fails on unique constraint.
- **Acceptance:** Constraint exists + adversarial duplicate rejected.

### T11 — Cross-tenant RLS structurally blocks reads even when app code forgets the guard

- **Definition:** The most load-bearing invariant. Even if a developer forgets `SET LOCAL ifos.tenant_slug`, an app-level SELECT returns ZERO rows from another tenant's data. This is structural Postgres-level enforcement, not application-level.
- **Enforcement:** T2 (RLS enabled) + T3 (policy attached) + `current_setting('ifos.tenant_slug', TRUE)` returns NULL when unset; NULL never equals any non-null value; predicate returns false; row excluded.
- **Documentation source:** Day-4 §7 lines ~1080-1150 (RLS isolation gate, 5/5 conditions verified at provisioning).
- **Verification command:**
  ```sql
  -- Set wrong tenant + try to read another's data
  SET ifos.tenant_slug='not-the-real-tenant';
  SELECT count(*) FROM voice_corpus;            -- expect 0
  SELECT count(*) FROM decision_log WHERE agent_name='test-agent';  -- expect 0
  ```
  Expected: 0 rows from every cross-tenant read attempt.
- **Acceptance:** **VERIFIED Day-4 §7 (5/5 conditions).** Re-verified by tenancy audit Step T11 in this slice.

### T12 — `_shared/` helpers are tenant-agnostic (no hard-coded tenant slugs)

- **Definition:** Bash scripts and JSON schemas in `agents/_shared/` and `packages/agents-runtime/_shared/` never hard-code a specific tenant slug. All tenant references go through `CTX_TENANT_SLUG` environment variable set by the rendered agent's `context.sh`.
- **Enforcement:** Code review at render time (renderer pre-flight could check); manual code review of every `_shared/` change.
- **Documentation source:** ADR-003 §3.3.3 Option γ + `agents/_shared/README.md` §"Live mode vs fallback mode".
- **Verification command:**
  ```bash
  grep -rn "tenant_slug.*=.*['\"][a-z]" agents/_shared/ packages/agents-runtime/_shared/ \
    | grep -v "CTX_TENANT_SLUG\|tenant_slug=\|tenant_slug>" \
    | grep -v "test-tenant\|migration-test\|examples\|fallback"
  ```
  Expected: zero hits (or only intentional examples in comments).
- **Acceptance:** Audit grep returns clean. Examples in comments / test files exempted.

---

## §3 — Verification matrix

| Invariant | Status | Verified by | Last verified | Notes |
|---|---|---|---|---|
| T1 | Partial → Verified | Day-4 §7 schema-creation gate + tenancy audit | 2026-05-17 Day-4 (Day-4 tables); pending Day-9 (v0.2 tables + cross-validation) | All 9 tables expected to pass; v0.2 tables structurally identical pattern |
| T2 | Partial → Verified | Day-4 §7 RLS-enable check + tenancy audit | 2026-05-17 Day-4 (Day-4 tables); pending Day-9 (v0.2 + cross-validation) | Same |
| T3 | Partial → Verified | Day-4 §7 policy attach check + tenancy audit | Same as T2 | Same |
| T4 | **NOT verified** | Tenancy audit Step T4 (adversarial) | Pending Day-9 | This is the most likely place for a silent bug — app code that forgets the guard |
| T5 | Partial → Verified | Day-4 §6.3 GRANT inspection + tenancy audit | Day-4 §6.3 documented; pending adversarial in Day-9 | Decision_log + recent_edit confirmed |
| T6 | Partial → Verified | Day-4 §6.5 provisioning + tenancy audit | Day-4 docs; pending Day-9 verification | Per-tenant vault perms |
| T7 | Partial → Verified | ADR-003 §3.3.3 design + tenancy audit | ADR-003 + ADR-004 design; pending Day-9 functional test | Cross-tenant render isolation |
| T8 | Partial → Verified | Renderer source `renderer.ts` + tenancy audit | Phase 2 commit `3c16d35`; pending Day-9 functional verify | .env chmod 0600 |
| T9 | Partial → Verified | `common-base.json` schema + tenancy audit | Phase 1 commit `a279226` (schema); pending Day-9 adversarial | Slug pattern validation |
| T10 | Partial → Verified | v0.2 migration §2 partial unique index + tenancy audit | v0.2 migration design; pending Day-9 functional verify (post live migration) | Single-active voice corpus per tenant |
| T11 | **VERIFIED** | Day-4 §7 RLS isolation gate (5/5 conditions) + Phase 2 stress test | 2026-05-17 Day-4 | The only adversarially-verified invariant; foundation of the layered defence |
| T12 | Partial → Verified | grep audit + code review | Phase 1 + Phase 3 + Phase 5 commits; pending Day-9 audit grep | Tenant-agnostic helpers |

**Meta exception:** The `tenants` table has NO RLS by design — it's the tenant registry, must be visible to admin operations. All `tenants` writes are admin-only; `ifos_app` has SELECT-only on it (per Day-4 §6.3 line 704). This is documented as an explicit exception, not a violation.

---

## §4 — When invariants change

The 12 invariants above are the v1.0 set. Adding a new invariant (T13+) OR modifying an existing one requires:

1. **Surface in an ADR** — invariant changes are architectural decisions. Cannot edit this document inline; route through ADR-005+ and link.
2. **Migration coverage** — if a new invariant requires schema changes, ship migration SQL alongside the ADR.
3. **Audit coverage** — extend `scripts/run-tenancy-audit.sh` with the new test.
4. **Codex ratification** — invariant document is ratified via `review-architecture-decision.md` skill; updates re-ratify.
5. **Update RISK-REGISTER if applicable** — new invariant often surfaces a risk it's mitigating; document explicitly.

The full provenance trail: ADR → tenancy-invariants.md update → migration SQL (if needed) → audit script update → Codex ratification → backlog closure.

---

## §5 — Where this document is enforced

- **Pre-render**: ADR-003 §3.3.3 Option γ + ADR-004 Decision 2 + Decision 3 enforce T6, T7, T8 at render time.
- **Pre-migration**: Day-4 §6.5 provision-tenant workflow + v0.1-to-v0.2.sql migration enforce T1, T2, T3, T5, T9, T10 at schema creation.
- **At every agent runtime write**: hook-helpers.sh + voice-loader.sh enforce T4 via `SET LOCAL ifos.tenant_slug` pattern; relies on T11 (Postgres RLS) as the structural backstop.
- **At every code review**: `_shared/` changes audited for T12 hard-coded slug introduction.
- **At every tenancy audit run**: `scripts/run-tenancy-audit.sh` (companion artefact) verifies T1-T12 against live VPS.

This document is the **single source of truth**. ADRs, runbooks, and code comments reference it; the inverse — this document references them — completes the round-trip.

---

## §6 — Open questions surfaced during invariant consolidation

| # | Question | Trigger to resolve |
|---|---|---|
| Q1 | Should T4 be promoted to structural via stored-procedure wrappers (so app code physically cannot INSERT without `SET LOCAL`)? | If Day-9 tenancy audit reveals an app-code path forgot the guard, AND the cost of T11 catching the leak is unacceptable (e.g., partial writes). |
| Q2 | Should `tenants` meta table have an `enabled` boolean (vs `status` enum) to enable structural disable-without-delete? | If first tenant offboards and we discover row deletion is destructive to audit trail. Founder Decision D3 from Codex Round 1 may resolve. |
| Q3 | Should `ifos_app` role be split into per-vertical roles (e.g., `ifos_app_recruitment`) to limit blast radius if `ifos_app` credentials leak? | If pilot reveals broader-than-recruitment workload that warrants role split. v1.1+ concern. |
| Q4 | What is the test pattern for verifying T4 at code-review time (vs runtime audit)? | If Day-9 audit reveals false-negatives — code-review-style grep checks would be more reliable. |
| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |

---

## §7 — Status

**Reference (In Force on tenant-data write paths).** Codex ratification queue item #35; ratified via `.codex/ratification/review-architecture-decision.md`. Companion audit script at `scripts/run-tenancy-audit.sh` ratified as item #38. Both queued for Codex Round 3 after this commit ships.

*End of tenancy-invariants.md.*
