#!/usr/bin/env bash
# =============================================================================
# task-block.sh — Mark task as BLOCKED with comment
#
# Usage: bash scripts/bash/task-block.sh <task-file> "<reason>"
#
# Example: bash scripts/bash/task-block.sh T001.md "Missing prerequisites from P5"
#
# Returns: 0 on success, 1 on error
# =============================================================================

set -euo pipefail

TASK_FILE="${1:-}"
REASON="${2:-}"

if [[ -z "$TASK_FILE" ]] || [[ -z "$REASON" ]]; then
  echo "Usage: task-block.sh <task-file> <reason>" >&2
  exit 1
fi

if [[ ! -f "$TASK_FILE" ]]; then
  echo "Task file not found: $TASK_FILE" >&2
  exit 1
fi

# Update status
sed -i 's/^Status: TODO$/Status: BLOCKED/' "$TASK_FILE"

# Add blocked comment
BLOCKED_BY="Blocked by agent: $(hostname) at $(date)"
echo "" >> "$TASK_FILE"
echo "## Blocked" >> "$TASK_FILE"
echo "- $BLOCKED_BY" >> "$TASK_FILE"
echo "- Reason: $REASON" >> "$TASK_FILE"

echo "Blocked: $TASK_FILE — $REASON"
exit 0
