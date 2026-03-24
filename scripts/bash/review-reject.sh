#!/usr/bin/env bash
# =============================================================================
# review-reject.sh — CADRE Review Rejector
#
# Usage: bash scripts/bash/review-reject.sh <TASK_ID> "<comment>"
#
# Purpose:
#   Archi calls this when a task needs work.
#   Updates the review-request file, moves task back to In Progress.
#
# CADRE Invariants: I-01, I-02, I-03, I-06
#
# Exit codes:
#   0 — rejection recorded
#   1 — error (missing file, wrong status, missing comment)
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TASK_ID="${1:-}"
COMMENT="${2:-}"

# 1. Validate args — COMMENT is required (cannot reject without reason)
if [[ -z "$TASK_ID" || -z "$COMMENT" ]]; then
  echo -e "${RED}❌ Usage: bash scripts/bash/review-reject.sh <TASK_ID> \"<comment>\"${NC}"
  echo -e "   Example: bash scripts/bash/review-reject.sh T001 \"FK constraint not handled — see contracts/tasks.yml line 42\""
  echo -e "   Note: comment is required. 'Fix it' is not acceptable — reference the specific contract/spec."
  exit 1
fi

# 2. Check review-request file exists
REQFILE="review-request/${TASK_ID}.md"
if [[ ! -f "$REQFILE" ]]; then
  echo -e "${RED}❌ Review request not found: ${REQFILE}${NC}"
  echo -e "   Has the Module Agent run review-request.sh for ${TASK_ID}?"
  exit 1
fi

# 3. Check status is ready-for-review
CURRENT_STATUS="$(grep -m1 '^\*\*Status\*\*:' "$REQFILE" | sed 's/\*\*Status\*\*: //')"
if [[ "$CURRENT_STATUS" != "ready-for-review" ]]; then
  echo -e "${RED}❌ Cannot reject: status is '${CURRENT_STATUS}' (expected ready-for-review)${NC}"
  exit 1
fi

# 4. Update verdict section
REVIEWED_AT="$(date -u +"%Y-%m-%d %H:%M UTC")"

# Update Status line
sed -i "s/^\*\*Status\*\*: ready-for-review/**Status**: needs-work/" "$REQFILE"

# Update Verdict, Comment, Reviewed lines
sed -i "s/^\*\*Verdict\*\*:.*/**Verdict**: NEEDS_WORK/" "$REQFILE"
sed -i "s/^\*\*Comment\*\*:.*/**Comment**: ${COMMENT}/" "$REQFILE"
sed -i "s/^\*\*Reviewed\*\*:.*/**Reviewed**: ${REVIEWED_AT}/" "$REQFILE"

# 5. Print rejection details
echo -e "${RED}❌ NEEDS_WORK: ${TASK_ID}${NC}"
echo -e "   Comment: ${COMMENT}"
echo -e "   Task → back to In Progress"
echo -e "   Module agent: read ${REQFILE}, fix issues, re-run review-request.sh"
exit 0
