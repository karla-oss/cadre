#!/usr/bin/env bash
# =============================================================================
# review-request.sh — CADRE Review Request Creator
#
# Usage: bash scripts/bash/review-request.sh <TASK_ID> "<what was done>"
#
# Purpose:
#   Module Agent calls this when a task is complete.
#   Creates a review-request artifact with Status: draft.
#   Agent must fill in self-check boxes, then run review-submit.sh.
#
# CADRE Invariants: I-01, I-02, I-03, I-06
# OBS-008: Two-step review protocol (create → submit)
#
# Exit codes:
#   0 — review request created successfully
#   1 — invalid args
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
  echo -e "${RED}❌ Usage: bash scripts/bash/review-request.sh <TASK_ID> \"<what was done>\"${NC}"
  echo -e "   Example: bash scripts/bash/review-request.sh T001 \"implement POST /tasks endpoint\""
  exit 1
fi

if [[ ! "$TASK_ID" =~ ^T[0-9]+$ ]]; then
  echo -e "${RED}❌ Invalid TASK_ID format: '$TASK_ID' — expected T[0-9]+ (e.g. T001, T42)${NC}"
  exit 1
fi

# 2. Check for uncommitted changes — warn but do NOT block
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo -e "${YELLOW}⚠️  You have uncommitted scratch work. Clean up before requesting review.${NC}"
fi

# 3. Create review-request/ directory if not exists
mkdir -p review-request

# 4. Create review-request/${TASK_ID}.md with Status: draft
OUTFILE="review-request/${TASK_ID}.md"
CREATED_AT="$(date -u +"%Y-%m-%d %H:%M UTC")"
AGENT="${USER:-module-agent}"
FILES_CHANGED="$(git diff HEAD --name-only 2>/dev/null || echo "[run: git diff HEAD --name-only]")"

cat > "$OUTFILE" <<TEMPLATE
# Review Request: ${TASK_ID}

**Status**: draft
**Agent**: ${AGENT}
**Created**: ${CREATED_AT}
**Description**: ${DESCRIPTION}

## What was done

${DESCRIPTION}

## Files changed

${FILES_CHANGED:-[no changes detected against HEAD]}

## Self-check vs contract

- [ ] Implementation matches contract definition
- [ ] Only touched files within owned module boundary
- [ ] No invented endpoints or entities
- [ ] Edge cases handled per spec

## Risks / open questions

[None — or describe any concerns]

---

## Architect Review

**Verdict**:
**Comment**:
**Reviewed**:
TEMPLATE

# 5. Print confirmation and next step instructions
echo -e "${GREEN}✅ Draft created: review-request/${TASK_ID}.md${NC}"
echo ""
echo -e "📝 NEXT STEP: Fill in self-check boxes in review-request/${TASK_ID}.md"
echo -e "   Then run: bash scripts/bash/review-submit.sh ${TASK_ID}"
exit 0
