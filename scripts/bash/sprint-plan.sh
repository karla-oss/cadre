#!/usr/bin/env bash
# =============================================================================
# sprint-plan.sh — Sprint Planning Master Script
#
# Usage:
#   bash scripts/bash/sprint-plan.sh <epic-folder>
#
# Runs entire planning phase P1-P8:
#   P1 specify → P2 clarify → P3 assess → P4 plan → P5 readiness → P6 tasks → P7 preflight → P8 sprint-branch
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

echo "============================================"
echo "SPRINT PLANNING — $EPIC_NAME"
echo "============================================"
echo ""

# P1: Specify
echo "[P1] Specify — @Puma fills spec"
echo "----------------------------------------"
bash "$SCRIPT_DIR/specify.sh" "$EPIC_PATH"
echo ""

# P2: Clarify
echo "[P2] Clarify — @Archi resolves markers"
echo "----------------------------------------"
bash "$SCRIPT_DIR/clarify.sh" "$EPIC_PATH"
echo ""

# P3: Assess
echo "[P3] Assess — @Archi checks contradictions, drift"
echo "----------------------------------------"
bash "$SCRIPT_DIR/readiness_assessment.sh" "$EPIC_PATH"
echo ""

# P4: Plan
echo "[P4] Plan — @Archi creates technical plan"
echo "----------------------------------------"
bash "$SCRIPT_DIR/plan.sh" "$EPIC_PATH"
echo ""

# P5: Readiness
echo "[P5] Readiness — @Archi gates plan quality"
echo "----------------------------------------"
bash "$SCRIPT_DIR/readiness.sh" "$EPIC_PATH"
echo ""

# P6: Tasks
echo "[P6] Tasks — @Puma generates tasks"
echo "----------------------------------------"
bash "$SCRIPT_DIR/make_tasks.sh" "$EPIC_PATH"
echo ""

# P7: Preflight
echo "[P7] Preflight — @Archi final check"
echo "----------------------------------------"
bash "$SCRIPT_DIR/preflight_assessment.sh" "$EPIC_PATH"
echo ""

# P8: Sprint Branch
echo "[P8] Sprint Branch — @Archi creates sprint branch"
echo "----------------------------------------"
bash "$SCRIPT_DIR/sprint-branch.sh" "$EPIC_PATH"
echo ""

echo "============================================"
echo "SPRINT PLANNING COMPLETE"
echo "============================================"
echo ""
echo "Sprint branch created. Implementation phase can start."
