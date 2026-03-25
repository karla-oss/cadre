#!/usr/bin/env bash
# =============================================================================
# on-p6a-start.sh — Hook runs when P6a phase starts
#
# Spawns standing module agents based on available tasks.
# This hook is triggered when transitioning from P5 to P6a.
#
# Usage: bash scripts/hooks/on-p6a-start.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TASKS_DIR="${TASKS_DIR:-$CADRE_ROOT/tasks}"

echo "=== P6a Start Hook ==="
echo "Spawning module agents..."

# Agent types to check
AGENTS="api frontend analysis infra"

for agent in $AGENTS; do
  # Normalize agent name
  case "$agent" in
    api) FULL_NAME="api-agent" ;;
    frontend) FULL_NAME="frontend-agent" ;;
    analysis) FULL_NAME="analysis-agent" ;;
    infra) FULL_NAME="infra-agent" ;;
    *) FULL_NAME="${agent}-agent" ;;
  esac
  
  # Check if there are TODO tasks for this agent
  TASK_COUNT=$(bash "$SCRIPT_DIR/../bash/task-get-todos.sh" "$agent" 2>/dev/null | wc -l)
  
  if [[ $TASK_COUNT -gt 0 ]]; then
    echo "Found $TASK_COUNT TODO tasks for @${FULL_NAME} — spawning..."
    # Note: Actual spawn is done by Super via sessions_spawn
    # This hook just logs what should be spawned
    echo "  → Should spawn: @${FULL_NAME}"
  else
    echo "No TODO tasks for @${FULL_NAME} — skipping"
  fi
done

echo "=== P6a Start Hook Complete ==="
echo "Run 'spawn-agent.sh --no-task --agent <type>' manually or via Super."
