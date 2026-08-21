#!/usr/bin/env bash
# fill-dev-sandbox-secrets.sh
#
# Interactive clipboard-pipe helper for populating
# ~/.ifos-local-vault/dev-sandbox/_secrets.env without typing values into
# terminal/chat (Path A discipline). Workflow per variable:
#   1. Script prompts "Copy VAR_NAME, press Enter"
#   2. You copy the value in 1Password (Cmd+C on the field)
#   3. You press Enter in this script
#   4. Script reads pbpaste, writes VAR=<value> to the file (atomic), clears clipboard
#   5. Moves to next variable
#
# Press Enter WITHOUT copying anything to skip that variable (leaves blank).
# Press Ctrl+C anytime to abort (partial file remains; safe to re-run).
#
# Path A guarantees:
#   - Values never echoed to terminal stdout/stderr
#   - Values never appear in shell history (no command typed with value inline)
#   - Clipboard cleared after each write (prevents accidental paste elsewhere)
#   - File is mode 0600 throughout

set -euo pipefail

readonly SECRETS_FILE="${HOME}/.ifos-local-vault/dev-sandbox/_secrets.env"
readonly TMP_FILE="${SECRETS_FILE}.tmp.$$"

# Variables to prompt for, in order. Only includes the ones Day 35 + W6 needs.
# Add more as needed (Xero/QB/TrueLayer/WorkOS) — they're in the file already
# with VAR= shape, just empty; this script will fill or skip per your input.
readonly VARS=(
  "ANTHROPIC_API_KEY"
  "COMPANIES_HOUSE_API_KEY"
  "BULLHORN_CLIENT_ID"
  "BULLHORN_CLIENT_SECRET"
  "BULLHORN_SANDBOX_USERNAME"
  "BULLHORN_SANDBOX_PASSWORD"
  "BULLHORN_SANDBOX_CORPORATION_ID"
  "BULLHORN_SANDBOX_REGION"
  "GRANOLA_CLIENT_ID"
  "GRANOLA_WORKSPACE_ID"
  "REED_API_KEY"
  "REED_ACCOUNT_ID"
  "CVLIBRARY_AUTH_MODE"
  "CVLIBRARY_API_KEY"
  "CVLIBRARY_ACCESS_TOKEN"
  "CVLIBRARY_ACCOUNT_ID"
  "XERO_CLIENT_ID"
  "XERO_CLIENT_SECRET"
  "XERO_DEMO_COMPANY_ORG_ID"
  "QB_CLIENT_ID"
  "QB_CLIENT_SECRET"
  "QB_SANDBOX_REALM_ID"
  "TRUELAYER_CLIENT_ID"
  "TRUELAYER_CLIENT_SECRET"
  "WORKOS_SECRET_KEY"
  "TELEGRAM_BOT_TOKEN"
)

if [[ ! -f "${SECRETS_FILE}" ]]; then
  printf 'ERROR: %s does not exist.\n' "${SECRETS_FILE}" >&2
  printf 'Create it first by copying the template:\n' >&2
  printf '  cp ~/.ifos-local-vault/dev-sandbox/_secrets.env.template %s\n' "${SECRETS_FILE}" >&2
  printf '  chmod 0600 %s\n' "${SECRETS_FILE}" >&2
  exit 1
fi

# Confirm mode 0600 (defense-in-depth)
chmod 0600 "${SECRETS_FILE}"

printf '\n'
printf '════════════════════════════════════════════════════════════════════\n'
printf '  Fill dev-sandbox secrets — clipboard-pipe mode\n'
printf '════════════════════════════════════════════════════════════════════\n'
printf '\n'
printf '  For each variable below:\n'
printf '    - Copy the value from 1Password (Cmd+C on the field)\n'
printf '    - Press Enter HERE to write it to the file + clear clipboard\n'
printf '    - Press Enter WITHOUT copying to skip (leave blank)\n'
printf '    - Press Ctrl+C to abort safely\n'
printf '\n'
printf '  File: %s\n' "${SECRETS_FILE}"
printf '\n'
printf '────────────────────────────────────────────────────────────────────\n'
printf '\n'

# Track stats
filled=0
skipped=0

# Work on a temp copy; rename atomically at the end
cp "${SECRETS_FILE}" "${TMP_FILE}"
chmod 0600 "${TMP_FILE}"

