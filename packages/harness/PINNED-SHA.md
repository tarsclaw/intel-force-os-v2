# cortextOS pinned commit

Repo: github.com/grandamenium/cortextos
SHA: c21fbfe991a0030ea055bd8e2389a0801a424383
Short: c21fbfe
Date pinned: 2026-05-16
Verified at: c21fbfe991a0030ea055bd8e2389a0801a424383

## What this submodule is

This submodule at `packages/harness/cortextos/` is a **reference pin**, not
the runtime.

The actual IFOS cortextOS runtime lives at `~/code/cortex-os-ifos/` and is
invoked via the `cortextos-ifos` binary (see this repo's `.envrc` for
`IFOS_HARNESS_ROOT`).

The submodule exists because:
1. Git history of `~/code/CortexOS/` records exactly which cortextOS SHA
   each commit was built against. Future-you can check out any commit and
   know the runtime context.
2. Claude Code can read cortextOS internals with the `view` tool without
   leaving this repo — useful for understanding what we're building on.
3. The four `bus/kb-*.sh` originals are here for reference when we build
   the brain-replacement overrides at `packages/brain/bus-overrides/`
   (master brief §3.4 and §5).

## Boundary

The submodule is **read-only**. Never edit anything inside it. To consume
new upstream features:

```
cd ~/code/cortex-os-ifos
git fetch origin
git checkout <new-sha>
npm install && npm run build
echo "<new-sha>" > .ifos-pinned-sha

cd ~/code/CortexOS/packages/harness/cortextos
git fetch origin
git checkout <new-sha>
cd ~/code/CortexOS

# Update this file's SHA line above, then commit
git add packages/harness/cortextos packages/harness/PINNED-SHA.md
git commit -m "harness: bump cortextos to <short-sha>"
```

After every bump:
- Restart IFOS daemon if running
- Run full test suite
- Codex ratification per master brief §10
- Update `.agents/learnings/00-cortextos-quirks.md` if new quirks emerge
