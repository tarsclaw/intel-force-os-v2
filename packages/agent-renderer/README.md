# @ifos/agent-renderer

Translates IFOS Agent Bundle v2 (`agents/<vertical>/<name>/`) into a cortextOS-shaped per-tenant agent directory (`${frameworkRoot}/orgs/<org>/agents/<name>/`). Implements [ADR-003](../../docs/decisions/ADR-003-agent-bundle-renderer.md) and the 12-row file mapping at [`docs/architecture/agent-bundle-renderer-design.md` §2.1](../../docs/architecture/agent-bundle-renderer-design.md).

## Status

**Phase 2 scaffold (v0.1.0).** Phases 3-5 (helpers + voice schema + voice-loader) follow per `~/.claude/plans/bubbly-snuggling-lantern.md`. First production render: Diagnostic agent at Week 4 per master brief §8.2.

## Install + build

```bash
cd packages/agent-renderer
pnpm install
pnpm build   # produces dist/cli.js (ESM, Node 20+ shebang)
pnpm test    # 30 unit tests
```

## Invocation

```bash
node dist/cli.js render <agent-name> --tenant <slug> \
  [--bundle-root <path>] \
  [--vault-root <path>] \
  [--framework-root <path>] \
  [--org <name>] \
  [--dry-run] \
  [--force-overwrite-non-rendered]
```

### Defaults

| Flag | Default | Source |
|---|---|---|
| `--bundle-root` | `<repo>/agents/recruitment/` | master brief §4.1 |
| `--vault-root` | `${IFOS_VAULT_ROOT:-/vault}/<slug>` | Ultraplan §5.1 |
| `--framework-root` | `${CTX_ROOT:-~/.cortextos/ifos-v2}` | `.envrc` |
| `--org` | `<tenant-slug>` | one-org-per-tenant in v1.0 |

### Example (test fixture)

From repo root, after `source .envrc`:

```bash
node packages/agent-renderer/dist/cli.js render test-agent \
  --tenant migration-test \
  --bundle-root packages/agent-renderer/tests/fixtures \
  --vault-root packages/agent-renderer/tests/fixtures/test-tenant-vault/migration-test \
  --framework-root /tmp/ifos-render-test
```

Output (stdout):

```json
{
  "outcome": "rendered",
  "agentName": "test-agent",
  "tenantSlug": "migration-test",
  "targetDir": "/tmp/ifos-render-test/orgs/migration-test/agents/test-agent",
  "filesWritten": 10,
  "durationMs": 23
}
```

Exit code `0` for `rendered` or `no-op`; `1` for `failed`; `2` for fatal CLI error.

## CLI name divergence from ADR-003

ADR-003 §3.3.1 specifies `cortextos-ifos render-agent`. The upstream `cortextos-ifos` binary lives in the read-only submodule per master brief §3.1 boundary, so we can't add a subcommand there. Phase 2 ships the renderer as standalone `ifos-render-agent` (Node binary; `bin` field in package.json). The `.envrc` `alias ifosctl="cortextos-ifos"` is unchanged; a separate wrapper for `ifosctl render-agent <args>` is **not** in Phase 2 scope.

**Action item:** ADR-004 (Phase 2 follow-up) will ratify either (a) keeping `ifos-render-agent` as a standalone surface or (b) building an `ifosctl` shim that multiplexes. Founder + Codex review at first ratification round.

## What it does — 12-row file map

| Source | Target | Action |
|---|---|---|
| `agent.md` | `CLAUDE.md` | Synthesis: preamble + body + tenant footer |
| `config.schema.json` | `config.json` | Synthesis: schema + `_config.yaml` + common-*.json defaults + Ajv validation |
| (none) | `.env` (`chmod 0600`) | Synthesis: `_secrets.env` filtered through `tools.yaml` `required_env` |
| `tools.yaml` | `tools.yaml` | Passthrough |
| `validate.sh` | `.claude/hooks/validate.sh` (`chmod 0755`) | Verbatim copy |
| `context.sh` | `.claude/hooks/context.sh` (`chmod 0755`) | Verbatim copy |
| `README.md` | `README.md` | Verbatim copy |
| `tests/fixtures/` | — | Stays in source (CI fixture runner per master brief §8.3) |
| cortextOS templates (IDENTITY/SOUL/GOALS/MEMORY/etc.) | — | Drop |
| `.claude/skills/` (24-skill tree) | — | Drop (R2 commitment per ADR-003 Decision 1) |
| (none) | `goals.json` | Empty placeholder — daemon-side compat per `add-agent.ts:131-140` |
| (none) | `.claude/hooks/_shared → ../../_shared` | Symlink (Option γ per ADR-003 §3.3.3) |

Plus the `.rendered-by-ifos-renderer` marker written **last** (pre-flight refuses to overwrite directories without it; protects against `add-agent` scaffolding collisions).

## Atomicity (ADR-003 §3.3.4)

1. Write to `<target>.tmp.<pid>/`
2. If `<target>/` exists, rename to `<target>.prev.<ISO-timestamp>/`
3. Atomic rename `<target>.tmp.<pid>/` → `<target>/`
4. `cleanOldPrev` retains the two most recent `.prev.*` directories

