#!/usr/bin/env bash
# =============================================================================
# readiness_assessment.sh — P3.B Readiness Assessment
#
# Usage:
#   bash scripts/bash/readiness_assessment.sh <epic-folder>
#
# Flow:
#   1. Spawns @puma
#   2. Puma spawns @archi via sessions_spawn
#   3. Archi validates + provides fixes if needed
#   4. Puma applies fixes
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
ASSESSMENT_FILE="$EPIC_PATH/assessment-report.md"

echo "=== P3.B Readiness Assessment ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -f "$SPEC_FILE" ]]; then
  echo "Error: spec.md not found" >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Spawning @puma to execute P3.B..."
echo ""
echo "Puma will:"
echo "  1. Spawn @archi"
echo "  2. Archi validates + provides fixes"
echo "  3. Puma applies fixes"
echo "  4. Done"
echo ""

PUMA_TASK="You are @puma for SpecForge.

## Your Task: Execute P3.B Readiness Assessment

Execute P3.B Readiness Assessment for epic: $EPIC_NAME at $SPEC_FILE

## Steps:

1. Spawn @archi to run assessment with fixes:
   - Use sessions_spawn tool
   - model: minimax/MiniMax-M2.7
   - label: archi-readiness
   - task: \"You are @archi for SpecForge.

Project: SpecForge, Stage: MVP

Read: $SPEC_FILE

## Assessment Dimensions
- Completeness — all sections filled?
- Contradictions — conflicting statements?
- Drift — deviations from plan?
- Technical — feasibility, MVP violations?
- Contracts — dependencies documented?

## If issues found:
For each issue, provide:
- What to fix
- How to fix it (specific changes)

## Output
Write assessment to: $ASSESSMENT_FILE

Format:
# Readiness Assessment: $EPIC_NAME
Date: [date]
Status: PASS | FAIL

[each check with findings]

If FAIL, include FIXES section:
## Fixes Required
1. [issue] → [fix]
2. [issue] → [fix]

Report done.\"

2. Wait for @archi to complete

3. After @archi completes, apply fixes:
   - Read $ASSESSMENT_FILE
   - If Status: FAIL, apply each fix to $SPEC_FILE
   - If Status: PASS, no changes needed

4. Verify changes applied

5. Report done with summary

## Important
- Use sessions_spawn to spawn @archi
- Wait for @archi to complete before applying fixes"

echo "$PUMA_TASK"
echo ""
echo "=== Spawning @puma with P3.B task ==="
