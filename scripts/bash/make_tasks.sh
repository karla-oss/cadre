#!/usr/bin/env bash
# =============================================================================
# make_tasks.sh — P6a Task Generation
#
# Usage:
#   bash scripts/bash/make_tasks.sh <epic-folder>
#
# Flow:
#   1. Spawns @puma
#   2. Puma generates tasks from plan.md
#   3. Tasks written to tasks/
#   4. Done
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
SPEC_FILE="$EPIC_PATH/spec.md"
PLAN_FILE="$EPIC_PATH/plan.md"
TASKS_DIR="$EPIC_PATH/tasks"

echo "=== P6a Task Generation ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "Error: plan.md not found. Run plan.sh first." >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Spawning @puma to generate tasks..."
echo ""

PUMA_TASK="You are @puma for SpecForge.

## Your Task: Generate Tasks from Plan

Generate implementation tasks for epic: $EPIC_NAME

Read:
- Spec: $SPEC_FILE
- Plan: $PLAN_FILE

## Task Structure

Create tasks in: $TASKS_DIR/

Each task file: `TXXX.md`

\`\`\`markdown
---
title: "[TXXX] Task title"
status: TODO
priority: P1
module: api|frontend|infra|analysis
created-by: puma
---

## Description
[What to do]

## Files
- \`api/...\`
- \`frontend/...\`

## Dependencies
- [TXX]

## Verification
[How to verify done]
\`\`\`

## Rules
- One task = one file
- Match module to agent (@api-agent, @frontend-agent, etc)
- P1 = must have, P2 = should have
- Include file paths for each module agent
- Group related items into single tasks
- Verify against plan.md implementation steps

Generate all tasks, then report count per module.

## Important
- Create tasks/ directory if not exists
- Write tasks as markdown files
- Report done with summary"