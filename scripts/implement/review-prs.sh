#!/usr/bin/env bash
# =============================================================================
# review-prs.sh — I4 Code Review + Merge
#
# Usage:
#   bash scripts/implement/review-prs.sh <epic-folder> [PR_NUMBER]
#
# Called by: Git Hook (on PR approved)
#
# Flow:
#   1. Spawns @Archi agent
#   2. @Archi reads PR diff
#   3. @Archi validates: code quality, SPEC compliance, micro-modules
#   4. If OK: APPROVED → MERGE PR
#   5. If issues: NEEDS_WORK → PR comment
# =============================================================================

set -euo pipefail

ORIG_CWD="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

EPIC_PATH="${1:-}"
PR_NUMBER="${2:-}"

if [[ -z "$EPIC_PATH" ]]; then
  echo "Usage: $0 <epic-folder> [PR_NUMBER]" >&2
  echo "Example: $0 specs/S5-polish---auth 42" >&2
  exit 1
fi

if [[ "$EPIC_PATH" != /* ]]; then
  EPIC_PATH="${ORIG_CWD}/${EPIC_PATH}"
fi

EPIC_NAME=$(basename "$EPIC_PATH")
SPEC_FILE="$EPIC_PATH/spec.md"
PLAN_FILE="$EPIC_PATH/plan.md"

echo "=== I4 Code Review + Merge ==="
echo "Epic: $EPIC_NAME"
echo ""

# Get PR info if gh is available and PR_NUMBER provided
if command -v gh &> /dev/null && [[ -n "$PR_NUMBER" ]]; then
  echo "Fetching PR #$PR_NUMBER..."
  PR_TITLE=$(gh pr view "$PR_NUMBER" --json title --jq '.title' 2>/dev/null || echo "Unknown")
  PR_URL=$(gh pr view "$PR_NUMBER" --json url --jq '.url' 2>/dev/null || echo "")
  PR_STATE=$(gh pr view "$PR_NUMBER" --json state --jq '.state' 2>/dev/null || echo "UNKNOWN")
  
  echo "PR #$PR_NUMBER: $PR_TITLE"
  echo "State: $PR_STATE"
  echo ""
  
  if [[ "$PR_STATE" != "OPEN" ]]; then
    echo "PR is not open. Skipping."
    exit 0
  fi
fi

echo "✅ Script ready"
echo ""
echo "Spawning @archi for code review..."
echo ""

ARCHI_TASK="You are @archi for SpecForge.

## Project Context
- Project: SpecForge
- Stage: MVP
- Spec: $EPIC_NAME at $SPEC_FILE
- Plan: $PLAN_FILE

## Your Task: I4 Code Review

Review PR for code quality and merge.

PR: #$PR_NUMBER - $PR_TITLE
URL: $PR_URL

## Review Checks

1. **Code Quality**
   - Clean code, no duplication
   - Follows project conventions
   - No commented out code
   - No debug statements

2. **SPEC Compliance**
   - Code matches spec requirements
   - All acceptance criteria addressed
   - No feature creep

3. **Micro-module Rules**
   - Small focused files
   - Max ~100 lines per file
   - One concept per file
   - No god files

4. **Security**
   - No hardcoded secrets
   - Input validation
   - SQL injection prevention
   - XSS prevention

5. **Tests**
   - If tests exist: do they pass?
   - Are tests meaningful?

## Your Decision

For each issue found:
- If minor: add comment but APPROVE
- If blocking: REQUEST_CHANGES with specific feedback

## If APPROVED
Merge the PR:
\`\`\`bash
gh pr merge $PR_NUMBER --squash --delete-branch
\`\`\`

Add merge comment:
\`\`\`
✅ Reviewed by @archi. Code quality: OK. SPEC compliant. Merged.
\`\`\`

## If NEEDS_WORK
Add review comment with specific issues:
\`\`\`
⚠️ Changes requested by @archi:

1. [Issue description]
2. [Issue description]

Please fix and re-request review.
\`\`\`

Report done with summary."

echo "$ARCHI_TASK"
echo ""
echo "=== To complete I4 manually: ==="
echo "1. Spawn @archi agent"
echo "2. Give the task above"
echo "3. @Archi will review and merge"
echo ""

# If PR_NUMBER provided, fetch diff for review
if command -v gh &> /dev/null && [[ -n "$PR_NUMBER" ]]; then
  echo "Fetching PR diff..."
  gh pr diff "$PR_NUMBER" > "/tmp/pr-${PR_NUMBER}.diff" 2>/dev/null
  echo "Diff saved to: /tmp/pr-${PR_NUMBER}.diff"
fi
