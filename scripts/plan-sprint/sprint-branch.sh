#!/usr/bin/env bash
# =============================================================================
# sprint-branch.sh — I0 Sprint Branch Creation
#
# Usage:
#   bash scripts/bash/sprint-branch.sh <epic-folder>
#
# Flow:
#   1. Create sprint branch from main
#   2. Sprint branch = signal to start implementation
#   3. All PRs will target this branch
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
PROJECT_DIR="$(dirname "$EPIC_PATH")"

echo "=== I0 Sprint Branch ==="
echo "Epic: $EPIC_NAME"
echo ""

cd "$PROJECT_DIR" || exit 1

# Check git
if [[ ! -d .git ]]; then
  echo "Error: Not a git repository" >&2
  exit 1
fi

# Branch name: sprint/S5-polish-auth
SPRINT_BRANCH="sprint/$(echo "$EPIC_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"

echo "Creating sprint branch: $SPRINT_BRANCH"

# Create sprint branch from main
git checkout main 2>/dev/null || git checkout master 2>/dev/null
git pull origin main 2>/dev/null || git pull origin master 2>/dev/null
git checkout -b "$SPRINT_BRANCH"

echo ""
echo "✅ Sprint branch created: $SPRINT_BRANCH"
echo ""
echo "This branch = signal to start implementation."
echo "All PRs should target: $SPRINT_BRANCH"
