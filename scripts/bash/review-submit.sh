#!/usr/bin/env bash
# =============================================================================
# review-submit.sh — CADRE Review Submission (Step 2)
#
# Usage: bash scripts/bash/review-submit.sh <TASK_ID>
#
# Purpose:
#   Second step of the two-step review protocol (OBS-008).
#   Validates self-check boxes and transitions status to ready-for-review.
#
#   Step 1: review-request.sh  → creates draft
#   Step 2: review-submit.sh   → validates + submits
#
# CADRE Invariants: I-01, I-02, I-03, I-06
# C3 Gate: all self-check boxes must be [x] before submission
#
# Exit codes:
#   0 — submitted successfully
#   1 — validation failed or invalid args
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TASK_ID="${1:-}"

# 1. Validate args
if [[ -z "$TASK_ID" ]]; then
  echo -e "${RED}❌ Usage: bash scripts/bash/review-submit.sh <TASK_ID>${NC}"
  echo -e "   Example: bash scripts/bash/review-submit.sh T001"
  exit 1
fi

RECORD_FILE="review-request/${TASK_ID}.md"

# 2. Check review-request/<TASK_ID>.md exists
if [[ ! -f "$RECORD_FILE" ]]; then
  echo -e "${RED}❌ Review request not found: ${RECORD_FILE}${NC}"
  echo -e "   Run first: bash scripts/bash/review-request.sh ${TASK_ID} \"<description>\""
  exit 1
fi

# 3. Check Status is NOT already ready-for-review (prevent double-submit)
CURRENT_STATUS="$(grep -m1 '^\*\*Status\*\*:' "$RECORD_FILE" 2>/dev/null | sed 's/\*\*Status\*\*: //' | tr -d '\r')"
if [[ "$CURRENT_STATUS" == "ready-for-review" ]]; then
  echo -e "${YELLOW}⚠️  Task ${TASK_ID} is already ready-for-review — skipping double-submit.${NC}"
  exit 1
fi

# 4. C3 Gate: ALL self-check boxes must be [x]
if grep -qF -- "- [ ]" "$RECORD_FILE" 2>/dev/null; then
  echo -e "${RED}❌ C3 GATE BLOCKED: Fill in self-check boxes first${NC}"
  echo -e "${RED}   Open: ${RECORD_FILE}${NC}"
  echo -e "${YELLOW}   Change '- [ ]' to '- [x]' for each completed item.${NC}"
  exit 1
fi

# 5. Update Status: draft/needs-work → ready-for-review
sed -i "s/^\*\*Status\*\*: .*/\*\*Status\*\*: ready-for-review/" "$RECORD_FILE"

# 6. Confirm
echo -e "${GREEN}✅ Task ${TASK_ID} → Ready for Review. Archi: run review-status.sh${NC}"
exit 0
