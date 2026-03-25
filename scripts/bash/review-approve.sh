#!/usr/bin/env bash
# =============================================================================
# review-approve.sh — CADRE Review Approver
#
# Usage: bash scripts/bash/review-approve.sh <TASK_ID> "<commit description>"
#
# Purpose:
#   Archi calls this after approving a task.
#   Updates the review-request file, commits, marks done.
#
# CADRE Invariants: I-01, I-06, NOTE-001
#
# Exit codes:
#   0 — approved and committed
#   1 — error (missing file, wrong status, invalid args)
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TASK_ID="${1:-}"
DESCRIPTION="${2:-}"

# 1. Validate args
if [[ -z "$TASK_ID" || -z "$DESCRIPTION" ]]; then
  echo -e "${RED}❌ Usage: bash scripts/bash/review-approve.sh <TASK_ID> \"<commit description>\"${NC}"
  echo -e "   Example: bash scripts/bash/review-approve.sh T001 \"implement POST /tasks endpoint\""
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
  echo -e "${RED}❌ Cannot approve: status is '${CURRENT_STATUS}' (expected ready-for-review)${NC}"
  exit 1
fi

# 4. Update verdict section
REVIEWED_AT="$(date -u +"%Y-%m-%d %H:%M UTC")"

# Update Status line
sed -i "s/^\*\*Status\*\*: ready-for-review/**Status**: approved/" "$REQFILE"

# Update Verdict, Comment, Reviewed lines
sed -i "s/^\*\*Verdict\*\*:.*/**Verdict**: APPROVED/" "$REQFILE"
sed -i "s/^\*\*Comment\*\*:.*/**Comment**: —/" "$REQFILE"
sed -i "s/^\*\*Reviewed\*\*:.*/**Reviewed**: ${REVIEWED_AT}/" "$REQFILE"

# 5. Commit via task-commit.sh
bash "$(dirname "$0")/task-commit.sh" "${TASK_ID}" "${DESCRIPTION}"

# 6. Check if this was the last task — remind about integrate
REMAINING=$(grep -c "^\[ \]" review-request/*.md 2>/dev/null || echo "0")
if [[ "$REMAINING" == "0" ]]; then
  echo -e "${YELLOW}⚠️  Last task approved. Run /cadre.integrate before /cadre.validate.${NC}"
fi

# 7. Print confirmation
echo -e "${GREEN}✅ APPROVED: ${TASK_ID}${NC}"
echo -e "   Committed. Task → Done."
exit 0
