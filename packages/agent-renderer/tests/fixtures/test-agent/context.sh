#!/usr/bin/env bash
# Context hydration — test-agent renderer fixture. Sources _shared/ helpers if present.

set -euo pipefail

SHARED_DIR="${CTX_AGENT_DIR}/.claude/hooks/_shared"

if [[ -d "${SHARED_DIR}" ]]; then
  # Real helpers land in Phase 3; this is a no-op for the renderer fixture.
  :
fi

echo "context.sh: hydrated for ${CTX_TENANT_SLUG}/${CTX_AGENT_NAME}"
