#!/usr/bin/env bash
# =============================================================================
# integrate.sh — I3 Cross-Module Integration
#
# Usage:
#   bash scripts/bash/integrate.sh <epic-folder>
#
# Flow:
#   Spawns @Inta to validate contracts between modules
#   @Inta NEVER merges — only validates contracts
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
TASKS_DIR="$EPIC_PATH/tasks"

echo "=== I3 Cross-Module Integration ==="
echo "Epic: $EPIC_NAME"
echo ""

if [[ ! -d "$TASKS_DIR" ]]; then
  echo "Error: tasks/ not found" >&2
  exit 1
fi

echo "✅ Script ready"
echo ""
echo "Spawning @inta for integration review..."
echo ""

ARCHI_TASK="You are @inta for SpecForge.

## Project Context
- Project: SpecForge
- Stage: MVP

## Your Task: I3 Cross-Module Integration Review

Review PRs for contract compliance between modules.

Read:
- Tasks: $TASKS_DIR/*.md (filter READY_FOR_REVIEW status)
- Contracts: $EPIC_PATH/contracts/*.md

## Your Role
@Inta validates CONTRACTS between modules ONLY.
@Inta NEVER merges code.

## Integration Checks
For each PR:
1. Read the PR changes
2. Check if API contracts are honored
3. Check if data flows correctly between modules
4. Check for broken imports across modules
5. Run E2E smoke tests if available

## Decision
- If contracts OK: APPROVED → passes to I4 (@Archi review)
- If issues: NEEDS_WORK → add comment to PR

## Output
Write integration report to: $EPIC_PATH/integration-report.md

Report done."

echo "$ARCHI_TASK"
echo ""
echo "=== Spawning @inta ==="