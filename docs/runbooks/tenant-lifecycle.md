# Tenant lifecycle — runbook

**Status:** In Force
**Date:** 2026-05-20 (Day 9 — pre-Diagnostic-build foundation)
**Authority:** Consolidates Day-4 §6.5 provisioning + tenancy-invariants.md + ADR-002 + ADR-003 + v0.2 supplement.
**Companion:** `docs/architecture/tenancy-invariants.md` (the 12 invariants every state must preserve).

---

## §1 — Lifecycle states

```
                                  ┌─────────────┐
                                  │ Provisioned │
                                  └──────┬──────┘
                                         │ first agent rendered
                                  ┌──────▼──────┐
                       ┌──────────►   Active    ├──────────┐
                       │          └──────┬──────┘          │
                       │                 │                 │
                       │   schema        │  tenant pauses  │
                       │   migration     │  operations     │
                       │                 │                 │
                       │          ┌──────▼──────┐          │
                       │          │  Suspended  │          │
                       │          └──────┬──────┘          │
                       │                 │ resume          │
                       │                 │                 │
                       └─────────────────┘                 │
                                                           │
                                                ┌──────────▼──────────┐
                                                │     Offboarded      │
                                                │  (90-day legal hold │
                                                │   then purge)       │
                                                └─────────────────────┘
```

Four states + one self-loop (Migrate). Every state transition preserves the 12 tenancy invariants from `tenancy-invariants.md`.

---

## §2 — Provisioned (new tenant onboarding)

### Trigger
- Pilot LOI signed by tenant + counter-signed by founder
- Manual founder action to begin provisioning

### Inputs needed
| Field | Source | Notes |
|---|---|---|
| `tenant_slug` | Onboarding form | Pattern: `^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$` (T9) |
| `legal_name` | Onboarding form | Full UK legal entity name |
| `primary_contact` | Onboarding form | Name + email + phone + role |
| `tier` | Pricing decision | solo | boutique | growth | scale |
| `deployment_preference` | Pricing | sovereign | cloud (v1.0 default cloud) |
| `operating_window` | Onboarding | 24/7 | business-hours | out-of-hours |
| `ATS choice` | Onboarding | bullhorn (v1.0 only) |
| `Bullhorn tenant corp_id` | From tenant's Bullhorn admin | Per `common-ats.json` |
| `Telegram operator chat_id` | Setup call | Per `common-notifications.json` |
| `Voice corpus seed docs` | Setup call upload | Operator-curated examples + recent consultant drafts |

### Workflow