# Clear clipboard at start so first variable doesn't pick up stale value
printf '' | pbcopy

for var in "${VARS[@]}"; do
  printf '  [%s]  ' "${var}"
  # Read user input — they should copy to clipboard first, then press Enter
  read -r -p "Press Enter when value copied (or just Enter to skip): " _

  # Read clipboard value (suppress any error if pbpaste returns nothing)
  value="$(pbpaste 2>/dev/null || true)"

  if [[ -z "${value}" ]]; then
    printf '    → SKIPPED (clipboard empty)\n'
    skipped=$((skipped + 1))
    continue
  fi

  # Sanity: refuse if value looks like our prompt text (user didn't actually copy)
  if [[ "${value}" == *"Press Enter"* ]]; then
    printf '    → SKIPPED (clipboard contained prompt text; nothing was copied)\n'
    skipped=$((skipped + 1))
    continue
  fi

  # Strip leading/trailing whitespace (1Password sometimes adds these on copy)
  value="$(printf '%s' "${value}" | awk '{$1=$1; print}')"

  # Replace the VAR=<old_value> line atomically in temp file.
  # The line in the template/file looks like: VAR_NAME= (followed by optional whitespace + # comment)
  # We replace just the value portion, keeping any inline comment intact.
  # Use a Python one-liner for safe escaping (sed escapes are painful for arbitrary values).
  python3 - "${TMP_FILE}" "${var}" "${value}" <<'PY'
import sys, re, os, tempfile
path, var, value = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, 'r') as f:
    lines = f.readlines()
replaced = False
new_lines = []
for line in lines:
    m = re.match(r'^(' + re.escape(var) + r')=([^\n#]*)(\s*#.*)?$', line)
    if m and not replaced:
        comment = m.group(3) or ''
        # Comments-after-value style: VAR=<value>    # comment
        # If there's a comment, keep it with one space buffer
        if comment.strip():
            new_lines.append(f'{var}={value}    {comment.lstrip()}')
            if not new_lines[-1].endswith('\n'):
                new_lines[-1] += '\n'
        else:
            new_lines.append(f'{var}={value}\n')
        replaced = True
    else:
        new_lines.append(line)
if not replaced:
    # Variable not found in file; append at end (shouldn't normally happen
    # since template includes all variables)
    if new_lines and not new_lines[-1].endswith('\n'):
        new_lines.append('\n')
    new_lines.append(f'{var}={value}\n')

# Atomic write: temp + rename
tmp_dir = os.path.dirname(path)
fd, tmp_path = tempfile.mkstemp(dir=tmp_dir, prefix='.fillsecrets.')
try:
    with os.fdopen(fd, 'w') as f:
        f.writelines(new_lines)
    os.chmod(tmp_path, 0o600)
    os.rename(tmp_path, path)
except Exception:
    try: os.unlink(tmp_path)
    except FileNotFoundError: pass
    raise
PY

  # Clear clipboard immediately
  printf '' | pbcopy

  printf '    → WROTE (%d chars)\n' "${#value}"
  filled=$((filled + 1))
done

# Atomic move temp → real file
mv "${TMP_FILE}" "${SECRETS_FILE}"
chmod 0600 "${SECRETS_FILE}"

printf '\n'
printf '────────────────────────────────────────────────────────────────────\n'
printf '  Done. filled=%d, skipped=%d (of %d total variables)\n' "${filled}" "${skipped}" "${#VARS[@]}"
printf '────────────────────────────────────────────────────────────────────\n'
printf '\n'
printf '  Verify with (NEVER use cat — never `cat` a secrets file):\n'
printf '    awk -F= '"'"'$1 !~ /^#/ && $1 != "" {\n'
printf '      val=$2; for(i=3; i<=NF; i++) val = val "=" $i\n'
printf '      sub(/[ \\t]*#.*$/, "", val); gsub(/^[ \\t]+|[ \\t]+$/, "", val)\n'
printf '      print "  " $1 "  " (length(val) == 0 ? "[EMPTY]" : "[SET " length(val) " chars]")\n'
printf '    }'"'"' %s\n' "${SECRETS_FILE}"
printf '\n'
printf '  Clipboard has been cleared.\n'
printf '\n'
