#!/usr/bin/env bash
# =============================================================================
# implement.sh — I1 Spawn Module Agents
#
# Usage:
#   bash scripts/implement/implement.sh <epic-folder>
#
# Flow:
#   1. Read cadre-config.yml (max_total, max_per_type)
#   2. Read tasks from tasks/
#   3. Spawn one agent per task (within pool limits)
#   4. Wait if pool full
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
CONFIG_FILE="$EPIC_PATH/../cadre-config.yml"

echo "=== I1 Spawn Module Agents ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -d "$TASKS_DIR" ]]; then
  echo "Error: tasks/ not found. Run make_tasks.sh first." >&2
  exit 1
fi

# -----------------------------------
# 1. Read cadre-config.yml
# -----------------------------------
MAX_TOTAL=5
MAX_PER_TYPE=3

if [[ -f "$CONFIG_FILE" ]]; then
  MAX_TOTAL=$(grep "max_total:" "$CONFIG_FILE" | awk '{print $2}' || echo "5")
  MAX_PER_TYPE=$(grep "max_per_type:" "$CONFIG_FILE" | awk '{print $2}' || echo "3")
fi

echo "Agent pool limits:"
echo "  max_total: $MAX_TOTAL"
echo "  max_per_type: $MAX_PER_TYPE"
echo ""

# -----------------------------------
# 2. Get TODO tasks
# -----------------------------------
echo "Finding TODO tasks..."
TASKS=$(find "$TASKS_DIR" -name "T*.md" -exec grep -l "**Status**: TODO" {} \; 2>/dev/null | sort)

if [[ -z "$TASKS" ]]; then
  echo "No TODO tasks found."
  exit 0
fi

TASK_COUNT=$(echo "$TASKS" | wc -l)
echo "Found $TASK_COUNT TODO tasks"
echo ""

# -----------------------------------
# 3. Spawn agents (one per task)
# -----------------------------------
SPAWNED=0
ACTIVE_AGENTS=0

for TASK_FILE in $TASKS; do
  TASK_NAME=$(basename "$TASK_FILE" .md)
  
  # Extract module from task file
  MODULE=$(grep "^module:" "$TASK_FILE" 2>/dev/null | awk '{print $2}' || echo "unknown")
  
  echo "--- Task: $TASK_NAME (module: $MODULE) ---"
  
  # Check pool limits
  if [[ $ACTIVE_AGENTS -ge $MAX_TOTAL ]]; then
    echo "  Pool full ($ACTIVE_AGENTS/$MAX_TOTAL). Waiting..."
    sleep 5
    ACTIVE_AGENTS=0
  fi
  
  # Spawn agent for this task
  echo "  Spawning agent for $TASK_NAME..."
  
  # TODO: Actually spawn the agent
  # For now: show the command
  echo "  Command would be:"
  echo "    spawn-agent.sh --task $TASK_FILE"
  
  SPAWNED=$((SPAWNED + 1))
  ACTIVE_AGENTS=$((ACTIVE_AGENTS + 1))
  
  echo "  Pool: $ACTIVE_AGENTS/$MAX_TOTAL"
  echo ""
done

echo "=== Summary ==="
echo "Tasks found: $TASK_COUNT"
echo "Agents spawned: $SPAWNED"
echo ""
echo "Agents will:"
echo "  1. Create microbranch"
echo "  2. Implement task"
echo "  3. Create PR"
echo "  4. Update task status to READY_FOR_REVIEW"
