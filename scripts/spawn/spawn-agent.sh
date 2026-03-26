#!/usr/bin/env bash
# =============================================================================
# spawn-agent.sh — CADRE Agent Spawner
#
# Usage:
#   bash scripts/bash/spawn-agent.sh --task <ticket-file>        # Tasked mode
#   bash scripts/bash/spawn-agent.sh --no-task --agent <type>   # Un-tasked mode
#
# Examples:
#   bash scripts/bash/spawn-agent.sh --task specs/001/tickets/T001.md
#   bash scripts/bash/spawn-agent.sh --no-task --agent api
#
# Exit codes:
#   0 — spawned or no tasks (un-tasked)
#   1 — invalid args or error
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CADRE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# --- Parse args ---
MODE=""
TICKET_FILE=""
AGENT_TYPE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      MODE="tasked"
      TICKET_FILE="$2"
      shift 2
      ;;
    --no-task)
      MODE="untasked"
      shift
      ;;
    --agent)
      AGENT_TYPE="$2"
      shift 2
      ;;
    *)
      echo -e "${RED}Unknown arg: $1${NC}" >&2
      exit 1
      ;;
  esac
done

# --- Validate ---
if [[ -z "$MODE" ]]; then
  echo -e "${RED}Usage: spawn-agent.sh --task <file> OR --no-task --agent <type>${NC}" >&2
  exit 1
fi

# --- TASKED MODE ---
if [[ "$MODE" == "tasked" ]]; then
  if [[ -z "$TICKET_FILE" ]]; then
    echo -e "${RED}--task requires ticket file${NC}" >&2
    exit 1
  fi

  if [[ ! -f "$TICKET_FILE" ]]; then
    echo -e "${RED}Ticket not found: $TICKET_FILE${NC}" >&2
    exit 1
  fi

  TASK_CONTENT="$(cat "$TICKET_FILE")"
  TASK_ID="$(echo "$TASK_CONTENT" | grep -m1 '^# ' | sed -E 's/^#[[:space:]]+([A-Z]+-[0-9]+):.*/\1/' || echo "UNKNOWN")"
  
  # Dynamic agent name based on task + module
  MODULE="$(echo "$TASK_CONTENT" | grep -m1 '^module:' | awk '{print $2}' || echo "unknown")"
  AGENT_NAME="${TASK_ID}-${MODULE}"  # Dynamic: T001-api, T001-frontend
  
  FILE="$(echo "$TASK_CONTENT" | grep -m1 '^\*\*File\*\*:' | sed 's/\*\*File\*\*: //' | tr -d '[:space:]' || echo "N/A")"
  EPIC="$(echo "$TASK_CONTENT" | grep -m1 '^\*\*Epic\*\*:' | sed 's/\*\*Epic\*\*: //' | tr -d '[:space:]' || echo "N/A")"

  TICKET_ABS="$(realpath "$TICKET_FILE")"

  # Generate prompt
  cat <<PROMPT
You are @${AGENT_NAME} for SpecForge.

## Your task: ${TASK_ID}

Agent name: ${AGENT_NAME} (dynamic, based on task)

## CADRE Constitution

You MUST follow these principles:

### Micro Tasks
- One task = one deliverable
- Max 1-2 days of work
- Clear acceptance criteria

### Micro Modules
- One file = one concept
- Max ~100 lines per file
- No god files