```bash
# Step 1: Validate slug pattern (T9 invariant)
SLUG="<slug-from-onboarding>"
PATTERN="^[a-z0-9][a-z0-9-]{1,62}[a-z0-9]$"
[[ "${SLUG}" =~ ${PATTERN} ]] || { echo "INVALID SLUG"; exit 1; }

# Step 2: Insert into tenants registry
psql -c "INSERT INTO tenants (tenant_slug, tenant_name, metadata)
  VALUES ('${SLUG}', '<legal_name>', '{\"status\":\"provisioning\",\"tier\":\"<tier>\",\"provisioned_at\":\"$(date -u +%FT%TZ)\"}'::jsonb);"

# Step 3: Create per-tenant Postgres role (RLS-enforced)
psql -c "CREATE ROLE ifos_tenant_${SLUG} NOINHERIT NOLOGIN;
  GRANT ifos_tenant_${SLUG} TO ifos_app;"

# Step 4: Provision /vault/<slug>/ structure (T6 invariant)
ssh maddox@${VPS_HOST} "sudo -u ifos_user bash -s" <<EOF
mkdir -p /vault/${SLUG}/{_voice,_config,_brand,_playbooks,spot-checks,pending-approvals,wiki/raw}
chmod 700 /vault/${SLUG}
EOF

# Step 5: Generate _secrets.env (Path D — credentials NEVER enter chat)
ssh maddox@${VPS_HOST} "sudo -u ifos_user bash -s" <<EOF
cat > /vault/${SLUG}/_secrets.env <<INNER
BULLHORN_OAUTH_TOKEN=<provided-by-tenant>
TELEGRAM_BOT_TOKEN=<provided>
TELEGRAM_CHAT_ID=<provided>
TELEGRAM_ALLOWED_USER=<provided>
INNER
chmod 600 /vault/${SLUG}/_secrets.env
EOF

# Step 6: Seed _config.yaml
ssh maddox@${VPS_HOST} "sudo -u ifos_user tee /vault/${SLUG}/_config.yaml" <<EOF
tenant_slug: ${SLUG}
tenant_legal_name: "<legal_name>"
operating_window: <window>
tier: <tier>
voice_threshold: 0.75
EOF

# Step 7: Seed initial voice corpus row (empty — operator uploads docs separately)
psql -c "SET ifos.tenant_slug='${SLUG}';
  INSERT INTO voice_corpus (tenant_slug, version, source_doc_count, source_doc_origin,
    chunk_count, chunking_strategy, embedding_model, last_indexed_at, is_active)
  VALUES ('${SLUG}', 'v0.1-seed', 0, '{}', 0, 'paragraph',
    'text-embedding-3-small', now(), TRUE);"

# Step 8: Render each active v1.0 agent for this tenant (when fleet ships)
for agent in diagnostic; do
  ifos-render-agent render ${agent} --tenant ${SLUG}
done

# Step 9: Verify provisioning via tenancy audit
bash scripts/run-tenancy-audit.sh
# Expect: all 12 invariants pass; new tenant appears in T1-T3 enumerations

# Step 10: Activate (when agent fleet ready to run)
cortextos-ifos start --tenant ${SLUG}

# Step 11: Update tenants.metadata.status to "active"
psql -c "UPDATE tenants SET metadata = metadata || '{\"status\":\"active\",\"activated_at\":\"$(date -u +%FT%TZ)\"}'::jsonb WHERE tenant_slug='${SLUG}';"
```

### Acceptance

- New tenant passes all 12 tenancy invariants per `bash scripts/run-tenancy-audit.sh`
- `tenants` row exists with `metadata.status='active'`
- `/vault/<slug>/` exists with mode 700 + `_secrets.env` chmod 600
- Each rendered agent's `.env` chmod 600 (T8 invariant)
- Initial voice_corpus row with `is_active=TRUE` (T10 invariant)
- `cortextos-ifos list-agents` shows the tenant's agents

### Reference scripts

**TODO**: Currently the provisioning steps are documented here but no single `scripts/provision-tenant.sh` exists — the workflow is reconstructable from Day-4 §6.5. Recommend writing `scripts/provision-tenant.sh` when first real tenant LOI signs (lazy implementation OK; one-shot manual run is acceptable for first 1-2 pilots).

---

## §3 — Active (operating)

### Day-to-day operations

| Activity | Workflow | Invariant preserved |
|---|---|---|
| Agent draft + approve via Telegram | `hh_decision_action` writes to decision_log; orange-tier blocks on Telegram approval | T4 (every write sets SET LOCAL) |
| Voice corpus re-index | Operator uploads new docs to `/vault/<slug>/_voice/`; `ifosctl reindex-voice --tenant <slug>` runs ingest pipeline + flips `is_active` atomically | T10 (single-active per tenant) |
| Tone rule add/edit | Tenant operator edits `/vault/<slug>/_voice/tone-rules.yaml` OR Brain UI v1.1; sync to Postgres `tone_rule` table | T1-T3 (RLS isolation) |
| Bullhorn OAuth refresh | Per-agent 8-min cycle per `bullhorn-integration-path.md` §4.5; ESC_BULLHORN_AUTH on failure | (No invariant violation; runtime concern) |
| Agent edit + re-render | Edit `agents/recruitment/<name>/agent.md` in repo; merge; run `ifos-render-agent render <name> --tenant <slug>`; `cortextos-ifos bus self-restart <name>` | T7 (rendered dirs isolated) |
| Spot-check operator review | `autosend_spot_check_enqueue` writes to `/vault/<slug>/spot-checks/<file>.md`; operator reviews + flags as approved/rejected/escalate | (No invariant violation) |

### Edit propagation

**Editing the source bundle** at `agents/recruitment/<name>/` requires re-render for every active tenant using that agent:

