# PII purge — operational pattern

**Status:** Proposed (pending Founder Decision D3 final retention period + D2 external advisor input)
**Date:** 2026-05-22
**Authority:** Surfaces UK GDPR Art. 5(1)(e) data-minimisation compliance for `recent_edit` text fields. Companion to `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D3 + Risk #10 in `docs/RISK-REGISTER.md`.
**Companion artefacts:**
- `scripts/ifos-pii-purge.sh` — cron implementation (shellcheck clean)
- `docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql` — schema addition (text_purged_at audit column)
- `docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql` — rollback

---

## §1 — Why this pattern exists

`recent_edit` rows store the agent's draft (`original_text`) and the consultant's edited version (`edited_text`) verbatim, length-capped at 8192 chars per field. Per v0.2 supplement §1, these can contain PII (candidate names, salaries, contact info).

UK GDPR Art. 5(1)(e) (data minimisation) requires that personal data be "kept in a form which permits identification of data subjects for no longer than is necessary for the purposes for which the personal data are processed."

**For IFOS:**

- **Purpose 1: Operator review** of agent drafts — needs the text only during the review window (typically minutes to hours, max ~4h timeout).
- **Purpose 2: Voice drift detection** — needs aggregated metadata (`edit_distance`, `tone_rules_triggered`, `resolution`) not the raw text.
- **Purpose 3: v2.0 LoRA SFT corpus** — needs PAIRS of (draft, edit) for training. Indefinitely useful, BUT could be argued GDPR-compliant via either (a) explicit consent in pilot TOS, (b) pseudonymisation before training, or (c) bounded retention sufficient for one training cycle.

**The operational pattern:** purge text fields after a defined retention window; preserve metadata indefinitely.

---

## §2 — Default retention window

**Proposed v1.0 default: 90 days, pending D2/D3 advisor confirmation.** This runbook is written for the recommended D3-B path, but D3 has not been confirmed by the founder and D2 SeedLegals/external-advisor input is still required. Recommend NOT shorter than 30 days (review-cycle floor) and NOT longer than 180 days (GDPR-compliance ceiling for un-consented retention).

Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.

---

## §3 — Schema state

`recent_edit` table extended via `v0.2-to-v0.3-pii-purge.sql`:

```sql
ALTER TABLE recent_edit
  ADD COLUMN text_purged_at TIMESTAMPTZ;  -- NULL = text fields still present
                                          -- NOT NULL = text NULLed at this timestamp

-- Defence-in-depth: if purged, both text fields MUST be NULL
ALTER TABLE recent_edit ADD CONSTRAINT recent_edit_text_purged_consistency CHECK (
  text_purged_at IS NULL
  OR (original_text IS NULL AND edited_text IS NULL)
);
```

Audit semantics: rows with `text_purged_at IS NOT NULL` are "purged" — text bodies redacted, metadata retained.

---

## §4 — Cron deployment

### Production (on VPS)

Script lives at `/usr/local/bin/ifos-pii-purge.sh` (symlinked from `scripts/ifos-pii-purge.sh` in the IFOS repo).

```bash
# Cron config: /etc/cron.daily/ifos-pii-purge
#!/usr/bin/env bash
sudo -u ifos_user /usr/local/bin/ifos-pii-purge.sh \
  --retention-days 90 \
  >> /var/log/ifos/pii-purge.log 2>&1