### Micro Branches
- One change per branch
- Branch per task: \`micro/${TASK_ID}-description\`

### Micro Changes
- Small PRs = faster review
- Lower risk = safer iteration

## Your task: ${TASK_ID}

Read your ticket: ${TICKET_ABS}

The ticket contains everything you need:
- What to do
- Relevant contract snippet
- Acceptance criteria

## Do NOT read these files:
- quickstart.md
- sprint-config.md

## Your boundary

ONLY touch: ${FILE}

## After completing

1. Mark [X] in specs/${EPIC}/tasks.md for ${TASK_ID}
2. Run: bash /workspace/projects/cadre/scripts/bash/review-request.sh ${TASK_ID} "brief description"
3. Fill self-check in review-request/${TASK_ID}.md
4. Run: bash /workspace/projects/cadre/scripts/bash/review-submit.sh ${TASK_ID}
PROMPT

  exit 0
fi

# --- UNTASKED MODE ---
if [[ "$MODE" == "untasked" ]]; then
  if [[ -z "$AGENT_TYPE" ]]; then
    echo -e "${RED}--agent <type> is required for --no-task${NC}" >&2
    exit 1
  fi

  TASKS_DIR="$CADRE_ROOT/tasks"
  if [[ ! -d "$TASKS_DIR" ]]; then
    echo -e "${RED}No tasks directory: $TASKS_DIR${NC}" >&2
    exit 1
  fi

  TASK_SCRIPTS="$SCRIPT_DIR"

  # Normalize agent name
  NORMALIZED_AGENT="$AGENT_TYPE"
  case "$AGENT_TYPE" in
    api) NORMALIZED_AGENT="api-agent" ;;
    frontend) NORMALIZED_AGENT="frontend-agent" ;;
    infra) NORMALIZED_AGENT="infra-agent" ;;
    analysis) NORMALIZED_AGENT="analysis-agent" ;;
    archi) NORMALIZED_AGENT="archi-agent" ;;
    inta) NORMALIZED_AGENT="inta-agent" ;;
    # Puma is just @puma, not @puma-agent
    puma) NORMALIZED_AGENT="puma" ;;
  esac

  # Get project context for Puma
  # Default: PROJECT_DIR env or assume ../ from CADRE root
  PROJECT_CONTEXT=""
  if [[ "$AGENT_TYPE" == "puma" ]]; then
    PROJECT_DIR="${PROJECT_DIR:-$(dirname "$CADRE_ROOT")}"
    PROJECT_CONTEXT_FILE="$PROJECT_DIR/puma-context.md"
    if [[ -f "$PROJECT_CONTEXT_FILE" ]]; then
      PROJECT_CONTEXT=$(cat <<EOF

## Project Context

Read this file for project context: $PROJECT_CONTEXT_FILE

EOF
)
    fi
  fi

  # Generate standing agent prompt
  cat <<PROMPT
You are a standing agent @${NORMALIZED_AGENT} for SpecForge.${PROJECT_CONTEXT}

## Your role
You execute tasks from the task system. Your job:
1. Find your tasks
2. Execute them
3. Report completion
4. Repeat or sleep

## Task System Scripts
- Get your TODO tasks:
  bash ${TASK_SCRIPTS}/task-get-todos.sh ${AGENT_TYPE}

- Claim a task (mark IN_PROGRESS):
  bash ${TASK_SCRIPTS}/task-claim.sh <task-file>

- Mark task done:
  bash ${TASK_SCRIPTS}/task-complete.sh <task-file>

- Block task (if can't execute):
  bash ${TASK_SCRIPTS}/task-block.sh <task-file> "<reason>"

## Your Workflow

Loop:
  1. Get TODO tasks: bash task-get-todos.sh ${AGENT_TYPE}
  2. If empty → terminate (sleep)
  3. Pick first task from list
  4. READ the task file (understand what needs to be done)
  5. Claim it: bash task-claim.sh <task-file>
     - If claim fails (already taken) → pick next task
  6. Execute the work (based on what you read)
  7. Mark ready for review: bash task-complete.sh <task-file>
  8. Go back to step 1

## Important
- For @puma: Use @puma as owner tag in task files (not @puma-agent)
- All other agents use @xxx-agent format

## Constraints
- Only touch files related to your task
- If task can't be executed (missing prerequisites) → block it with reason
- Complete task fully before moving to next
- Be thorough — one good task > three half-done

## After all tasks done
When no more TODO tasks → terminate (sleep).
You will be re-triggered when new tasks appear.

Start now:
1. Get your TODO tasks
2. Pick and execute first task
PROMPT

  exit 0
fi
