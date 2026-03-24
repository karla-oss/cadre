#!/usr/bin/env bash
# =============================================================================
# spawn-agent.sh — CADRE Minimal Agent Prompt Generator
#
# Usage: bash scripts/bash/spawn-agent.sh <TICKET_FILE>
#
# Purpose:
#   Read a ticket file and output a minimal agent prompt to stdout.
#   Orchestrator uses this output as the task for sessions_spawn.
#
# OBS-010: Ticket-per-agent context model
#
# Exit codes:
#   0 — prompt output successfully
#   1 — invalid args or ticket file not found
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
NC='\033[0m'

TICKET_FILE="${1:-}"

# --- Validate ---
if [[ -z "$TICKET_FILE" ]]; then
  echo -e "${RED}❌ Usage: bash scripts/bash/spawn-agent.sh <TICKET_FILE>${NC}" >&2
  echo -e "   Example: bash scripts/bash/spawn-agent.sh specs/001-input-ingestion/tickets/T001.md" >&2
  exit 1
fi

if [[ ! -f "$TICKET_FILE" ]]; then
  echo -e "${RED}❌ Ticket file not found: $TICKET_FILE${NC}" >&2
  exit 1
fi

# --- Extract fields ---
TICKET_CONTENT="$(cat "$TICKET_FILE")"

# TASK_ID from header: "# T001: Some Title"
TASK_ID="$(echo "$TICKET_CONTENT" | grep -m1 '^# T' | sed 's/^# \(T[0-9]*\):.*/\1/')"

# OWNER from "**Owner**: @api-agent"
OWNER="$(echo "$TICKET_CONTENT" | grep -m1 '^\*\*Owner\*\*:' | sed 's/\*\*Owner\*\*: @\(.*\)/\1/' | tr -d '[:space:]')"

# FILE from "**File**: api/routers/projects.py"
FILE="$(echo "$TICKET_CONTENT" | grep -m1 '^\*\*File\*\*:' | sed 's/\*\*File\*\*: //' | tr -d '[:space:]')"

# EPIC from "**Epic**: 001-input-ingestion"
EPIC="$(echo "$TICKET_CONTENT" | grep -m1 '^\*\*Epic\*\*:' | sed 's/\*\*Epic\*\*: //' | tr -d '[:space:]')"

# --- Validate extracted fields ---
if [[ -z "$TASK_ID" ]]; then
  echo -e "${RED}❌ Could not extract TASK_ID from ticket header (expected: # T001: Title)${NC}" >&2
  exit 1
fi
if [[ -z "$OWNER" ]]; then
  echo -e "${RED}❌ Could not extract OWNER from ticket (expected: **Owner**: @agent-name)${NC}" >&2
  exit 1
fi
if [[ -z "$FILE" ]]; then
  echo -e "${RED}❌ Could not extract FILE from ticket (expected: **File**: path/to/file.py)${NC}" >&2
  exit 1
fi
if [[ -z "$EPIC" ]]; then
  echo -e "${RED}❌ Could not extract EPIC from ticket (expected: **Epic**: epic-branch)${NC}" >&2
  exit 1
fi

# Resolve absolute path to ticket file
TICKET_ABS="$(realpath "$TICKET_FILE")"

# --- Output minimal agent prompt ---
cat <<PROMPT
You are @${OWNER} for SpecForge.

## Your task: ${TASK_ID}

Read your ticket: ${TICKET_ABS}

The ticket contains everything you need:
- What to do
- Relevant contract snippet
- Acceptance criteria

## Your boundary

ONLY touch: ${FILE}

## After completing

1. Mark [X] in specs/${EPIC}/tasks.md for ${TASK_ID}
2. Run: bash /workspace/projects/cadre/scripts/bash/review-request.sh ${TASK_ID} "brief description"
3. Fill self-check boxes in review-request/${TASK_ID}.md
4. Run: bash /workspace/projects/cadre/scripts/bash/review-submit.sh ${TASK_ID}
PROMPT

exit 0
