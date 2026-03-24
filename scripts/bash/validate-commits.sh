#!/usr/bin/env bash
# =============================================================================
# validate-commits.sh — CADRE Commit Audit
#
# Usage: bash scripts/bash/validate-commits.sh <tasks_file> [branch]
#
# Purpose:
#   Audit git history to verify each task in tasks.md has a corresponding
#   commit. Reports missing task commits as warnings before Phase 7 (Polish).
#
# CADRE Invariants: I-04 (Artifact-Driven), NOTE-001 (task = commit)
#
# Exit codes:
#   0 — all tasks have commits (or no tasks file found)
#   1 — one or more tasks missing commits
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

TASKS_FILE="${1:-}"
BRANCH="${2:-HEAD}"

if [[ -z "$TASKS_FILE" ]]; then
  echo -e "${RED}❌ Usage: bash scripts/bash/validate-commits.sh <tasks_file> [branch]${NC}"
  echo -e "   Example: bash scripts/bash/validate-commits.sh specs/001-feature/tasks.md"
  exit 1
fi

if [[ ! -f "$TASKS_FILE" ]]; then
  echo -e "${RED}❌ tasks.md not found: $TASKS_FILE${NC}"
  exit 1
fi

echo -e "${CYAN}📋 CADRE Commit Audit — $TASKS_FILE${NC}"
echo ""

# Extract all task IDs from tasks.md (format: T001, T002, ...)
task_ids=$(grep -oE '\bT[0-9]{3,}\b' "$TASKS_FILE" | sort -u)

if [[ -z "$task_ids" ]]; then
  echo -e "${YELLOW}⚠️  No task IDs found in $TASKS_FILE${NC}"
  exit 0
fi

# Get all commit messages from git log
commit_log=$(git log "$BRANCH" --oneline 2>/dev/null || true)

missing=()
found=()

while IFS= read -r task_id; do
  if echo "$commit_log" | grep -qE "^[a-f0-9]+ ${task_id}:"; then
    found+=("$task_id")
  else
    missing+=("$task_id")
  fi
done <<< "$task_ids"

total=${#found[@]}
total_missing=${#missing[@]}

# Report found
if [[ ${#found[@]} -gt 0 ]]; then
  echo -e "${GREEN}✅ Tasks with commits (${#found[@]}):${NC}"
  for t in "${found[@]}"; do
    commit=$(echo "$commit_log" | grep -E "^[a-f0-9]+ ${t}:" | head -1)
    echo -e "   ${GREEN}${commit}${NC}"
  done
  echo ""
fi

# Report missing
if [[ ${#missing[@]} -gt 0 ]]; then
  echo -e "${RED}❌ Tasks WITHOUT commits (${#missing[@]}):${NC}"
  for t in "${missing[@]}"; do
    echo -e "   ${RED}$t — no commit found${NC}"
  done
  echo ""
  echo -e "${YELLOW}📋 NOTE-001 violation: task = commit rule broken.${NC}"
  echo -e "${YELLOW}   Run: bash scripts/bash/task-commit.sh <TASK_ID> \"<description>\"${NC}"
  exit 1
else
  echo -e "${GREEN}✅ All $total tasks have corresponding commits. NOTE-001 satisfied.${NC}"
  exit 0
fi
