#!/usr/bin/env bash
# =============================================================================
# task-comment.sh — Add a comment to a task
#
# Usage: bash scripts/bash/task-comment.sh <task-file> "<author>" "<comment>"
#
# Example: bash scripts/bash/task-comment.sh tasks/FE-001.md "@archi" "LGTM, minor style issue"
#
# Returns: 0 on success
# =============================================================================

set -euo pipefail

TASK_FILE="${1:-}"
AUTHOR="${2:-}"
COMMENT="${3:-}"

if [[ -z "$TASK_FILE" ]] || [[ -z "$AUTHOR" ]] || [[ -z "$COMMENT" ]]; then
  echo "Usage: task-comment.sh <task-file> <author> <comment>" >&2
  exit 1
fi

if [[ ! -f "$TASK_FILE" ]]; then
  echo "Task file not found: $TASK_FILE" >&2
  exit 1
fi

TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"

# Append comment to task file
{
  echo ""
  echo "---"
  echo "**$AUTHOR** at $TIMESTAMP:"
  echo ""
  echo "$COMMENT"
} >> "$TASK_FILE"

echo "Comment added to $TASK_FILE by $AUTHOR"
exit 0
