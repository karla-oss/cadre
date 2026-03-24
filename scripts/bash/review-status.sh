#!/usr/bin/env bash
# =============================================================================
# review-status.sh — CADRE Review Queue
#
# Usage: bash scripts/bash/review-status.sh
#
# Purpose:
#   Show current review queue grouped by status.
#   Archi runs this to see what needs review.
#
# Exit codes:
#   0 — always
# =============================================================================

set -euo pipefail

NC='\033[0m'
BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'

# 1. Check if review-request/ directory exists
if [[ ! -d "review-request" ]]; then
  echo "No review requests found."
  exit 0
fi

# Collect all .md files
mapfile -t FILES < <(find review-request -maxdepth 1 -name "*.md" | sort)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No review requests found."
  exit 0
fi

# 2. Parse each file
declare -a READY=()
declare -a NEEDS_WORK=()
declare -a APPROVED=()

for FILE in "${FILES[@]}"; do
  TASK_ID="$(basename "$FILE" .md)"
  STATUS="$(grep -m1 '^\*\*Status\*\*:' "$FILE" 2>/dev/null | sed 's/\*\*Status\*\*: //' | tr -d '\r')"
  AGENT="$(grep -m1 '^\*\*Agent\*\*:' "$FILE" 2>/dev/null | sed 's/\*\*Agent\*\*: //' | tr -d '\r')"
  CREATED="$(grep -m1 '^\*\*Created\*\*:' "$FILE" 2>/dev/null | sed 's/\*\*Created\*\*: //' | tr -d '\r')"
  DESCRIPTION="$(grep -m1 '^\*\*Description\*\*:' "$FILE" 2>/dev/null | sed 's/\*\*Description\*\*: //' | tr -d '\r')"
  COMMENT="$(grep -m1 '^\*\*Comment\*\*:' "$FILE" 2>/dev/null | sed 's/\*\*Comment\*\*: //' | tr -d '\r')"

  case "$STATUS" in
    ready-for-review)
      READY+=("${TASK_ID}|${AGENT}|${CREATED}|${DESCRIPTION}")
      ;;
    needs-work)
      NEEDS_WORK+=("${TASK_ID}|${AGENT}|${COMMENT}")
      ;;
    approved)
      APPROVED+=("${TASK_ID}")
      ;;
    *)
      NEEDS_WORK+=("${TASK_ID}|unknown|unknown status: ${STATUS}")
      ;;
  esac
done

# 3. Print grouped output
echo -e "${BOLD}📋 CADRE Review Queue${NC}"
echo ""

# READY FOR REVIEW
COUNT=${#READY[@]}
echo -e "${CYAN}READY FOR REVIEW (${COUNT}):${NC}"
if [[ $COUNT -eq 0 ]]; then
  echo -e "  ${GRAY}(none)${NC}"
else
  for ENTRY in "${READY[@]}"; do
    IFS='|' read -r TID AGENT CREATED DESC <<< "$ENTRY"
    echo -e "  ${BOLD}${TID}${NC} — @${AGENT} — ${CREATED} — \"${DESC}\""
  done
fi

echo ""

# NEEDS WORK
COUNT=${#NEEDS_WORK[@]}
echo -e "${YELLOW}NEEDS_WORK (${COUNT}):${NC}"
if [[ $COUNT -eq 0 ]]; then
  echo -e "  ${GRAY}(none)${NC}"
else
  for ENTRY in "${NEEDS_WORK[@]}"; do
    IFS='|' read -r TID AGENT COMMENT <<< "$ENTRY"
    echo -e "  ${BOLD}${TID}${NC} — @${AGENT} — comment: \"${COMMENT}\""
  done
fi

echo ""

# APPROVED
COUNT=${#APPROVED[@]}
echo -e "${GREEN}APPROVED (${COUNT}):${NC}"
if [[ $COUNT -eq 0 ]]; then
  echo -e "  ${GRAY}(none)${NC}"
else
  echo -e "  ${APPROVED[*]}"
fi

echo ""

# Summary
READY_COUNT=${#READY[@]}
if [[ $READY_COUNT -eq 0 ]]; then
  echo -e "${GREEN}✅ Queue empty — nothing to review.${NC}"
else
  echo -e "${YELLOW}⚡ ${READY_COUNT} task(s) waiting for Archi review.${NC}"
fi

exit 0
