#!/usr/bin/env bash
# =============================================================================
# on-review-request.sh — Hook runs when review is requested
#
# Triggered when a task is marked READY_FOR_REVIEW.
# Spawns @archi-agent to review the changes.
#
# Usage: bash scripts/hooks/on-review-request.sh <task-id>
#
# Example: bash scripts/hooks/on-review-request.sh FE-EXPORT-001
# =============================================================================

set -euo pipefail

TASK_ID="${1:-}"

if [[ -z "$TASK_ID" ]]; then
  echo "Usage: on-review-request.sh <task-id>" >&2
  exit 1
fi

echo "=== Review Request Hook ==="
echo "Review requested for: $TASK_ID"
echo "Spawning @archi-agent for review..."

# Note: Actual spawn is done by Super
# This hook notifies that review is needed

echo "=== Hook Complete ==="
echo "Run 'spawn-agent.sh --task <review-request> --agent archi' manually or via Super."
