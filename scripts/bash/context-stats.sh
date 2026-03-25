#!/usr/bin/env bash
# context-stats.sh — Capture agent context breakdown before spawn
# Usage: bash context-stats.sh <TICKET_FILE> <EPIC_DIR>
#
# Outputs JSON with context breakdown for telemetry

set -euo pipefail

TICKET="${1:-}"
EPIC_DIR="${2:-}"

if [[ -z "$TICKET" || -z "$EPIC_DIR" ]]; then
  echo '{"error": "missing args"}'
  exit 1
fi

# Ticket lines
TICKET_LINES=$(wc -l < "$TICKET" 2>/dev/null || echo 0)

# Contract section lines (between "Contract snippet" and next ##)
CONTRACT_LINES=0
if grep -q "Contract snippet" "$TICKET" 2>/dev/null; then
  CONTRACT_LINES=$(sed -n '/Contract snippet/,/^## /p' "$TICKET" 2>/dev/null | wc -l)
fi

# Sprint config lines
CONFIG_LINES=0
CONFIG_FILE="$EPIC_DIR/sprint-config.md"
if [[ -f "$CONFIG_FILE" ]]; then
  CONFIG_LINES=$(wc -l < "$CONFIG_FILE")
fi

# Spec lines (one level up)
SPEC_LINES=0
SPEC_FILE="$EPIC_DIR/../spec.md"
if [[ -f "$SPEC_FILE" ]]; then
  SPEC_LINES=$(wc -l < "$SPEC_FILE")
fi

# Data model lines
MODEL_LINES=0
MODEL_FILE="$EPIC_DIR/data-model.md"
if [[ -f "$MODEL_FILE" ]]; then
  MODEL_LINES=$(wc -l < "$MODEL_FILE")
fi

# Quickstart lines
QUICKSTART_LINES=0
QUICKSTART_FILE="$EPIC_DIR/quickstart.md"
if [[ -f "$QUICKSTART_FILE" ]]; then
  QUICKSTART_LINES=$(wc -l < "$QUICKSTART_FILE")
fi

# Target file lines (what agent will modify)
TARGET_FILE=""
TARGET_LINES=0
if grep -q "^\*\*File\*\*:" "$TICKET" 2>/dev/null; then
  TARGET_FILE=$(grep "^\*\*File\*\*:" "$TICKET" | sed 's/.*: //' | tr -d ' ')
  if [[ -n "$TARGET_FILE" ]]; then
    # Try relative to epic dir, then relative to repo root
    if [[ -f "$EPIC_DIR/../../../$TARGET_FILE" ]]; then
      TARGET_LINES=$(wc -l < "$EPIC_DIR/../../../$TARGET_FILE")
    elif [[ -f "$TARGET_FILE" ]]; then
      TARGET_LINES=$(wc -l < "$TARGET_FILE")
    fi
  fi
fi

TOTAL=$((TICKET_LINES + CONTRACT_LINES + CONFIG_LINES + SPEC_LINES + MODEL_LINES + QUICKSTART_LINES))

cat <<EOF
{
  "ticket_lines": $TICKET_LINES,
  "contract_lines": $CONTRACT_LINES,
  "config_lines": $CONFIG_LINES,
  "spec_lines": $SPEC_LINES,
  "model_lines": $MODEL_LINES,
  "quickstart_lines": $QUICKSTART_LINES,
  "target_file_lines": $TARGET_LINES,
  "context_lines_total": $TOTAL,
  "target_file": "$TARGET_FILE"
}
EOF
