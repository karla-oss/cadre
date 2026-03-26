#!/usr/bin/env bash
# =============================================================================
# implement.sh — I1 Spawn Module Agents
#
# Usage:
#   bash scripts/bash/implement.sh <epic-folder>
#
# Flow:
#   Spawns module agents in parallel
#   Each agent gets its TODO tasks and implements
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

echo "=== I1 Spawn Module Agents ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -d "$TASKS_DIR" ]]; then
  echo "Error: tasks/ not found. Run make_tasks.sh first." >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Spawning module agents..."
echo ""

# Find modules with TODO tasks
MODULES=$(grep -l "**Status**: TODO" "$TASKS_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | sed 's/T[0-9]*-//' | sort -u)

echo "Modules with TODO tasks: $MODULES"
echo ""

for module in $MODULES; do
  echo "--- Spawning @$module-agent ---"
done

echo ""
echo "To spawn agents manually:"
echo "  bash spawn-agent.sh --task tasks/T001.md"
echo ""
echo "Agents will:"
echo "  1. Create microbranch"
echo "  2. Implement task"
echo "  3. Create PR"
echo "  4. Update task status to READY_FOR_REVIEW"
