#!/usr/bin/env bash
# =============================================================================
# validate.sh — I6 Validate Epic
#
# Usage:
#   bash scripts/bash/validate.sh <epic-folder>
#
# Flow:
#   @Archi validates all tasks are complete
#   Super approves epic close
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
TASKS_DIR="$EPIC_PATH/tasks"
REPORT_FILE="$EPIC_PATH/validation-report.md"

echo "=== I6 Validate Epic ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -f "$SPEC_FILE" ]]; then
  echo "Error: spec.md not found" >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Spawning @archi for validation..."
echo ""

ARCHI_TASK="You are @archi for SpecForge.

## Project Context
- Project: SpecForge
- Stage: MVP

## Your Task: I6 Validate Epic

Validate epic completion.

Read:
- Spec: $SPEC_FILE
- Tasks: $TASKS_DIR/*.md

## Validation Checklist
For each task:
- Status is DONE?
- All acceptance criteria met?
- PR merged?

Check:
- All tasks Done?
- All PRs merged?
- Integration tests pass?
- Acceptance criteria met?
- No blockers?

## Output

Write validation report to: $REPORT_FILE

Format:
# Validation Report: $EPIC_NAME

## Status
- Total tasks: N
- Done: N
- Blocked: N

## Checklist
- [ ] All tasks Done
- [ ] All PRs merged
- [ ] Integration tests pass
- [ ] Acceptance criteria met
- [ ] No blockers

## Super Approval
Waiting for Super sign-off to close epic.

Report done."

echo "$ARCHI_TASK"
echo ""
echo "=== Spawning @archi ==="