```bash
for tenant in $(psql -t -c "SELECT tenant_slug FROM tenants WHERE metadata->>'status'='active';"); do
  ifos-render-agent render <name> --tenant "${tenant}"
  cortextos-ifos bus self-restart <name>  # picks up new render
done
```

**v1.1+ ergonomic improvement (per ADR-005 when filed):** `ifos-render-agent render <name> --all-tenants` does this in one command.

### When to invoke `pm2 restart` vs `cortextos-ifos bus self-restart`

- **New agent** (first time PM2 sees it): `pm2 restart ifos-daemon` reloads agent list + spawns PTYs
- **Existing agent re-render** (config or .env changed): `cortextos-ifos bus self-restart <name>` is the surgical reload — picks up new config.json + .env without restarting peer agents

Per ADR-003 §"Master brief edits authorised" Edit B (post-ADR-004 corrected to `ifos-render-agent`).

---

## §4 — Suspended (tenant pause)

### Trigger
- Tenant requests temporary pause (billing freeze, holiday, restructuring)
- Founder pauses unilaterally for compliance investigation

### Workflow

```bash
# Stop all agents for this tenant
cortextos-ifos stop --tenant <slug>

# Update status
psql -c "UPDATE tenants SET metadata = metadata || '{\"status\":\"suspended\",\"suspended_at\":\"$(date -u +%FT%TZ)\",\"suspended_reason\":\"<reason>\"}'::jsonb WHERE tenant_slug='<slug>';"
```

### Data preserved
- All Postgres rows remain (RLS-isolated)
- `/vault/<slug>/` untouched
- Rendered agent dirs preserved (`${frameworkRoot}/orgs/<slug>/`)
- PM2 processes stopped but ecosystem config retained

### Resume
- `cortextos-ifos start --tenant <slug>` re-spawns agents
- `psql -c "UPDATE tenants SET metadata = ... 'status':'active' ..."`
- Verify via `bash scripts/run-tenancy-audit.sh`

### Acceptance
- No data lost during suspend
- Post-resume tenancy audit passes
- Decision_log shows audit row with `agent_name='_tenant_admin'`, `phase='trigger'`, `payload.action='suspend|resume'`

---

## §5 — Offboarded (tenant churns)

### Trigger
- Tenant cancels subscription
- Founder offboards for compliance violation
- Pilot conversion declined post-pilot-window

### 90-day legal hold

Per UK GDPR Art. 17 (Right to erasure) + Art. 5(1)(e) (data minimisation), tenant data may be:
- **Erased on request** within 30 days
- **Retained up to 90 days** for legal/billing purposes
- **Anonymised + retained indefinitely** for SFT corpus (Founder Decision D3 dependency)

**v1.0 default:** 90-day legal hold + tenant-controlled retention beyond.

### Workflow

```bash
# Step 1: Stop all agents
cortextos-ifos stop --tenant <slug>

# Step 2: Mark status; record offboard timestamp
psql -c "UPDATE tenants SET metadata = metadata || '{
  \"status\":\"offboarded\",
  \"offboarded_at\":\"$(date -u +%FT%TZ)\",
  \"legal_hold_expires\":\"$(date -u -v+90d +%FT%TZ)\"
}'::jsonb WHERE tenant_slug='<slug>';"

# Step 3: Snapshot for legal hold
ssh maddox@${VPS_HOST} "sudo -u ifos_user tar -czf /backup/tenant-snapshots/<slug>-$(date +%Y%m%d).tar.gz /vault/<slug>"

# Step 4: Post-legal-hold purge (90 days later — scheduled cron OR manual)
# WARNING: this is destructive
psql -c "SET ifos.tenant_slug='<slug>';
  DELETE FROM recent_edit       WHERE tenant_slug='<slug>';
  DELETE FROM voice_corpus_chunks WHERE tenant_slug='<slug>';
  DELETE FROM voice_corpus      WHERE tenant_slug='<slug>';
  DELETE FROM tone_rule         WHERE tenant_slug='<slug>';
  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
  DELETE FROM tenant_eval_sets  WHERE tenant_slug='<slug>';
  DELETE FROM decision_log      WHERE tenant_slug='<slug>';
  DELETE FROM entity_links      WHERE tenant_slug='<slug>';
  DELETE FROM entities          WHERE tenant_slug='<slug>';"
# decision_log + recent_edit are append-only — DELETE requires running as superuser (admin operation)

# Step 5: Drop Postgres role
psql -c "REVOKE ifos_tenant_<slug> FROM ifos_app; DROP ROLE ifos_tenant_<slug>;"

# Step 6: Remove vault + rendered dirs
ssh maddox@${VPS_HOST} "sudo -u ifos_user bash -c 'rm -rf /vault/<slug> ${CTX_ROOT}/orgs/<slug>'"

# Step 7: Update tenants registry
psql -c "UPDATE tenants SET metadata = metadata || '{
  \"status\":\"purged\",
  \"purged_at\":\"$(date -u +%FT%TZ)\"
}'::jsonb WHERE tenant_slug='<slug>';"
```

