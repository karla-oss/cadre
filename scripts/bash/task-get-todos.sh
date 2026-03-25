#!/usr/bin/env bash
# =============================================================================
# task-get-todos.sh — Get TODO tasks for an agent type
#
# Usage: bash scripts/bash/task-get-todos.sh <agent-type>
#
# Example: bash scripts/bash/task-get-todos.sh api
#          bash scripts/bash/task-get-todos.sh frontend
#
# Returns: List of task file paths (one per line), sorted by priority
# Exit codes:
#   0 — success (even if no tasks found)
#   1 — invalid args
# =============================================================================

set -euo pipefail

AGENT="${1:-}"

if [[ -z "$AGENT" ]]; then
  echo "Usage: task-get-todos.sh <agent-type>" >&2
  exit 1
fi

# Find tasks directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Default tasks dir, can be overridden via TASKS_DIR env
TASKS_DIR="${TASKS_DIR:-$CADRE_ROOT/tasks}"

if [[ ! -d "$TASKS_DIR" ]]; then
  echo "No tasks directory found at $TASKS_DIR" >&2
  exit 1
fi

# Find task files matching this agent and status TODO
# Sort by priority (P0 first, then P1, P2, etc.)
find "$TASKS_DIR" -name "*.md" -type f 2>/dev/null | while read -r f; do
  OWNER="$(grep -m1 '^\*\*Owner\*\*:' "$f" 2>/dev/null | sed 's/\*\*Owner\*\*: //' | tr -d ' ' || true)"
  STATUS="$(grep -m1 '^\*\*Status\*\*:' "$f" 2>/dev/null | sed 's/\*\*Status\*\*: //' | tr -d ' ' || true)"
  PRIORITY="$(grep -m1 '^\*\*Priority\*\*:' "$f" 2>/dev/null | sed 's/\*\*Priority\*\*: //' | tr -d ' ' || echo 'P99')"
  
  # Normalize agent name: api -> api-agent, frontend -> frontend-agent, etc.
  NORMALIZED_AGENT="$AGENT"
  case "$AGENT" in
    api) NORMALIZED_AGENT="api-agent" ;;
    frontend) NORMALIZED_AGENT="frontend-agent" ;;
    infra) NORMALIZED_AGENT="infra-agent" ;;
    analysis) NORMALIZED_AGENT="analysis-agent" ;;
    archi) NORMALIZED_AGENT="archi-agent" ;;
    inta) NORMALIZED_AGENT="inta-agent" ;;
    # Puma is just @puma (not @puma-agent)
    puma) NORMALIZED_AGENT="puma" ;;
  esac

  # Check if this task belongs to this agent and is TODO
  if [[ "$OWNER" == "@${NORMALIZED_AGENT}" ]] && [[ "$STATUS" == "TODO" ]]; then
    echo "$PRIORITY:$f"
  fi
done | sort | sed 's/^[^:]*://'
