#!/usr/bin/env bash
# =============================================================================
# preflight_assessment.sh — P6b Preflight Assessment
#
# Usage:
#   bash scripts/bash/preflight_assessment.sh <epic-folder>
#
# Flow:
#   1. Spawns @archi
#   2. Archi reviews tasks for correctness, contracts, dependencies
#   3. Archi writes preflight report
#   4. Done
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
PLAN_FILE="$EPIC_PATH/plan.md"
TASKS_DIR="$EPIC_PATH/tasks"
REPORT_FILE="$EPIC_PATH/preflight-report.md"

echo "=== P6b Preflight Assessment ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -d "$TASKS_DIR" ]]; then
  echo "Error: tasks/ not found. Run make_tasks.sh first." >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Spawning @archi for preflight assessment..."
echo ""

ARCHI_TASK="You are @archi for SpecForge.

## Project Context
- Project: SpecForge
- Stage: MVP

## Your Task: P6b Preflight Assessment

Review implementation tasks for: $EPIC_NAME

Read:
- Spec: $SPEC_FILE
- Plan: $PLAN_FILE
- Tasks: $TASKS_DIR/*.md

## Preflight Checks

For each task, check:
1. **Correctness** — does the task match the spec?
2. **Completeness** — all files covered?
3. **Dependencies** — correct order? all dependencies met?
4. **Contracts** — no breaking changes to frozen contracts?
5. **Conflicts** — no module overlap or git conflicts?

## Output

Write report to: $REPORT_FILE

Format:
\`\`\`markdown
# Preflight Assessment: $EPIC_NAME

**Date**: [date]
**Status**: PASS | FAIL

## Task Reviews

### T001
- Status: OK | ISSUE
- [Finding]

## Summary
- Total tasks: N
- Passed: N
- Issues: N

## Issues (if any)
1. [Issue] → [Fix]
\`\`\`

Be thorough. Report PASS only if truly ready for implementation.

Report done."

echo "$ARCHI_TASK"
echo ""
echo "=== Spawning @archi ==="