### Acceptance
- Post-purge tenancy audit confirms no orphan rows for `<slug>` in any tenant-data table
- `/vault/<slug>/` removed; rendered org dirs removed
- Tenant slug freed for future reuse (after 12-month cooling period to avoid confusion with legacy data — recommended, not enforced)
- Audit row in decision_log: `agent_name='_tenant_admin'`, `phase='gating_failed'`, `payload.action='tenant_purged'`, `payload.tenant_slug=<slug>` (written PRE-DELETE so the audit row survives)

### Open implementation gap
**No `scripts/offboard-tenant.sh` exists.** Workflow above is the runbook spec. Script written when first tenant churns. **Risk:** if first churn happens without script, ad-hoc workflow risks omitting steps. Acceptable for v1.0 (low probability in pilot phase); v1.1+ adds the script.

---

## §6 — Migrate (vertical-schema version upgrade)

### Trigger
- Vertical-schema vN.M → vN.M+1 (e.g., v0.2 → v0.3)
- Day-4 §6.3 generic-primitive schema additions (new table, new column)
- Critical bugfix migration

### Workflow

```bash
# Step 1: Test migration on migration-test tenant first
bash scripts/run-live-migration.sh  # with the new vN.M-to-vN.M+1.sql
bash scripts/run-tenancy-audit.sh   # verify all 12 invariants still hold

# Step 2: Schedule maintenance window per tenant SLA (typically <30 min downtime)
# Notify tenants 48h ahead

# Step 3: Apply migration to all active tenants inside transaction
for tenant in $(psql -t -c "SELECT tenant_slug FROM tenants WHERE metadata->>'status'='active';"); do
  echo "Migrating ${tenant}..."
  psql -v ON_ERROR_STOP=1 -v tenant_slug="${tenant}" -f migrations/vN.M-to-vN.M+1.sql
done

# Step 4: Re-render all active agents (so they pick up new fields)
for tenant in $(...); do
  for agent in $(cortextos-ifos list-agents --tenant ${tenant} --names-only); do
    ifos-render-agent render ${agent} --tenant ${tenant}
  done
done

# Step 5: Restart agents
cortextos-ifos restart --all

# Step 6: Tenancy audit per tenant
for tenant in $(...); do
  bash scripts/run-tenancy-audit.sh --tenant ${tenant}  # not yet implemented — currently runs against migration-test
done

# Step 7: Rollback path if any step fails
psql -f migrations/vN.M+1-to-vN.M.sql  # the companion rollback SQL
```

### Acceptance
- Migration SQL applies cleanly against test tenant first
- All active tenants migrate successfully OR rollback cleanly
- Post-migration tenancy audit passes for every tenant
- Agents resume normal operation within maintenance window

### Open implementation gap
**Migration runner currently only handles `migration-test` tenant.** Multi-tenant migration loop is the script extension at v1.1+. v1.0 with 1-2 pilot tenants can run the loop manually.

---

## §7 — Cross-state invariants

Regardless of state transition, the 12 tenancy invariants from `docs/architecture/tenancy-invariants.md` MUST hold:

