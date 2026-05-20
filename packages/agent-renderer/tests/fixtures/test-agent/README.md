# test-agent

Minimal test fixture bundle for `packages/agent-renderer/` unit + integration
tests. NOT a v1.0 production agent. Used only by `vitest` runs + manual
acceptance commands (`pnpm render -- render test-agent --tenant <slug>`).

Six bundle files + three fixture sub-directories per master brief §8 layout.

This README is tenant-agnostic by design — references no specific tenant
slug so cross-tenant tenancy-audit verification (T7) returns clean.
