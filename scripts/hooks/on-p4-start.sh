#!/usr/bin/env bash
# =============================================================================
# on-p4-start.sh — Hook runs when P4 (Plan) phase starts
#
# Spawns @puma to begin planning: create tasks, write specs.
#
# Usage: bash scripts/hooks/on-p4-start.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo "=== P4 Start Hook ==="
echo "Spawning @puma for planning..."

# Check if puma-context.md exists
if [[ ! -f "$CADRE_ROOT/../puma-context.md" ]]; then
  echo "WARNING: puma-context.md not found!"
  echo "Run: bash scripts/bash/puma-init.sh first"
fi

echo ""
echo "To spawn Puma:"
echo "  spawn-agent.sh --no-task --agent puma"
echo ""
echo "Or spawn with specific task:"
echo "  spawn-agent.sh --task <spec-file> --agent puma"
echo ""
echo "=== Hook Complete ==="
