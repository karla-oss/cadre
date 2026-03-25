#!/usr/bin/env bash
# =============================================================================
# specify.sh — Puma runs specify scenario to fill epic spec
#
# Usage:
#   bash scripts/bash/specify.sh <epic-folder>
#
# Example:
#   bash scripts/bash/specify.sh specs/004-export-pipeline
#
# Puma will:
#   1. Read epic template
#   2. Fill spec.md with content
#   3. Validate output
#   4. Ensure files are in correct locations
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

EPIC_PATH="${1:-}"

if [[ -z "$EPIC_PATH" ]]; then
  echo "Usage: specify.sh <epic-folder>" >&2
  echo "Example: specify.sh specs/004-export-pipeline" >&2
  exit 1
fi

# Resolve absolute path
if [[ "$EPIC_PATH" != /* ]]; then
  EPIC_PATH="$(pwd)/$EPIC_PATH"
fi

if [[ ! -d "$EPIC_PATH" ]]; then
  echo "Error: Epic folder not found: $EPIC_PATH" >&2
  exit 1
fi

EPIC_NAME=$(basename "$EPIC_PATH")
EPIC_DIR="$CADRE_ROOT/../$(basename "$(dirname "$EPIC_PATH")")/$(basename "$EPIC_PATH")"

echo "=== Puma Specify ==="
echo "Epic: $EPIC_NAME"
echo "Path: $EPIC_PATH"
echo ""

# Check template exists
TEMPLATE_SPEC="$CADRE_ROOT/templates/epic/spec.md"
if [[ ! -f "$TEMPLATE_SPEC" ]]; then
  echo "Error: Template not found: $TEMPLATE_SPEC" >&2
  exit 1
fi

# Check epic scaffold exists
if [[ ! -f "$EPIC_PATH/spec.md" ]]; then
  echo "Error: Epic spec.md not found. Run epic-create.sh first." >&2
  exit 1
fi

echo "Template: $TEMPLATE_SPEC"
echo "Epic spec: $EPIC_PATH/spec.md"
echo ""

# Generate prompt for Puma
cat <<PROMPT
You are @puma for SpecForge.

## Your Task: Fill Epic Specification

The epic scaffold exists at: $EPIC_PATH

Read the template: $TEMPLATE_SPEC

Read the existing spec.md: $EPIC_PATH/spec.md

## Your Job:

1. **Read the template** ($TEMPLATE_SPEC) - understand required sections

2. **Fill the spec.md** at $EPIC_PATH/spec.md:
   - User Scenarios & Testing (user stories with acceptance criteria)
   - Functional Requirements
   - Constraints
   - Out of Scope
   - Any other sections

3. **Follow the template structure** - keep all sections from template

4. **Quality checklist** (max 3 [NEEDS CLARIFICATION] markers):
   - Make informed guesses for unspecified details
   - Only mark for clarification if:
     - Multiple reasonable interpretations exist
     - No reasonable default exists
   - Prioritize by impact: scope > security > UX > technical

5. **Write directly to**: $EPIC_PATH/spec.md

6. **Validate output**:
   - All mandatory sections completed
   - No empty sections (remove if N/A)
   - Acceptance criteria are testable
   - [NEEDS CLARIFICATION] markers <= 3

## Important:
- Do NOT change the frontmatter (Epic ID, Owner, Status, etc.)
- Do NOT change file structure
- Fill CONTENT only
- Write for business stakeholders, not developers
- Focus on WHAT and WHY, not HOW

Start now. Read the template, read the existing spec, fill in the content.
PROMPT

echo ""
echo "=== Puma Specify Prompt Generated ==="
echo "Run this prompt with @puma agent"
echo ""
echo "Expected outcome:"
echo "  - $EPIC_PATH/spec.md filled with content"
echo "  - All template sections completed"
echo "  - Quality checklist passed"
