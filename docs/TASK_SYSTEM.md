# CADRE Task System

**Status**: Draft v1.0 (2026-03-25)
**Purpose**: Define task shape, statuses, lifecycle, and automation scripts.

---

## Overview

CADRE uses a task system abstraction — agents interact with tasks through a defined interface, without knowing if the backend is files or Jira.

```
┌─────────────────────────────────────┐
│         Agent                        │
│                                     │
│  task-get-todos.sh <agent>         │
│  task-claim.sh <task-file>         │
│  task-complete.sh <task-file>       │
│  task-block.sh <task-file> <reason> │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│       Task System Abstraction         │
├─────────────────────────────────────┤
│  Backend: Files (current)            │
│  Future: Jira                       │
└─────────────────────────────────────┘
```

---

## Task Hierarchy

| Level | Location | Purpose |
|-------|----------|---------|
| **Epic** | `specs/*/spec.md` | Feature specification |
| **Sprint** | `specs/*/tasks.md` | Sprint tracking, marks sprint open/closed |
| **Task** | `tasks/*.md` | Individual work unit (per-agent) |

### Sprint-Level (`tasks.md`)

Used for sprint management. Contains:
- All task IDs for this sprint
- Checkbox tracking (manual or automated)
- Sprint status (open/closed)
- **When sprint is closed** — mark in `tasks.md` header

Example sprint header:
```markdown
**Epic**: 002-analysis-pipeline
**Status**: P6a (Sprint closed 2026-03-25)
```

### Task-Level (`tasks/*.md`)

Individual task files for agent execution. One file per task.

---

## Task Shape

Tasks are individual units of work owned by a specific agent.

### File Format

```
tasks/
├── T001.md    # One file per task
├── T002.md
└── ...
```

### Task File Template

```markdown
# T001: [Title]

**Status**: TODO
**Owner**: @api-agent
**Created-by**: @puma
**Priority**: P1
**Epic**: 002-analysis-pipeline

## Description

[What needs to be done]

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Notes

[Any additional context]
```

### Fields

| Field | Required | Values | Description |
|-------|----------|--------|-------------|
| `Status` | Yes | `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED` | Current state |
| `Owner` | Yes | `@agent-name` | Who is executing (assignee) |
| `Created-by` | Yes | `@agent-name` | Who created the task |
| `Priority` | No | `P0`, `P1`, `P2`, `P3` | Execution priority (P0 = highest) |
| `Epic` | No | Epic ID | Which epic this belongs to |

---

## Status Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┌──────┐    claim     ┌────────────┐   complete   ┌────┐ │
│   │ TODO │ ──────────► │ IN_PROGRESS │ ──────────► │DONE│ │
│   └──────┘              └────────────┘             └────┘ │
│       │                        │                         │
│       │ block                  │ block                   │
│       ▼                       ▼                         │
│   ┌─────────┐           ┌─────────┐                     │
│   │ BLOCKED │           │ BLOCKED │                     │
│   └─────────┘           └─────────┘                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Status Definitions

| Status | Meaning | Who Sets |
|--------|---------|----------|
| `TODO` | Ready to work, no one claimed yet | Super / Puma |
| `IN_PROGRESS` | Claimed by agent, work underway | Agent (via claim) |
| `DONE` | Completed successfully | Agent (via complete) |
| `BLOCKED` | Cannot execute due to prerequisites | Agent (via block) |

---

## Priority

| Priority | Meaning | When to Use |
|---------|---------|-------------|
| `P0` | Critical — must do now | Blocking everything else |
| `P1` | High — do next | Core functionality |
| `P2` | Medium — scheduled | Important but not blocking |
| `P3` | Low — when time allows | Nice to have |

**Selection order:** P0 first, then by age (oldest first among same priority).

---

## Agent Assignment

| Agent | Owner Tag | Responsibility |
|-------|-----------|----------------|
| API | `@api-agent` | `api/` module |
| Analysis | `@analysis-agent` | `analysis/` module |
| Frontend | `@frontend-agent` | `frontend/` module |
| Infra | `@infra-agent` | Infrastructure, docker, deploy |
| Archi | `@archi-agent` | Architecture, contracts, reviews |
| Inta | `@inta-agent` | Integration, cross-module |

---

## Automation Scripts

All scripts are in `scripts/bash/`.

### task-get-todos.sh

Get available TODO tasks for an agent type.

```bash
bash scripts/bash/task-get-todos.sh api
# Returns: list of task files, sorted by priority
```

### task-claim.sh

Atomically claim a task (TODO → IN_PROGRESS).

```bash
bash scripts/bash/task-claim.sh tasks/T001.md
# Returns: "Claimed: tasks/T001.md"
# Error: "Task is not TODO (current: IN_PROGRESS)"
```

### task-complete.sh

Mark task as ready for review (IN_PROGRESS → READY_FOR_REVIEW).

```bash
bash scripts/bash/task-complete.sh tasks/T001.md
```

### task-block.sh

Block task with reason.

```bash
bash scripts/bash/task-block.sh tasks/T001.md "Missing P5 prerequisites"
```

### task-comment.sh

Add a comment to a task file.

```bash
bash scripts/bash/task-comment.sh tasks/FE-001.md "@archi" "LGTM, minor style issue"
bash scripts/bash/task-comment.sh tasks/FE-001.md "@puma" "Please clarify requirement X"
```

