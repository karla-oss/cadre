#!/usr/bin/env bash
# =============================================================================
# readiness.sh — P5 Readiness Gate
#
# Usage:
#   bash scripts/bash/readiness.sh <epic-folder>
#
# Flow:
#   1. Spawns @archi
#   2. Archi reviews plan quality
#   3. Archi writes gate report
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
REPORT_FILE="$EPIC_PATH/readiness-gate.md"

echo "=== P5 Readiness Gate ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "Error: plan.md not found. Run plan.sh first." >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Spawning @archi for readiness gate..."
echo ""

ARCHI_TASK="You are @archi for SpecForge.

## Project Context
- Project: SpecForge
- Stage: MVP

## Your Task: P5 Readiness Gate

Review plan quality for: $EPIC_NAME

Read:
- Spec: $SPEC_FILE
- Plan: $PLAN_FILE

## Gate Checks

Is the plan ready for task generation?

1. **Completeness** — does plan cover all spec requirements?
2. **Feasibility** — can it be implemented in MVP scope?
3. **Module coverage** — all modules covered (@api-agent, @frontend-agent)?
4. **Dependencies** — clear implementation order?
5. **Risks** — documented?

## Output

Write gate report to: $REPORT_FILE

Format:
\`\`\`markdown
# Readiness Gate: $EPIC_NAME

**Date**: [date]
**Status**: PASS | FAIL

## Checks
- Completeness: PASS | FAIL
- Feasibility: PASS | FAIL
- Module coverage: PASS | FAIL
- Dependencies: PASS | FAIL
- Risks: PASS | FAIL

## Issues (if any)
1. [Issue] → [Fix]

## Overall
**Result**: PASS | FAIL
\`\`\`

Be thorough. Report PASS only if plan is ready for tasks.

Report done."

echo "$ARCHI_TASK"
echo ""
echo "=== Spawning @archi ==="
