#!/usr/bin/env bash
# =============================================================================
# epic-create.sh — Create epic scaffold from PROJECT-SPEC.md Sprint Plan
#
# Usage:
#   bash scripts/bash/epic-create.sh                    # Auto (next epic from Sprint Plan)
#   bash scripts/bash/epic-create.sh <name> [modules]   # Manual override
#
# Example:
#   bash scripts/bash/epic-create.sh                    # Creates next epic from Sprint Plan
#   bash scripts/bash/epic-create.sh "export-pipeline" "api,frontend,infra"
#
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TEMPLATE_DIR="$CADRE_ROOT/templates/epic"

# Arguments
EPIC_NAME="${1:-}"
EPIC_MODULES="${2:-}"

# Project path (default: parent of CADRE root)
PROJECT_DIR="${PROJECT_DIR:-$(dirname "$CADRE_ROOT")}"
PROJECT_SPEC="$PROJECT_DIR/PROJECT-SPEC.md"

if [[ ! -f "$PROJECT_SPEC" ]]; then
  echo "Error: PROJECT-SPEC.md not found at $PROJECT_SPEC" >&2
  exit 1
fi

echo "=== Epic Create ==="
echo "Project: $PROJECT_DIR"

# Function to create epic from Sprint Plan
# Returns via global variables: EPIC_ID, EPIC_NAME
find_next_epic() {
  echo "Reading Sprint Plan from $PROJECT_SPEC..."
  
  # Parse Sprint Plan - find next epic without folder
  while IFS= read -r LINE; do
    local num=$(echo "$LINE" | sed -E 's/\| (S[0-9]+).*/\1/')
    local name=$(echo "$LINE" | sed -E 's/\| S[0-9]+ \| ([^|]+).*/\1/' | xargs)
    
    local num_only=$(echo "$num" | sed 's/S//')
    local folder_num=$(printf "%03d" "$num_only")
    local folder="$PROJECT_DIR/specs/${folder_num}-*"
    
    if ! ls -d $folder 2>/dev/null | grep -q .; then
      EPIC_ID="$num"
      EPIC_NAME="$name"
      echo "Found next epic: $EPIC_ID - $EPIC_NAME"
      return 0
    fi
  done < <(grep -E "^\| S[0-9]" "$PROJECT_SPEC")
  
  echo "Error: All epics from Sprint Plan already have folders" >&2
  return 1
}

# Parse arguments
if [[ -z "$EPIC_NAME" ]]; then
  find_next_epic
fi

# If still no name, error
if [[ -z "$EPIC_NAME" ]]; then
  echo "Error: Epic name is required" >&2
  exit 1
fi

# If EPIC_ID not set (manual mode), determine next epic number
if [[ -z "${EPIC_ID:-}" ]]; then
  LAST_NUM=$(find "$PROJECT_DIR/specs" -maxdepth 1 -type d -name '[0-9][0-9][0-9]-*' 2>/dev/null | \
    sed 's/.*\/\([0-9][0-9][0-9]\).*/\1/' | sort -n | tail -1)
  NEXT_NUM=$((LAST_NUM + 1))
  EPIC_ID="S$(printf "%d" "$NEXT_NUM")"
fi

# Slugify epic name (remove special chars)
EPIC_SLUG=$(echo "$EPIC_NAME" | tr '[:upper:]' '[:lower:]' | tr ' +' '-' | tr -cd 'a-z0-9-')

# Epic directory
EPIC_DIR="$PROJECT_DIR/specs/$EPIC_ID-$EPIC_SLUG"

if [[ -d "$EPIC_DIR" ]]; then
  echo "Error: Epic directory already exists: $EPIC_DIR" >&2
  exit 1
fi

echo ""
echo "Creating epic: $EPIC_ID - $EPIC_NAME"
echo "Directory: $EPIC_DIR"

# Create directory structure
mkdir -p "$EPIC_DIR/contracts"
mkdir -p "$EPIC_DIR/tickets"
mkdir -p "$EPIC_DIR/checklists"

# Copy templates
CURRENT_DATE=$(date '+%Y-%m-%d')

for template in spec.md plan.md data-model.md tasks.md quickstart.md; do
  if [[ -f "$TEMPLATE_DIR/$template" ]]; then
    DEST="$EPIC_DIR/$template"
    cp "$TEMPLATE_DIR/$template" "$DEST"
    
    # Replace placeholders
    sed -i "s/\[Epic Name\]/$EPIC_NAME/g" "$DEST"
    sed -i "s/\[epic-id\]/$EPIC_ID/g" "$DEST"
    sed -i "s/\[DATE\]/$CURRENT_DATE/g" "$DEST"
    if [[ -n "${EPIC_MODULES:-}" ]]; then
      sed -i "s/\[api, frontend, etc\]/$EPIC_MODULES/g" "$DEST"
    fi
    
    echo "  Created: $DEST"
  fi
done

echo ""
echo "=== Epic Scaffold Created ==="
echo "Epic: $EPIC_ID - $EPIC_NAME"
echo "Directory: $EPIC_DIR"
echo ""
echo "Next steps:"
echo "  1. Review scaffold files"
echo "  2. Spawn @puma to fill spec: spawn-agent.sh --no-task --agent puma"
echo "  3. Update Sprint Plan status in PROJECT-SPEC.md"