```

Daily at 02:00 UTC (after backups complete, before tenant activity peaks). Single run per day; idempotent (only NULLs rows where text is still present).

### Local testing

Founder can test against migration-test tenant via:

```bash
# From repo root
SSH_MODE=1 bash scripts/ifos-pii-purge.sh --dry-run --retention-days 90
```

Prompts for `ifos_app` password (Path A); opens SSH tunnel; reports what WOULD be purged. No writes.

For live execution against test tenant:

```bash
SSH_MODE=1 bash scripts/ifos-pii-purge.sh --retention-days 90
# (omit --dry-run)
```

---

## §5 — What the cron does

1. Queries `tenants` table for active + suspended tenants
2. Per tenant, sets `SET app.current_tenant='<tenant>'` (T4 invariant)
3. SELECTs count(*) from `recent_edit` WHERE `resolved_at < now() - interval '<N> days' AND original_text IS NOT NULL`
4. If dry-run: reports counts, exits
5. Otherwise: UPDATE setting `original_text = NULL`, `edited_text = NULL`, `text_purged_at = now()`
6. Audit row to `decision_log`: `agent_name='_pii_purger'`, `phase='gating_failed'`, `outcome='purged'`, payload has `rows_purged` + `tenants_touched` + `retention_days` + invocation_time

---

## §6 — What survives the purge

| Field | Pre-purge | Post-purge |
|---|---|---|
| `original_text` | populated | NULL |
| `edited_text` | populated OR NULL | NULL |
| `edit_distance` | populated | populated (preserved) |
| `resolution` | populated | populated (preserved) |
| `tone_rules_triggered` | populated | populated (preserved) |
| `action_type` | populated | populated (preserved) |
| `agent_name` | populated | populated (preserved) |
| `resolved_at` | populated | populated (preserved) |
| `tenant_slug` | populated | populated (preserved) |
| `text_purged_at` | NULL | NOW() |

**The metadata fields are sufficient for:**

- Voice-drift detection nightly cron (operates on `edit_distance` + `tone_rules_triggered` + `resolution`)
- v2.0 LoRA SFT corpus (after operator consent + retention amendment, OR via separate consented corpus collection process)
- Audit queries ("how often did Concierge's drafts get edited vs approved?")

**What's lost after purge:**

- The exact text of the draft + edit
- LoRA training pair regeneration (requires the text)

---

## §7 — Tenant-controlled retention (D3-C compatibility)

Per-tenant override via `tenant_adapters.config.pii_retention_days`:

```sql
INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
VALUES (
  'acme-recruitment',
  'pii_retention',
  '{"pii_retention_days": 180}'::jsonb,
  TRUE
)
ON CONFLICT (tenant_slug, adapter_name) DO UPDATE SET config = EXCLUDED.config;
```

Value range: [30, 365]. Cron reads override per tenant before computing the cut-off.

**Implementation note:** `scripts/ifos-pii-purge.sh` v0.1 uses a single `--retention-days` CLI arg for all tenants. Per-tenant override support is a Phase-2 cron enhancement (lands when first tenant requests extended retention; founder TOS amendment + advisor input on the requested duration).

---

## §8 — Failure modes

| Failure | Cron behaviour | Recovery |
|---|---|---|
| Postgres unreachable at cron-time | exit code 1; cron log captures the connection error; next-day retry | Manual investigation + ssh-tunnel test |
| Mid-purge connection loss | Transaction rollback (BEGIN…COMMIT block — though we use single UPDATE so no explicit BEGIN); partial purge unlikely with single statement | Re-run next cycle; rows partially purged stay partially purged with timestamps |
| Disk full during audit row write | UPDATE succeeds; audit row write fails; orphaned purge | Decision_log fallback to JSONL at `/var/log/ifos/decision-log.jsonl`; replay via autosend-syncer when disk recovers |
| Cron not running (systemd cron disabled) | No purge for days; PII accumulates | Monitor: weekly query for "oldest non-purged row resolved_at" > retention window indicates broken cron |
| Wrong retention configured | Over-aggressive purge: text NULLed prematurely; data lost | Pre-migration backup + dry-run mandatory before any retention reduction |

---

## §9 — Monitoring + alerting

Weekly health check (recommend a Brain UI v1.1 widget OR ad-hoc query):

```sql
-- Should be 0 if cron is healthy
SELECT count(*) FROM recent_edit
WHERE original_text IS NOT NULL
  AND resolved_at < now() - interval '95 days';  -- 5-day grace
```

If > 0, the cron has been silent for ≥ 5 days. Investigate.

Also useful:

```sql
-- Verify daily purge volume (should match expected tenant activity)
SELECT date_trunc('day', created_at) AS purge_day,
       payload->>'rows_purged' AS rows,
       payload->>'tenants_touched' AS tenants
FROM decision_log
WHERE agent_name = '_pii_purger'
ORDER BY created_at DESC
LIMIT 30;
```

---

## §10 — Open implementation gaps

| # | Gap | Trigger |
|---|---|---|
| P1 | Cron not yet deployed to VPS | After D3 + D2 advisor confirm retention window |
| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
| P3 | Brain UI v1.1 widget for "rows beyond retention" visibility | Brain UI W11 build |
| P4 | Backup snapshot before purge (defence-in-depth) | Production deployment + first pilot |
| P5 | Per-jurisdiction retention enforcement (EU GDPR vs UK DPA vs US) | First non-UK tenant (v1.1+ international) |

P1 + P4 are pre-production blockers. P2 + P3 + P5 are v1.1+.

---

## §11 — Pre-deployment checklist

Before applying the migration or running the first cron in production:

- [ ] D2 SeedLegals advisor input received BEFORE applying migration
- [ ] D3 founder confirmation received BEFORE first cron run
- [ ] D3 final retention period confirmed by D2 SeedLegals advisor
- [ ] `v0.2-to-v0.3-pii-purge.sql` migration applied to live VPS (adds `text_purged_at` column + constraint)
- [ ] `scripts/ifos-pii-purge.sh` symlinked to `/usr/local/bin/ifos-pii-purge.sh`
- [ ] Cron entry deployed: `/etc/cron.daily/ifos-pii-purge`
- [ ] Test dry-run executes clean (with current tenant data; reports 0 rows expected unless tenants have history > 90 days)
- [ ] Backup snapshot strategy in place (Hetzner volume snapshot weekly)
- [ ] Decision_log audit row format verified via test run
- [ ] Risk #10 status updated in RISK-REGISTER

---

## §12 — Status

**Proposed.** Pending:
- Founder Decision D3 final retention period confirmation (currently 90 days default)
- D2 SeedLegals advisor input on whether 90 days is the right floor
- Live migration (`v0.2-to-v0.3-pii-purge.sql` execution)
- Cron deployment to VPS

When all four resolve: Risk #10 status flips to "mitigated"; UK GDPR Art. 5(1)(e) compliance posture documented; pilot LOI block lifts on PII grounds.

Codex Day-7 manifest queue position: TBD (~#41 when filed). Ratifies via `review-architecture-decision.md` skill (In Force status; D5 softening applies).

*End of operational pattern.*
