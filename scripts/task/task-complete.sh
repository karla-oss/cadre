#!/usr/bin/env bash
# =============================================================================
# task-complete.sh — Mark task as DONE
#
# Usage: bash scripts/bash/task-complete.sh <task-file>
#
# Example: bash scripts/bash/task-complete.sh /path/to/T001.md
#
# Returns: 0 if completed, 1 if not IN_PROGRESS or invalid
# =============================================================================

set -euo pipefail

TASK_FILE="${1:-}"

if [[ -z "$TASK_FILE" ]]; then
  echo "Usage: task-complete.sh <task-file>" >&2
  exit 1
fi

if [[ ! -f "$TASK_FILE" ]]; then
  echo "Task file not found: $TASK_FILE" >&2
  exit 1
fi

# Verify it was IN_PROGRESS
STATUS="$(grep -m1 '^\*\*Status\*\*:' "$TASK_FILE" 2>/dev/null | sed 's/\*\*Status\*\*: //' | tr -d ' ' || echo 'UNKNOWN')"

if [[ "$STATUS" != "IN_PROGRESS" ]]; then
  echo "Task $TASK_FILE is not IN_PROGRESS (current: $STATUS)" >&2
  exit 1
fi

# Mark as ready for review (not done — review comes next)
sed -i 's/\*\*Status\*\*: IN_PROGRESS/**Status**: READY_FOR_REVIEW/' "$TASK_FILE"
echo "Ready for review: $TASK_FILE"
exit 0
