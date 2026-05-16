# Vault concurrency — reference

**Status:** Reference (no Proposed/Accepted lifecycle). Synthesis of `docs/architecture/second-brain-design.md` §2.6 + `docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md` Decisions 2-3 + `docs/decisions/sequencing-target.md` §5-A `decision_log.phase` extension.
**Date:** 2026-05-17 (Week 0, Day 3 evening — Week-1 prerequisite #2)
**Author:** Claude Code
**Surfaced by:** `ADR-002` §"For Week 1 work" + `second-brain-design.md` Spec gap 2.6 + `sequencing-target.md` §6.5 (Day-4 Postgres provisioning consolidation).
**Submodule SHA referenced:** `c21fbfe991a0030ea055bd8e2389a0801a424383`

**Reading order:** `second-brain-design.md` §2.6 (concurrency mechanism scoping) first; then this document; then the implementation work in `packages/brain/wiki/lib/concurrency.ts` in Week 1-2 references this document as its specification.

**Purpose:** before `wiki/lib/concurrency.ts` is reviewable, the four concurrency mechanisms need formal specification with worked examples, lock-ordering rules, and escalation taxonomy. This document is that specification.

---

## Section 1 — Scope and context

The IFOS wiki at `/vault/<tenant-slug>/wiki/` is read and written by **multiple concurrent actors** per `second-brain-design.md` §2.4.5 storage decision diagram:

- **Founder via Obsidian** — writes `_voice/`, `_playbooks/`, `_decisions/`, free-form `## Notes` sections of any compiled entity (§2.4.1).
- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
- **Wiki library** (`packages/brain/wiki/lib/*.ts` per ADR-002 Decision 2) — the read/write API every agent invokes; serialises and coordinates the above.

Without explicit concurrency mechanisms, four failure modes are observable:

1. **Lost-write race.** Two agents read the same entity at version N, both compute version N+1, both write — last writer wins, first agent's changes silently lost.
2. **Read-during-partial-write.** Reader observes a half-written file mid-rename — markdown parser fails or, worse, succeeds and reads broken frontmatter.
3. **Human edit clobbered.** Founder edits a Candidate's `## Notes` in Obsidian; agent rewrites the same file's `<!-- auto:lifecycle -->` block 200ms later; founder's edit is lost or merged incorrectly.
4. **Rename cascade incoherent.** Candidate `sarah_bowen` renamed to `sarah_bowen_smith` requires updating all backlinks (entities that wiki-link to her); partial cascade leaves the wiki internally inconsistent.

Four mechanisms address these four failure modes in §2-§5. **All four mechanisms must be implemented in `wiki/lib/concurrency.ts`** for the wiki API to ship in v1.0 weeks 11-13 per `sequencing-target.md` §4.1 row 6 (Concierge, the heaviest concurrency stressor).

**What this document does not cover:**

- Disaster recovery (Postgres-rebuild-from-filesystem scan) — `second-brain-design.md` §2.5 fallback paths handle this; reconciliation runs are out of hot-path scope.
- Multi-tenant filesystem isolation — kernel-enforced per Ultraplan §5.1 line 220 (`ifos-tenant-{slug}` OS user); not a concurrency concern within a tenant.
- Cross-tenant read consistency — RLS handles this at the Postgres layer per ADR-002 Decision 3; not a wiki-library concern.

---

## Section 2 — Mechanism 1: `flock(2)` per-entity lock

**Purpose:** prevent lost-write races and read-during-partial-write at the filesystem level.

**Substrate:** POSIX advisory locking via the `flock(2)` syscall on a per-entity lock file.

### 2.1 — Lock file path

`/vault/<tenant-slug>/wiki/compiled/<entity_type>/<slug>.lock`

For example, locking the Sarah Bowen Candidate page in tenant `acme`:
`/vault/acme/wiki/compiled/candidates/sarah_bowen.lock`

The lock file is created on first acquisition and never deleted (kernel-released on process exit; deletion would race other holders).

### 2.2 — Lock semantics

- **Exclusive lock** (`LOCK_EX`) — every wiki-lib operation that reads-modify-writes a file acquires exclusive.
- **Shared lock** (`LOCK_SH`) — pure-read operations (e.g. `wiki-get`) acquire shared. Allows multiple concurrent readers; blocks writers.
- **Non-blocking attempt** (`LOCK_NB`) — used in cascade contexts (§5) where polling makes sense.
- **Timeout** — 5 seconds default (`OP_LOCK_TIMEOUT_S = 5`). If acquisition fails within 5s, raise `ESC_VAULT_LOCK_TIMEOUT`.
- **Release** — automatic on file descriptor close, including process exit (kernel-released). Manual `LOCK_UN` after operation completes.

### 2.3 — Worked example (TypeScript pseudocode)

```typescript
// wiki/lib/concurrency.ts
import { openSync, closeSync } from 'fs';
import { flockSync } from 'fs-ext'; // or equivalent

async function withEntityLock<T>(
  tenant: string,
  entityType: string,
  slug: string,
  mode: 'shared' | 'exclusive',
  op: () => Promise<T>,
): Promise<T> {
  const lockPath = `/vault/${tenant}/wiki/compiled/${entityType}/${slug}.lock`;
  const fd = openSync(lockPath, 'a+', 0o600);
  const lockType = mode === 'exclusive' ? 'ex' : 'sh';
  const startMs = Date.now();

  // Try non-blocking first; if contended, poll up to OP_LOCK_TIMEOUT_S
  while (true) {
    try {
      flockSync(fd, lockType + 'nb'); // LOCK_EX|LOCK_NB or LOCK_SH|LOCK_NB
      break;
    } catch (err) {
      if (err.code !== 'EAGAIN') { closeSync(fd); throw err; }
      if (Date.now() - startMs > 5000) {
        closeSync(fd);
        throw new EscVaultLockTimeout(tenant, entityType, slug, 5000);
      }
      await sleep(50); // 50ms poll interval
    }
  }

  try {
    return await op();
  } finally {
    closeSync(fd); // auto-releases lock
  }
}
```

### 2.4 — Lock-vs-rename interaction

`flock` is held on the **lock file**, not on the markdown file. The wiki library writes new markdown content via the standard atomic-write pattern (write to `.tmp` then `rename(2)`) per `agent-bundle-renderer-design.md` §3.3.4. Reader holding a shared lock observes either the pre-rename or post-rename file content — never partial. The lock file path remains stable across renames (it's `<slug>.lock`, not tied to the markdown filename inode).

---

## Section 3 — Mechanism 2: Postgres optimistic concurrency

**Purpose:** prevent lost-writes at the indexed-data layer when two agents both pass §2's `flock` (e.g. one reads under shared lock, releases, then acquires exclusive lock too late).

**Substrate:** integer `version` column on the `entities` table per `second-brain-design.md` §2.4.2 schema, incremented on every write. Read-then-write operations include the read `version` in the UPDATE `WHERE` clause; 0-rows-affected indicates a concurrent write.

### 3.1 — Schema requirement

The `entities` table per `second-brain-design.md` §2.4.2 currently has `created_at` and `updated_at` columns. **Adding a `version INT NOT NULL DEFAULT 0` column is required** for optimistic concurrency. This surfaces as a new Day-4 Postgres provisioning tightening — see §7 Bucket 3.

```sql
ALTER TABLE entities
  ADD COLUMN version INT NOT NULL DEFAULT 0;
```

### 3.2 — Read-then-write pattern (worked example)

```typescript
async function updateEntity(
  tenant: string,
  entityType: string,
  slug: string,
  mutator: (frontmatter: Frontmatter, body: string) => { frontmatter: Frontmatter; body: string },
): Promise<void> {
  return withEntityLock(tenant, entityType, slug, 'exclusive', async () => {
    let attempt = 0;
    while (attempt < 2) { // 1 retry per §6 retry policy
      // 1. Read entity from Postgres + filesystem
      const row = await pgQuery(
        `SELECT id, version, file_path FROM entities WHERE tenant_slug = $1 AND id = $2`,
        [tenant, `${entityType}_${slug}`],
      );
      if (!row) throw new EntityNotFound(tenant, entityType, slug);

      const fileContent = await fs.readFile(row.file_path, 'utf-8');
      const { frontmatter, body } = parseFrontmatter(fileContent);

      // 2. Compute new content
      const updated = mutator(frontmatter, body);
      const newFileContent = serialiseFrontmatter(updated.frontmatter, updated.body);

      // 3. Postgres optimistic-concurrency update (single statement)
      const result = await pgQuery(
        `UPDATE entities
         SET frontmatter = $1, updated_at = now(), version = version + 1
         WHERE tenant_slug = $2 AND id = $3 AND version = $4`,
        [updated.frontmatter, tenant, `${entityType}_${slug}`, row.version],
      );

      if (result.rowCount === 0) {
        // Concurrent write since our read — retry
        attempt++;
        if (attempt < 2) {
          await sleep(100); // 100ms backoff
          continue;
        }
        throw new EscVaultVersionMismatch(tenant, entityType, slug, row.version);
      }

      // 4. Filesystem atomic-write
      const tmpPath = row.file_path + '.tmp';
      await fs.writeFile(tmpPath, newFileContent, { mode: 0o644 });
      await fs.rename(tmpPath, row.file_path);

      return; // success
    }
  });
}
```

### 3.3 — flock + Postgres sequencing rule

**Always: flock first, Postgres check second, write third.**

The flock (§2) prevents two operations from racing the same file's read-then-write. The Postgres version check (§3) catches the rare case where flock acquisition succeeded sequentially but a *different* code path (e.g. cron-driven full-table update in Janitor's nightly sweep) updated the row without holding flock.

If the order is inverted (Postgres check first, flock second), a writer holding flock could miss a concurrent flock-bypassing write. The single rule "flock-then-Postgres-then-write" makes the locking surface a single sequenced API.

### 3.4 — Retry policy

- **1 retry** on `ESC_VAULT_VERSION_MISMATCH` with 100ms backoff (`OP_RETRY_BACKOFF_MS = 100`).
- If second attempt also fails: raise `ESC_VAULT_VERSION_MISMATCH`, record in `decision_log` with `phase='gating_failed'` per `sequencing-target.md` §5-A enum extension, log human-readable error to operator Telegram per primitive 5 escalation surface.
- Rationale: a second concurrent write is a real signal (not transient noise) — surface to operator rather than loop indefinitely.

---

## Section 4 — Mechanism 3: Obsidian-aware mtime debounce

**Purpose:** prevent agents from clobbering an in-progress founder edit in Obsidian.

**Substrate:** filesystem `stat(2)` mtime check before writing. If the file was modified within the last `DEBOUNCE_THRESHOLD_S` (30s default, configurable per tenant), wait and retry.

### 4.1 — Why Obsidian needs special handling

Obsidian writes files on every keystroke (or per autosave interval, ~2s default). Without debounce, an agent acquiring `flock` at t=10s would see a clean lock and overwrite the file the founder is actively editing — losing keystrokes between the last autosave and the agent's read.

The debounce check **does not** rely on Obsidian-specific signals (no LSP, no Obsidian API). It uses mtime alone, which any editor produces. This makes the mechanism editor-agnostic — VS Code, vim, or direct file edits all trigger it.

### 4.2 — Debounce flow (worked example)

```typescript
async function debounceForHumanEdits(
  tenant: string,
  filePath: string,
): Promise<void> {
  const DEBOUNCE_THRESHOLD_S = 30; // configurable per tenant via /vault/<tenant>/_config.yaml
  const MAX_RETRIES = 5;
  const RETRY_WAIT_S = 6;

  for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
    let stat;
    try {
      stat = await fs.stat(filePath);
    } catch (err) {
      if (err.code === 'ENOENT') return; // file doesn't exist yet; no human is editing it
      throw err;
    }

    const ageMs = Date.now() - stat.mtimeMs;
    if (ageMs >= DEBOUNCE_THRESHOLD_S * 1000) return; // file untouched for ≥30s; safe to write

    if (attempt === MAX_RETRIES) {
      throw new EscVaultHumanEditBlocked(tenant, filePath, MAX_RETRIES);
    }
    await sleep(RETRY_WAIT_S * 1000); // wait 6s, then re-stat
  }
}
```

### 4.3 — Where debounce fits in the operation sequence

Within `updateEntity` (§3.2 worked example), the debounce check runs **after** `flock` acquisition (so no other agent is mid-write) but **before** the Postgres read-then-write (so we don't waste a version-check on a file we're about to abandon):

```
acquire flock (§2)
  → debounce check (§4) ───→ if ESC_VAULT_HUMAN_EDIT_BLOCKED, release flock and surface
    → Postgres read (§3)
      → mutator + Postgres optimistic write
        → filesystem atomic-write
release flock
```

### 4.4 — Tenant configurability

The 30s default is conservative — tenants whose founders type at human speed (~200 char/min) have natural pauses every 5-10s, so 30s of inactivity reliably indicates "founder has stepped away." Tenants with collaborative editing (multiple humans in Obsidian via sync) may need a longer threshold; setting `debounce_threshold_s: 60` in `/vault/<tenant>/_config.yaml` extends it.

The 5-retry × 6s-wait pattern caps worst-case wait at 30s (5 × 6s = 30s) before raising `ESC_VAULT_HUMAN_EDIT_BLOCKED`. Total operation budget from flock-acquire to escalation: ~35s. Worth surfacing to operator at this point — likely a long Obsidian session that needs founder attention to schedule agent work around.

---

## Section 5 — Mechanism 4: rewrite-backlinks cascade

**Purpose:** keep wiki-links consistent when an entity is renamed or merged with another.

**Substrate:** discover all entities that reference the target via `entity_links` table per `second-brain-design.md` §2.4.2; iterate in deadlock-safe order; apply the rewrite under per-entity flock per §2; update `entity_links` rows in a single Postgres transaction per ADR-002 Decision 3.

### 5.1 — Cascade trigger conditions

The cascade is triggered when an operation changes the **referenceable name** of an entity. Two cases:

- **Rename:** `slug` changes (e.g. `sarah_bowen` → `sarah_bowen_smith`). File path changes; all `wiki-link` references must update.
- **Merge:** two duplicate entities are merged; one is deprecated. References to the deprecated entity rewrite to the surviving entity.

A rename or merge produces a list of (entity_id → new_entity_id) tuples; the cascade applies all of them across the wiki.

### 5.2 — Lock ordering rule (deadlock prevention)

**Rule: acquire flock on referencing entities in alphabetical order by `entity_id` within `entity_type`, then by `entity_type` alphabetically.**

Two simultaneous cascades that touch overlapping referencing sets would deadlock if they acquired locks in different orders. The rule eliminates that: every cascade acquires locks in the same total order. The acquisition function:

```typescript
function cascadeOrderingKey(ref: { entity_type: string; entity_id: string }): string {
  return `${ref.entity_type}:${ref.entity_id}`;
}

// Before cascade begins:
const orderedRefs = referencingEntities
  .slice()
  .sort((a, b) => cascadeOrderingKey(a).localeCompare(cascadeOrderingKey(b)));
```

### 5.3 — Cascade flow (worked example)

```typescript
async function cascadeRename(
  tenant: string,
  oldSlug: string,
  newSlug: string,
  entityType: string,
): Promise<void> {
  const CASCADE_TIMEOUT_MS = 30_000;
  const startMs = Date.now();

  // 1. Discover all referencing entities
  const refs = await pgQuery(
    `SELECT from_entity_type, from_entity_id, from_file_path
     FROM entity_links
     WHERE tenant_slug = $1 AND to_entity_type = $2 AND to_entity_id = $3`,
    [tenant, entityType, `${entityType}_${oldSlug}`],
  );

  // 2. Order deadlock-safe (§5.2)
  const ordered = refs.slice().sort((a, b) =>
    cascadeOrderingKey({ entity_type: a.from_entity_type, entity_id: a.from_entity_id })
      .localeCompare(cascadeOrderingKey({ entity_type: b.from_entity_type, entity_id: b.from_entity_id }))
  );

  // 3. Postgres transaction: update entity_links table + entities table version
  const txn = await pgBegin();
  try {
    // Rename the entity row
    await txn.query(
      `UPDATE entities SET id = $1, file_path = $2, version = version + 1
       WHERE tenant_slug = $3 AND id = $4`,
      [`${entityType}_${newSlug}`, newFilePath, tenant, `${entityType}_${oldSlug}`],
    );

    // Update all entity_links rows that pointed at the old name
    await txn.query(
      `UPDATE entity_links SET to_entity_id = $1
       WHERE tenant_slug = $2 AND to_entity_type = $3 AND to_entity_id = $4`,
      [`${entityType}_${newSlug}`, tenant, entityType, `${entityType}_${oldSlug}`],
    );

    await txn.commit();
  } catch (err) {
    await txn.rollback();
    throw err;
  }

  // 4. Filesystem: rename target file
  await fs.rename(oldFilePath, newFilePath);

  // 5. Cascade: rewrite each referencing entity's markdown body
  const failures: typeof refs = [];
  for (const ref of ordered) {
    if (Date.now() - startMs > CASCADE_TIMEOUT_MS) {
      throw new EscVaultCascadeTimeout(tenant, oldSlug, newSlug, failures.length, refs.length);
    }

    try {
      await withEntityLock(tenant, ref.from_entity_type, ref.from_entity_id, 'exclusive', async () => {
        const content = await fs.readFile(ref.from_file_path, 'utf-8');
        const rewritten = rewriteWikiLinks(content, oldSlug, newSlug, entityType);
        if (rewritten === content) return; // no actual change; skip
        const tmpPath = ref.from_file_path + '.tmp';
        await fs.writeFile(tmpPath, rewritten, { mode: 0o644 });
        await fs.rename(tmpPath, ref.from_file_path);
      });
    } catch (err) {
      failures.push(ref);
      // Continue cascade; surface partial failure at end
    }
  }

  if (failures.length > 0) {
    throw new EscVaultCascadePartialFailure(tenant, oldSlug, newSlug, failures);
  }
}
```

### 5.4 — Atomicity guarantee

If any step fails:

- **Filesystem writes already completed are NOT automatically rolled back** (filesystem doesn't have transactions across multiple files).
- **Postgres transaction rolls back** if the txn.commit() in step 3 fails. But if Postgres commit succeeded and a later filesystem rename fails (step 4 or step 5), the filesystem state is now inconsistent with Postgres truth.
- **This is the structural risk** — filesystem-vs-Postgres atomicity gap on multi-file cascades.

**V1.0 mitigation:** surface partial failure as `ESC_VAULT_CASCADE_PARTIAL_FAILURE` carrying the list of `failures` (referencing entities whose markdown bodies were not rewritten). Record in `decision_log` with `phase='gating_failed'`, `metadata` containing the failures list. **Founder reviews and manually reconciles** — for each failure, run the rewrite by hand (most edits are small) or accept temporary inconsistency until next operation through that entity.

**V1.2+ improvement deferred** — write-ahead-log pattern where filesystem writes go to `wiki/.tmp/cascade-<txn-id>/` first; commit moves them atomically (via batched renames inside a sentinel-marker pattern); rollback removes the `.tmp/cascade-<txn-id>/` directory. Eliminates the partial-failure surface at the cost of meaningful implementation complexity. Out of v1.0 scope.

### 5.5 — Performance consideration

The cascade is sequential — each referencing entity's flock is acquired serially. For an entity with 100 backlinks (e.g. a Company entity that 100 Candidates reference), worst-case lock-acquire-wait time is bounded by `100 × OP_LOCK_TIMEOUT_S = 500s` if every backlink is contested. Realistic median (uncontested) is ~5ms per entity, so 100 backlinks ≈ 500ms total.

**V1.0 cascade timeout: 30 seconds** (`CASCADE_TIMEOUT_MS = 30_000`). If exceeded, raise `ESC_VAULT_CASCADE_TIMEOUT` with `failures.length` (entities not yet rewritten) and `refs.length` (total cascade size). Decision_log entry per `phase='gating_failed'`. **Founder reviews** — for large cascades (>30s), the rename is structurally expensive and may warrant rescheduling to off-hours.

**V1.2+ improvement deferred** — async cascade with eventual consistency: rename completes synchronously at the Postgres + target-file layer; cascade-rewrite is queued as background tasks; consumers see the updated `entity_links` table immediately, and lagging markdown bodies are reconciled within minutes. Reduces user-visible rename latency. Out of v1.0 scope.

---

## Section 6 — Escalation codes summary

Five new escalation codes introduced by this document:

| Code | Trigger | Decision_log phase | Operator surface |
|---|---|---|---|
| `ESC_VAULT_LOCK_TIMEOUT` | §2: `flock` acquisition failed within `OP_LOCK_TIMEOUT_S = 5` seconds | `gating_failed` | Telegram operator chat per primitive 5 |
| `ESC_VAULT_VERSION_MISMATCH` | §3: Postgres optimistic-concurrency UPDATE found 0 rows after retry | `gating_failed` | Telegram operator chat |
| `ESC_VAULT_HUMAN_EDIT_BLOCKED` | §4: Obsidian debounce hit `MAX_RETRIES = 5` (file mtime still recent after 30s of waiting) | `gating_failed` | Telegram operator chat |
| `ESC_VAULT_CASCADE_PARTIAL_FAILURE` | §5: rewrite-backlinks cascade completed but ≥1 referencing entity failed to rewrite | `gating_failed` | Telegram operator chat, plus `failures` list in decision_log metadata |
| `ESC_VAULT_CASCADE_TIMEOUT` | §5: cascade exceeded `CASCADE_TIMEOUT_MS = 30_000` ms | `gating_failed` | Telegram operator chat, plus partial-progress counters |

All five route via `hh_decision_log` from master brief §8.1 Change 2 + `ESC_BULLHORN_AUTH` pattern from `bullhorn-integration-path.md` §6.1. **The `_shared/hook-helpers.sh` Week-1 prereq must wire these 5 codes** (in addition to `ESC_BULLHORN_AUTH` and `ESC_RENDERER_FAILED` already on the wiring list per `current-priorities.md` Week-1 prereqs).

---

## Section 7 — Spec gaps surfaced

Four-bucket structure matching prior decision documents.

### Bucket 1 — Resolved inline in this document

| Resolution | Location |
|---|---|
| Lock ordering rule (alphabetical by `entity_id` within `entity_type`, then by `entity_type`) | §5.2 |
| flock + Postgres sequencing (flock first, Postgres check second, write third) | §3.3 |
| Debounce threshold default (30s, configurable per tenant via `_config.yaml`) | §4.2 + §4.4 |
| Cascade atomicity gap (v1.0 mitigation via `ESC_VAULT_CASCADE_PARTIAL_FAILURE` + decision_log + manual reconciliation; full atomicity via write-ahead-log deferred to v1.2+) | §5.4 |
| Cascade performance (30s timeout; v1.0 sequential; v1.2+ async with eventual consistency deferred) | §5.5 |

### Bucket 2 — Master brief edits needed

**None from this document.** The concurrency design was already authorised by `ADR-002` Decisions 2-3 + `second-brain-design.md` §2.6. This document is reference / specification, not a new decision — it does not surface fresh master-brief drifts.

The atomic-correction-commit 8-edit manifest from Day 3 close is unchanged.

### Bucket 3 — Week 1-2 prerequisites surfaced (existing + new)

| Prerequisite | Status | Owner | Source |
|---|---|---|---|
| `wiki/lib/concurrency.ts` implementation against this specification | Week 1-2 | Claude Code | This document |
| `_shared/hook-helpers.sh` wires 5 new `ESC_VAULT_*` codes (in addition to `ESC_BULLHORN_AUTH` + `ESC_RENDERER_FAILED`) | Week 1-2 | Claude Code | `current-priorities.md` Week-1 prereq #3 + §6 of this document |
| **`entities` table `version INT NOT NULL DEFAULT 0` column** | **Day 4 Postgres provisioning (NEW)** | Founder + Claude Code | §3.1 of this document |

The `entities.version` column is a new Day-4 tightening — joins the three already on the list per `sequencing-target.md` §6.5 (entity_graph split + `_secrets.env` + `decision_log.phase` enum extension). Day-4 task now has **4 consolidated tightenings**.

### Bucket 4 — Operational defaults (overridable)

| Default | Value | Override path |
|---|---|---|
| `OP_LOCK_TIMEOUT_S` (per-operation flock acquire timeout) | 5 seconds | `/vault/<tenant>/_config.yaml` per-tenant override |
| `DEBOUNCE_THRESHOLD_S` (Obsidian-edit debounce window) | 30 seconds | `/vault/<tenant>/_config.yaml` per-tenant override |
| `CASCADE_TIMEOUT_MS` (rewrite-backlinks cascade total timeout) | 30,000 ms | Operation-level override at call site for known-large cascades |
| Retry policy on Postgres version-mismatch | 1 retry with 100ms backoff (`OP_RETRY_BACKOFF_MS`) | Hard-coded in v1.0; may surface to per-tenant config in v1.1+ if observed contention requires |
| Lock ordering | Alphabetical by `entity_id` within `entity_type`, then by `entity_type` | Not overridable — invariant for deadlock prevention |

All defaults are conservative for v1.0 pilot scale (3-6 tenants per Product Spec §5.4). Observed contention data in production may justify tightening (lower lock timeouts to surface contention faster) or loosening (higher cascade timeouts for batch operations). Revisit at first three pilots' month-3 review per Product Spec §3.

---

End of vault-concurrency reference.
