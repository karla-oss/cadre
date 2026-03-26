#!/usr/bin/env bash
# =============================================================================
# review-prs.sh — I4 Code Review
#
# Usage:
#   bash scripts/bash/review-prs.sh <epic-folder>
#
# Flow:
#   Spawns @Archi to review PRs
#   @Archi APPROVES and MERGES
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

echo "=== I4 Code Review ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -d "$TASKS_DIR" ]]; then
  echo "Error: tasks/ not found" >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Spawning @archi for code review..."
echo ""

ARCHI_TASK="You are @archi for SpecForge.

## Project Context
- Project: SpecForge
- Stage: MVP

## Your Task: I4 Code Review

Review PRs for code quality and merge.

Read:
- Tasks: $TASKS_DIR/*.md (filter READY_FOR_REVIEW status with PR links)
- Spec: $EPIC_PATH/spec.md
- Plan: $EPIC_PATH/plan.md

## Review Checks
For each PR:
1. Read PR diff
2. Validate:
   - Code quality
   - Spec compliance
   - Micro-module rules (small files, max 100 lines)
   - No security issues
   - Tests pass
3. If OK:
   - APPROVED → MERGE PR
4. If issues:
   - NEEDS_WORK → add comment

## Key Rule
APPROVED = MERGE immediately.

## Output
Write review summary to: $EPIC_PATH/review-summary.md

Report done."

echo "$ARCHI_TASK"
echo ""
echo "=== Spawning @archi ==="