#!/usr/bin/env bash
# =============================================================================
# plan.sh — P4 Technical Plan
#
# Usage:
#   bash scripts/bash/plan.sh <epic-folder>
#
# Flow:
#   1. Spawns @archi directly
#   2. Archi reads spec, creates plan.md
#   3. Done
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

echo "=== P4 Technical Plan ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -f "$SPEC_FILE" ]]; then
  echo "Error: spec.md not found" >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Spawning @archi to create technical plan..."
echo ""

ARCHI_TASK="You are @archi for SpecForge.

## Project Context
- Project: SpecForge
- Stage: MVP

## Your Task: Create Technical Plan

Read the spec: $SPEC_FILE

Create a technical plan at: $PLAN_FILE

## Plan Structure:

\`\`\`markdown
# Plan — $EPIC_NAME

**Epic**: $EPIC_NAME
**Status**: Draft

## Overview
[Brief description of implementation approach]

## Module Decomposition

### @api-agent
[What api does]
Files to create/modify:
- \`api/...\`

### @frontend-agent
[What frontend does]
Files to create/modify:
- \`frontend/...\`

### @infra-agent (if needed)
[What infra does]
Files to create/modify:
- \`infra/...\`

## Implementation Order
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk] | [High/Med/Low] | [Mitigation] |

## Dependencies
- [Dependency 1]
- [Dependency 2]
\`\`\`

Rules:
- MVP = simplest that works
- Include file paths for each module
- Include implementation order
- Include risks

Write plan to: $PLAN_FILE

Report done."

echo "$ARCHI_TASK"
echo ""
echo "=== Spawning @archi ==="
