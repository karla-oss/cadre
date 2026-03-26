#!/usr/bin/env bash
# =============================================================================
# fix-issues.sh — I5 Fix Integration Issues
#
# Usage:
#   bash scripts/bash/fix-issues.sh <epic-folder>
#
# Flow:
#   Module agents fix issues found in I3 or I4
#   Each fix = new microbranch + PR
# =============================================================================

set -euo pipefail

ORIG_CWD="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

EPIC_PATH="${1:-}"
if [[ -z "$EPIC_PATH" ]]; then
  echo "Usage: $0 <epic-folder>" >&2
  echo "Example: $0 specs/S5-polish---auth" >&2
  exit 1
fi

if [[ "$EPIC_PATH" != /* ]]; then
  EPIC_PATH="${ORIG_CWD}/${EPIC_PATH}"
fi

EPIC_NAME=$(basename "$EPIC_PATH")
TASKS_DIR="$EPIC_PATH/tasks"

echo "=== I5 Fix Integration Issues ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -d "$TASKS_DIR" ]]; then
  echo "Error: tasks/ not found" >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Issues to fix:"
echo ""

# Find tasks with NEEDS_WORK comments
for task in "$TASKS_DIR"/*.md; do
  if grep -q "NEEDS_WORK\|needs work" "$task" 2>/dev/null; then
    TASK_NAME=$(basename "$task")
    echo "  - $TASK_NAME: has feedback"
  fi
done

echo ""
echo "To fix an issue:"
echo "  1. Agent: git checkout -b micro/fix/TXXX-description"
echo "  2. Agent: Implement fix"
echo "  3. Agent: git push"
echo "  4. Agent: gh pr create"
echo "  5. Goes through I3 → I4 again"
echo ""
echo "Repeat until all issues resolved."
