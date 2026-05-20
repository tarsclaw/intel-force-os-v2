#!/usr/bin/env bash
# Gate A — test-agent renderer fixture. Hard-fail if CTX env not present.

set -euo pipefail

if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
  echo "validate.sh: CTX_TENANT_SLUG not set" >&2
  exit 1
fi

if [[ -z "${CTX_AGENT_NAME:-}" ]]; then
  echo "validate.sh: CTX_AGENT_NAME not set" >&2
  exit 1
fi

exit 0
