#!/usr/bin/env bash
# =============================================================================
# implement.sh — Implementation Phase Spawner
#
# Usage:
#   bash scripts/implement/implement.sh <epic-folder>
#
# This script generates the task manifest for main agent to spawn coder agents.
#
# IMPORTANT: Use agentId="coder" for implementation tasks!
#   - coder has semantic retrieval (qdrant)
#   - Token cost: ~1-10k vs ~500k for generic subagent
#   - Reduction: 50-500x cheaper!
#
# Example spawn command:
#   sessions_spawn(
#     task="Add skeleton loading to ProjectList.tsx",
#     agentId="coder",  # ← USE CODER, NOT generic subagent!
#     runtime="subagent"
#   )
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
CONFIG_FILE="$CADRE_ROOT/cadre-config.yml"

echo "=== I1 Implementation Phase ==="
echo "Epic: $EPIC_NAME"
echo ""

# -----------------------------------
# Read pool config
# -----------------------------------
MAX_TOTAL=5
MAX_PER_TYPE=3

if [[ -f "$CONFIG_FILE" ]]; then
  MAX_TOTAL=$(grep "max_total:" "$CONFIG_FILE" | awk '{print $2}' || echo "5")
  MAX_PER_TYPE=$(grep "max_per_type:" "$CONFIG_FILE" | awk '{print $2}' || echo "3")
fi

# -----------------------------------
# Find TODO tasks
# -----------------------------------
TASKS=$(find "$TASKS_DIR" -name "T*.md" 2>/dev/null | sort)

if [[ -z "$TASKS" ]]; then
  echo "No tasks found in $TASKS_DIR"
  exit 0
fi

# -----------------------------------
# Generate JSON manifest
# -----------------------------------
echo "{"
echo "  \"epic\": \"$EPIC_NAME\","
echo "  \"pool\": { \"max_total\": $MAX_TOTAL, \"max_per_type\": $MAX_PER_TYPE },"
echo "  \"agent_type\": \"coder\","
echo "  \"note\": \"Use agentId='coder' for implementation - has qdrant retrieval\","
echo "  \"tasks\": ["

FIRST=true
while IFS= read -r TASK_FILE; do
  TASK_ID=$(basename "$TASK_FILE" .md)
  MODULE=$(grep "^module:" "$TASK_FILE" | awk '{print $2}' || echo "unknown")
  TITLE=$(grep "^title:" "$TASK_FILE" | sed 's/title: "//' | sed 's/"$//' || echo "")
  STATUS=$(grep "^status:" "$TASK_FILE" | awk '{print $2}' || echo "TODO")
  
  if [[ "$STATUS" == "TODO" ]]; then
    if [[ "$FIRST" == true ]]; then
      FIRST=false
    else
      echo ","
    fi
    
    echo "    {"
    echo "      \"id\": \"$TASK_ID\","
    echo "      \"module\": \"$MODULE\","
    echo "      \"title\": \"$TITLE\","
    echo "      \"file\": \"$TASK_FILE\""
    echo -n "    }"
  fi
done <<< "$TASKS"

echo ""
echo "  ]"
echo "}"