- **T1-T3**: every tenant-data table has tenant_slug + RLS + policy (structural; can't be transiently violated)
- **T4**: any write path must set `SET LOCAL ifos.tenant_slug` first (runtime invariant; enforced by helpers)
- **T5**: append-only tables remain append-only (offboarding's DELETE requires admin role + audit-log row pre-DELETE)
- **T6-T8**: vault perms + render isolation + .env chmod survive state transitions
- **T9**: tenant_slug regex enforced on Provisioned (entry gate)
- **T10**: voice_corpus is_active=TRUE single-per-tenant (Migrate transition needs atomic flip)
- **T11**: cross-tenant RLS block (structural; permanent)
- **T12**: `_shared/` helpers tenant-agnostic (compile-time invariant; not state-dependent)

### Atomic-flip invariants

Some state transitions require atomic updates to preserve invariants:

- **Voice corpus re-index** (Active sub-state): new `voice_corpus` row inserted with `is_active=TRUE`; old row updated to `is_active=FALSE` in same transaction. Partial unique index (T10) enforces no two `is_active=TRUE` rows simultaneously.
- **Migrate**: per-tenant migration applied inside `BEGIN...COMMIT` block.
- **Provisioned → Active**: `tenants.metadata.status` flip is a single UPDATE.

### Audit row requirements

Every state transition writes to decision_log:

```sql
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, payload, created_at)
VALUES (
  '<slug>',
  '_tenant_admin',  -- sentinel agent name (see master brief §8.1 Change 2 + tenancy-invariants.md)
  '<phase>',         -- 'trigger' for state-entry; 'gating_failed' for offboard-purge
  '<outcome>',       -- 'provisioned' | 'activated' | 'suspended' | 'resumed' | 'offboarded' | 'purged' | 'migrated'
  jsonb_build_object(
    'action', '<action_name>',
    'previous_state', '<previous>',
    'new_state', '<new>',
    'operator', '<who-triggered>'
  ),
  now()
);
```

For **offboard-purge specifically**: the audit row is written BEFORE the DELETE statements so it survives in the audit trail.

---

## §8 — Open implementation gaps

| # | Gap | Severity | Resolution path | Trigger |
|---|---|---|---|---|
| L1 | `scripts/provision-tenant.sh` doesn't exist | Medium | Written at first real tenant LOI; v1.0 manual workflow acceptable | First pilot LOI signed |
| L2 | `scripts/offboard-tenant.sh` doesn't exist | Low | Written at first churn; manual workflow acceptable for first 1-2 pilots | First tenant offboards |
| L3 | `scripts/run-tenancy-audit.sh --tenant <slug>` arg not implemented (currently audits only migration-test) | Medium | Phase 2 extension OR v1.1+ multi-tenant audit | Multi-tenant pilot OR Codex Round-3 |
| L4 | Re-render automation `ifos-render-agent render --all-tenants` | Low | ADR-005 at v1.1+ multi-tenant operations | Second active tenant onboarded |
| L5 | Brain UI v1.1 tenant-admin UI for status changes | Medium | Brain UI W11-13 build slice | Week 11 |
| L6 | Migration runner multi-tenant loop in production | Medium | v1.1+ migration tooling | First schema migration with active tenants |
| L7 | 90-day purge cron (currently manual) | Low | Automation at v1.1+ when offboarding becomes routine | First offboarding cycle complete |
| L8 | Voice corpus re-index ergonomic command (currently manual SQL + ingest) | Medium | `ifosctl reindex-voice --tenant <slug>` v1.1+ | First tenant requests re-index |

**All 8 gaps tracked with named trigger.** v1.0 single-tenant pilot doesn't blocking on any.

---

## §9 — Status

**In Force** for runbook procedures. **Codex Day-7 manifest queue item #37**; ratifies via `review-architecture-decision.md` skill (with Founder Decision D5 softening for runbook artefacts).

Companion to:
- `docs/architecture/tenancy-invariants.md` (the 12 invariants every state preserves)
- `docs/architecture/architecture-cohesion-review.md` (boundary audit + gap surfacing)
- `scripts/run-tenancy-audit.sh` (verification harness)
- `scripts/run-live-migration.sh` (live-VPS migration wrapper)

*End of tenant-lifecycle.md.*