Daemon `discoverAgents()` filters by directory pattern; `.tmp.<pid>/` and `.prev.<timestamp>/` are invisible to discovery (verified against pinned cortextOS SHA `c21fbfe`).

## Failure modes (ADR-003 §4)

Every failure returns `outcome: "failed"` + `reason: "<code>: <message>"`. Codes follow `agent-bundle-renderer-design.md` §4 + map to `ESC_RENDERER_FAILED` per `agents/_shared/escalation-codes.md` §2.4:

| Code | Trigger |
|---|---|
| `schema-validation-failure` | `config.json` failed Ajv validation against bundle schema |
| `bundle-malformed` | Missing required bundle file OR unresolved preamble token OR tools.yaml requires env not in _secrets.env |
| `shared-helpers-missing` | `agents/_shared/` or `escalation-codes.md` not present |
| `tenant-not-provisioned` | `/vault/<slug>/` missing OR `_secrets.env` missing (Day-4 §6.5 prereq) |
| `non-rendered-target` | Target dir exists without `.rendered-by-ifos-renderer` marker; use `--force-overwrite-non-rendered` to override |
| `atomic-rename-failed` | Filesystem-level rename failed mid-commit (infrastructure issue, not author error) |

Failures abort cleanly: tmp dir cleaned up, prior `<target>/` rolled back from `.prev.<ts>/` if possible.

## Known limitations

- **`_shared/` copy-not-symlink staleness.** Renderer COPIES `agents/_shared/` to `${frameworkRoot}/orgs/<org>/agents/_shared/` per ADR-003 §3.3.3 Option γ — does NOT symlink. Mid-pilot edits to `agents/_shared/{voice-loader,hook-helpers}.sh` require re-running `render-agent` for each tenant. v1.0 acceptable (single-tenant pilot); v1.1 may add SHA-based skip-if-unchanged optimisation.
- **3-5s end-to-end latency (Ultraplan §3.2)** is for the agent runtime pipeline, NOT for the renderer itself. Renderer benchmarks at ~22-25ms per render against the test fixture on Day-8 hardware. Multi-tenant scale testing deferred to Week-5 exercise.
- **`discoverAgents()` lists `_shared` as a phantom agent.** Upstream cortextOS `bus/agents.ts` `listAgents()` scans `orgs/<org>/agents/*` without excluding `_shared/`. Renderer correctness unaffected; surfaces only in `cortextos-ifos list-agents` output. Carry-forward concern for IFOS daemon integration; not part of Phase 2 scope.
- **Telegram-down hang for orange-tier autosend** (autosend-safety-policy §5) is a Phase-3 concern in `hook-helpers.sh` `autosend_await_approval`, not a renderer concern. Documented for completeness.

## Hand-edits and re-rendering

Hand-edits to the rendered output are **lost on next render** (Decision 4: overwrite-no-merge per ADR-003 §3.4). Edit the bundle, then re-render. Decision-log row written with `agent_name='_renderer'` + `phase='render'` per ADR-003 §4 audit policy (Phase 3 wires this via `hook-helpers.sh`).

## Codex ratification

Renderer scaffold + 30 unit tests + first-render verification join the Codex Day-7 ratification queue (item #25 placeholder per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1). Execution deferred per Day-7 manifest §4 — manifest produced, skills not yet built.

## Repository layout

```
packages/agent-renderer/
├── README.md                 ← this file
├── package.json              ← @ifos/agent-renderer; Node ≥20; ESM
├── tsconfig.json             ← strict TypeScript; ES2022
├── tsup.config.ts            ← build target node20; ESM banner with shebang
├── vitest.config.ts          ← test config; tests/**/*.test.ts
├── src/
│   ├── cli.ts                ← commander entry; `render <name>` subcommand
│   ├── renderer.ts           ← orchestration: preflight → sync → synthesise → atomic commit
│   ├── fileMap.ts            ← 12-row mapping + goals.json placeholder constant
│   ├── preflight.ts          ← bundle / shared / tenant / marker checks
│   ├── atomicWrite.ts        ← tmp/prev/atomic rename + cleanOldPrev
│   ├── types.ts              ← RenderContext, RenderResult, FileMapRow
│   └── synthesis/
│       ├── claudeMd.ts       ← preamble + body + token substitution
│       ├── configJson.ts     ← Ajv 2020-12 + common-*.json $refs
│       └── envFile.ts        ← _secrets.env → .env filtered by tools.yaml.required_env
├── templates/
│   └── claude-md-preamble.md ← Phase 1 spec gap §2.1-A resolution
├── dist/                     ← tsup build output (gitignored)
└── tests/
    ├── unit/                 ← 4 vitest files; 30 tests
    └── fixtures/
        ├── test-agent/       ← minimal 6-file bundle
        └── test-tenant-vault/migration-test/  ← _config.yaml + _secrets.env
```

## See also

- ADR-003 — Agent bundle v2 renderer (ratified)
- `docs/architecture/agent-bundle-renderer-design.md` — 22-spec-gap design doc
- `agents/_shared/escalation-codes.md` — ESC catalogue (Phase 1)
- `packages/agents-runtime/_shared/common-*.json` — shared config schemas (Phase 1)
- `~/.claude/plans/bubbly-snuggling-lantern.md` — active 5-phase plan
