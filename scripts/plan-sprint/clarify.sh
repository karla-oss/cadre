#!/usr/bin/env bash
# =============================================================================
# clarify.sh — P3.A Clarify
#
# Usage:
#   bash scripts/bash/clarify.sh <epic-folder>
#
# Flow:
#   1. Spawns @puma
#   2. Puma spawns @archi via sessions_spawn
#   3. Archi resolves [NEEDS CLARIFICATION] markers
#   4. Puma applies answers to spec.md
#   5. Done
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
SPEC_FILE="$EPIC_PATH/spec.md"

echo "=== P3.A Clarify ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -f "$SPEC_FILE" ]]; then
  echo "Error: spec.md not found" >&2
  exit 1
fi

MARKER_COUNT=$(grep -c "\[NEEDS CLARIFICATION:" "$SPEC_FILE" 2>/dev/null || echo "0")
echo "Markers: $MARKER_COUNT"

if [[ "$MARKER_COUNT" == "0" ]]; then
  echo "✅ No markers. Already clarified."
  exit 0
fi

echo ""
echo "Spawning @puma to execute P3.A..."
echo ""

# The task that Puma will execute
PUMA_TASK="You are @puma for SpecForge.

## Your Task: Execute P3.A Clarify

Execute P3.A Clarify for epic: $EPIC_NAME at $SPEC_FILE

## Steps:

1. Find all [NEEDS CLARIFICATION: ...] markers in $SPEC_FILE

2. Spawn @archi to answer questions:
   - Use sessions_spawn tool
   - model: minimax/MiniMax-M2.7
   - task: \"You are @archi for SpecForge.

## Project Context
- Project: SpecForge
- Stage: MVP

## Your Task
Read $SPEC_FILE, find [NEEDS CLARIFICATION] markers, and answer each question based on MVP reasoning:
- MVP = simplest that works
- If not needed for MVP, defer
- Be decisive

Answer format:
**Answer:** [what to do]
**MVP:** [1-line why]

Write answers to a file, then report done.\"

3. After @archi completes, apply answers to $SPEC_FILE:
   - Replace each [NEEDS CLARIFICATION: ...] marker with the answer
   - Add note: **Clarified:** [answer]

4. Verify no markers remain

5. Report done with summary

## Important
- Use sessions_spawn to spawn @archi
- Wait for @archi to complete before applying answers"

echo "$PUMA_TASK"
echo ""
echo "=== Spawning @puma with P3.A task ==="
