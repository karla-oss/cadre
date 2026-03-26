#!/usr/bin/env bash
# =============================================================================
# task-claim.sh — Atomically claim a task (mark as IN_PROGRESS)
#
# Usage: bash scripts/bash/task-claim.sh <task-file>
#
# Example: bash scripts/bash/task-claim.sh /path/to/T001.md
#
# Returns: 0 if claimed, 1 if already taken or invalid
# =============================================================================

set -euo pipefail

TASK_FILE="${1:-}"

if [[ -z "$TASK_FILE" ]]; then
  echo "Usage: task-claim.sh <task-file>" >&2
  exit 1
fi

if [[ ! -f "$TASK_FILE" ]]; then
  echo "Task file not found: $TASK_FILE" >&2
  exit 1
fi

# Check current status
STATUS="$(grep -m1 '^\*\*Status\*\*:' "$TASK_FILE" 2>/dev/null | sed 's/\*\*Status\*\*: //' | tr -d ' ' || echo 'UNKNOWN')"

if [[ "$STATUS" != "TODO" ]]; then
  echo "Task $TASK_FILE is not TODO (current: $STATUS)" >&2
  exit 1
fi

# Create backup for rollback
cp "$TASK_FILE" "${TASK_FILE}.backup"

# Attempt to claim
if sed -i 's/\*\*Status\*\*: TODO$/\*\*Status\*\*: IN_PROGRESS/' "$TASK_FILE" 2>/dev/null; then
  # Verify it changed
  NEW_STATUS="$(grep -m1 '^\*\*Status\*\*:' "$TASK_FILE" | sed 's/\*\*Status\*\*: //' | tr -d ' ')"
  if [[ "$NEW_STATUS" == "IN_PROGRESS" ]]; then
    rm -f "${TASK_FILE}.backup"
    echo "Claimed: $TASK_FILE"
    exit 0
  fi
fi

# Rollback on failure
mv "${TASK_FILE}.backup" "$TASK_FILE" 2>/dev/null || true
echo "Failed to claim: $TASK_FILE" >&2
exit 1
