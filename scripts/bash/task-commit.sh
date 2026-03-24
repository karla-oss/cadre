#!/usr/bin/env bash
# =============================================================================
# task-commit.sh — CADRE Task Commit Enforcer
#
# Usage: bash scripts/bash/task-commit.sh <TASK_ID> "<description>" [--path <dir>]
#
# Purpose:
#   Enforce "task = commit" rule (CADRE NOTE-001).
#   Each completed task must be committed immediately with a standardized
#   message before proceeding to the next task.
#
# Convention: "<TASK_ID>: <description>"
# Example:    "T001: create api/ directory structure"
#
# Options:
#   --path <dir>   Stage only files under <dir> instead of all changes (git add -A)
#
# CADRE Invariants: I-04 (Artifact-Driven), I-07 (Jira Surface)
# OBS-007: --path flag for module boundary scoping
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
STAGE_PATH=""

# Parse optional --path flag
if [[ "${3:-}" == "--path" ]]; then
  if [[ -z "${4:-}" ]]; then
    echo -e "${RED}❌ --path flag requires a directory argument${NC}"
    echo -e "   Example: bash scripts/bash/task-commit.sh T001 \"description\" --path api/"
    exit 1
  fi
  STAGE_PATH="${4}"
fi

if [[ -z "$TASK_ID" || -z "$DESCRIPTION" ]]; then
  echo -e "${RED}❌ Usage: bash scripts/bash/task-commit.sh <TASK_ID> \"<description>\" [--path <dir>]${NC}"
  echo -e "   Example: bash scripts/bash/task-commit.sh T001 \"create api/ directory structure\""
  echo -e "   Example: bash scripts/bash/task-commit.sh T001 \"create api/ directory structure\" --path api/"
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

if [[ -n "$STAGE_PATH" ]]; then
  git add "$STAGE_PATH"
  echo -e "${GREEN}📁 Staging path: ${STAGE_PATH}${NC}"

  # Warn if there are cross-boundary files in the staged area
  STAGED_OUTSIDE="$(git diff --cached --name-only | grep -v "^$(echo "$STAGE_PATH" | sed 's|/$||')" || true)"
  if [[ -n "$STAGED_OUTSIDE" ]]; then
    echo -e "${YELLOW}⚠️  WARN: Staged files outside --path boundary:${NC}"
    echo "$STAGED_OUTSIDE" | while read -r f; do
      echo -e "${YELLOW}   $f${NC}"
    done
  fi
else
  git add -A
fi

git commit -m "$COMMIT_MSG"

echo -e "${GREEN}✅ Committed: $COMMIT_MSG${NC}"
echo -e "${GREEN}   $(git rev-parse --short HEAD)${NC}"