**Use cases:**
- Archi reviews code, adds comment after review
- Puma clarifies a task requirement
- Agent adds context or asks question
- Anyone can comment on any task

---

## Standing Agent Loop

When an agent is spawned without a specific task:

```
1. Get TODO tasks:    task-get-todos.sh <agent-type>
2. If empty → terminate (sleep)
3. Pick first task (highest priority, oldest first)
4. READ task file (understand what needs to be done)
5. Claim it:           task-claim.sh <task-file>
   - If claim fails (race) → pick next task
6. Execute work (based on what you read)
7. Mark done:          task-complete.sh <task-file>
8. Go back to step 1
```

### Blocked Task Handling

If agent determines task cannot be executed:
```
1. Add comment to task explaining why
2. Mark BLOCKED: task-block.sh <task-file> "<reason>"
3. Return to step 1 (pick next task)
```

---

## Race Condition Prevention

Two agents trying to claim the same task:

```
Agent A ──► claim T001 ──► TODO → IN_PROGRESS ──► SUCCESS
Agent B ──► claim T001 ──► (IN_PROGRESS, not TODO) ──► FAIL → pick next
```

Script checks status before claiming. Only the first successful sed wins.

---

## Constraints

1. **One task at a time** — agent claims one task, completes it, then picks next
2. **Only claim TODO** — cannot claim DONE, IN_PROGRESS, or BLOCKED
3. **Complete before next** — don't abandon a task half-done
4. **Block with reason** — if you can't do it, explain why

---

## Migration from Legacy Format

Legacy tasks were stored as checkboxes in `specs/*/tasks.md`.

New format uses individual files in `tasks/` directory.

**Migration is not required** — legacy format can coexist until legacy tasks are completed or migrated.

---

## Agent Identity

| Tag | Full Name | Type | Notes |
|-----|-----------|------|-------|
| `@torres` | `@torres` | Human | Super |
| `@puma` | `@puma` | AI Agent | PM, task creation |
| `@archi` | `@archi-agent` | AI Agent | Architecture, reviews |
| `@api` | `@api-agent` | AI Agent | API module |
| `@frontend` | `@frontend-agent` | AI Agent | Frontend module |
| `@analysis` | `@analysis-agent` | AI Agent | Analysis module |
| `@infra` | `@infra-agent` | AI Agent | Infrastructure |
| `@inta` | `@inta-agent` | AI Agent | Integration |

**Note:** In task files, always use full name `@xxx-agent` (except @puma and @torres).

---

## Agent Roles in CADRE

| Role | Agent | Responsibility |
|------|-------|---------------|
| Super | @torres (human) | Final veto, Epic approval |
| Puma | @puma (agent) | Tasks, specs, PM decisions |
| Archi | @archi-agent | Architecture, contracts, reviews |
| Module | @xxx-agent | Implementation |
| Infra | @infra-agent | Infrastructure |
| Inta | @inta-agent | Integration |

**Note:** Puma is a separate AI agent, not Zazza. Puma owns:
- Task creation
- Product specs and documentation
- Non-technical decisions

---

## CADRE Integration

| Phase | Task Activity | Hook |
|-------|---------------|------|
| P4 (Plan) | Puma creates tasks for epic | - |
| P5 (Readiness) | Tasks in system, ready for execution | - |
| P6a (Tasks) | Standing agents claim and execute | `on-p6a-start.sh` |
| P8 (Implement) | Agents mark READY_FOR_REVIEW | - |
| P8b (Review) | Super reviews, merges | `on-review-request.sh` |

### Hooks

Hooks are in `scripts/hooks/`:

| Hook | When | Purpose |
|------|------|---------|
| `on-p6a-start.sh` | P5 → P6a transition | Spawn module agents |
| `on-review-request.sh` | Task marked READY_FOR_REVIEW | Spawn @archi-agent for review |

**Usage:**
```bash
# When P6a starts:
bash scripts/hooks/on-p6a-start.sh

# When review is requested:
bash scripts/hooks/on-review-request.sh FE-EXPORT-001
```

---

## Backend: Files (Current)

Current implementation uses markdown files in `tasks/` directory.

**Location:** `<project>/tasks/*.md`

---

## CADRE Scripts for Puma

| Script | Purpose |
|--------|---------|
| `epic-create.sh` | Create epic scaffold from Sprint Plan |
| `specify.sh` | Puma fills epic specification |
| `puma-init.sh` | Initialize Puma context for project |

**Puma Workflow:**
```bash
# 1. Create epic scaffold
epic-create.sh

# 2. Puma fills spec
specify.sh specs/S5-polish---auth

# 3. Puma creates tasks
task-create.sh ...
```

---

## Backend: Jira (Future)

When switching to Jira:
- Update `task-system.sh` dispatcher
- Add `task-jira.sh` implementation
- Update agent prompt template

**Trigger:** Super will announce when to switch.

---

## Nice to Have (Future)

### Changes Section in Task File

After completing a task, agent could add a `## Changes` section with:
- List of modified files
- Brief description of changes
- `git diff --stat` output

Example:
```markdown
## Changes

- Modified: frontend/app/projects/[id]/export/page.tsx
- Added: Spinner component, loading state, error boundary
- Modified: frontend/lib/export.ts - added type column to CSV
```

**Purpose:** Reviewer can see what changed before doing git review.
