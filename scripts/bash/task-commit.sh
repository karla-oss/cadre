#!/usr/bin/env bash
# =============================================================================
# task-commit.sh — CADRE Task Commit Enforcer
#
# Usage: bash scripts/bash/task-commit.sh <TASK_ID> "<description>"
#
# Purpose:
#   Enforce "task = commit" rule (CADRE NOTE-001).
#   Each completed task must be committed immediately with a standardized
#   message before proceeding to the next task.
#
# Convention: "<TASK_ID>: <description>"
# Example:    "T001: create api/ directory structure"
#
# CADRE Invariants: I-04 (Artifact-Driven), I-07 (Jira Surface)
#
# Exit codes:
#   0 — committed successfully
#   1 — nothing to commit or invalid args
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TASK_ID="${1:-}"
DESCRIPTION="${2:-}"

if [[ -z "$TASK_ID" || -z "$DESCRIPTION" ]]; then
  echo -e "${RED}❌ Usage: bash scripts/bash/task-commit.sh <TASK_ID> \"<description>\"${NC}"
  echo -e "   Example: bash scripts/bash/task-commit.sh T001 \"create api/ directory structure\""
  exit 1
fi

# Validate task ID format
if [[ ! "$TASK_ID" =~ ^T[0-9]{3,}$ ]]; then
  echo -e "${YELLOW}⚠️  Warning: Task ID '$TASK_ID' doesn't match expected format T000${NC}"
fi

# Check if there's anything to commit
if git diff --quiet && git diff --cached --quiet && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
  echo -e "${YELLOW}⚠️  Nothing to commit for $TASK_ID — working tree clean${NC}"
  exit 1
fi

COMMIT_MSG="${TASK_ID}: ${DESCRIPTION}"

git add -A
git commit -m "$COMMIT_MSG"

echo -e "${GREEN}✅ Committed: $COMMIT_MSG${NC}"
echo -e "${GREEN}   $(git rev-parse --short HEAD)${NC}"
