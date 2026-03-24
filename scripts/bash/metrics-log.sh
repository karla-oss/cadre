#!/usr/bin/env bash
# metrics-log.sh — Append a metrics entry to framework/metrics.md
# Usage: bash scripts/bash/metrics-log.sh <SPRINT> <PHASE> <APPROACH> <TASKS_TOTAL> <NEEDS_WORK_PCT> <C1_DEVIATIONS> <ARCHI_ITERATIONS> [notes]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
METRICS_FILE="$REPO_ROOT/framework/metrics.md"

# --- Validate args ---
if [[ $# -lt 7 ]]; then
  echo "❌ Usage: $0 <SPRINT> <PHASE> <APPROACH> <TASKS_TOTAL> <NEEDS_WORK_PCT> <C1_DEVIATIONS> <ARCHI_ITERATIONS> [notes]"
  echo "   Example: $0 S3 'Phase 1' 'ticket' 5 10 0 1 'first ticket run'"
  exit 1
fi

SPRINT="$1"
PHASE="$2"
APPROACH="$3"
TASKS_TOTAL="$4"
NEEDS_WORK="$5"
C1_DEVIATIONS="$6"
ARCHI_ITERATIONS="$7"
NOTES="${8:-}"
DATE="$(date +%Y-%m-%d)"

if [[ -z "$SPRINT" || -z "$PHASE" ]]; then
  echo "❌ SPRINT and PHASE are required."
  exit 1
fi

# --- Ensure metrics file exists ---
if [[ ! -f "$METRICS_FILE" ]]; then
  echo "❌ Metrics file not found: $METRICS_FILE"
  exit 1
fi

# --- Build entry ---
ENTRY="\n### ${PHASE} — ${APPROACH} — ${DATE}\n- tasks_total: ${TASKS_TOTAL}\n- needs_work_rate: ${NEEDS_WORK}%\n- c1_deviations: ${C1_DEVIATIONS}\n- archi_iterations: ${ARCHI_ITERATIONS}"
if [[ -n "$NOTES" ]]; then
  ENTRY="${ENTRY}\n- notes: ${NOTES}"
fi

# --- Find or create sprint section and append ---
SPRINT_HEADER="## ${SPRINT}"

if grep -qF "$SPRINT_HEADER" "$METRICS_FILE"; then
  # Sprint section exists — append before the next ## section or EOF
  # Use awk to insert after the sprint section header block
  awk -v sprint="$SPRINT_HEADER" -v entry="$ENTRY" '
    BEGIN { found=0; done=0 }
    {
      if (!done && found && /^## / && $0 != sprint) {
        # We hit the next top-level section — insert before it
        printf "%s\n\n", entry
        done=1
      }
      print
      if (!found && index($0, sprint) == 1) {
        found=1
      }
    }
    END {
      if (found && !done) {
        printf "\n%s\n", entry
      }
    }
  ' "$METRICS_FILE" > "${METRICS_FILE}.tmp" && mv "${METRICS_FILE}.tmp" "$METRICS_FILE"
else
  # Sprint section does not exist — append new section at end of file
  printf "\n---\n\n%s\n%s\n" "$SPRINT_HEADER" "$ENTRY" >> "$METRICS_FILE"
fi

echo "📊 Metrics logged: ${SPRINT} ${PHASE}"
