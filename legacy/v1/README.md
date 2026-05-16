# legacy/v1 — Intel Force OS v1 (read-only reference)

**This directory is the v1 codebase snapshot, included here so Claude.ai (and any other reader of this repo) has one place to see everything v2 inherits from. It is NOT the active build target.**

---

## Status

- **Snapshot taken:** 2026-05-16
- **Source:** `/Users/madsadmin/code/intel-force-os/` on the founder's machine
- **State:** working tree at the time of v2 build-pack creation (post agent-activity-log work, pre-Phase-0)
- **Mirror repo:** https://github.com/tarsclaw/intel-force-os (separate canonical home)

---

## What this is

The Intel Force OS v1 product. Active, serving founding customers. Includes:

- `apps/dashboard/` — Next 15.5 dashboard (the source for v2's lifted UI chrome)
- `apps/marketing/` — landing-page work
- `src/` — Cloudflare Worker bot runtime (Teams HR Agent)
- `packages/db/` — Prisma schema
- `packages/trpc/` — tRPC routers
- `packages/schemas/` — shared Zod schemas
- `services/` — auxiliary services (brain-builder, secrets-vault, provisioning, etc.)
- `docs/` — ~40,000 lines of spec across 8 phase packs
- `teams-app/` — Microsoft Teams app manifest
- `migrations/` — D1 migrations
- `onboarding/` — per-customer CLI tools

---

## What it is NOT

- **NOT an active build target in this repo.** Active work lives at the top of `/Users/madsadmin/code/CortexOS/`, governed by `docs/build-pack/`.
- **NOT to be modified from v2 work.** If a v1 bug needs fixing, fix it in the standalone v1 repo (`tarsclaw/intel-force-os`) and re-snapshot here when convenient.
- **NOT a complete reproduction.** Excluded from this snapshot: `node_modules/`, `.next/`, `.turbo/`, `.wrangler/`, `dist/`, `services/quartz/` (386MB external bundle), and build artefacts.

---

## How to use during the v2 build

The build pack's `docs/build-pack/05-MIGRATION-MAP.md` names every concept worth lifting from v1, with v1 paths and v2 destinations. When that map says "lift `apps/dashboard/components/shared/card.tsx`", it means **this directory's** `apps/dashboard/components/shared/card.tsx`. Read it, copy the relevant patterns into v2's `packages/ui/` (or wherever the map prescribes), rewire imports, ship.

**Do not** copy entire directories. The migration map specifies file-by-file lifts. Bulk copies muddy the boundary the build pack is trying to maintain.

---

## Snapshot freshness

This snapshot ages. The canonical v1 lives at `tarsclaw/intel-force-os` and continues to receive bug fixes while founding customers are served. If a v1 change is material (security patch, customer-blocking bug fix), re-snapshot:

```bash
rsync -a \
  --exclude='node_modules' --exclude='.next' --exclude='.turbo' \
  --exclude='.wrangler' --exclude='dist' --exclude='.git' \
  --exclude='services/quartz' --exclude='*.log' --exclude='.DS_Store' \
  /Users/madsadmin/code/intel-force-os/ \
  /Users/madsadmin/code/CortexOS/legacy/v1/
git -C /Users/madsadmin/code/CortexOS add legacy/v1 && \
  git -C /Users/madsadmin/code/CortexOS commit -m "chore(legacy): refresh v1 snapshot"
```

In general: refresh quarterly OR after any material v1 change OR when v2 implementer requests it.
