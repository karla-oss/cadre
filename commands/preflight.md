---
description: CADRE Preflight Gate — mandatory checkpoint after task decomposition and before implementation. Validates task coverage, ownership compliance, contract compliance, and implementation drift (tasks vs frozen contracts).
cadre:
  phase: P5b-preflight-gate
  invariants: [I-01, I-02, I-03, I-04, I-10]
  assessment_dimensions: [task-coverage, ownership-compliance, contract-compliance, drift-tasks-vs-contracts]
  owner_required: false
  artifacts_produced: [preflight-report.md]
  artifacts_required: [spec.md, plan.md, tasks.md, contracts/]
  handoffs:
    - label: Start Implementation
      agent: cadre.implement
      prompt: Start bounded implementation per tasks.md
      send: true
scripts:
  sh: scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks
  ps: scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

This is the CADRE Preflight Gate — **Group B** of two assessment gates. Runs AFTER `/cadre.tasks` and BEFORE `/cadre.implement`. Requires `tasks.md` to exist.

**This command MUST run after `/cadre.tasks` and before any implementation agent is spawned.**

Two gates, two scopes:
- `cadre.readiness` (Group A): architectural readiness — plan vs spec
- `cadre.preflight` (Group B): implementation readiness — tasks vs contracts ← this command

## Outline

1. **Setup**: Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS. All paths must be absolute.

2. **Load artifacts**:
   - **REQUIRED**: spec.md
   - **REQUIRED**: plan.md
   - **REQUIRED**: tasks.md
   - **REQUIRED**: contracts/ (at least one contract file)
   - **IF EXISTS**: data-model.md
   - **IF EXISTS**: constitution.md

3. **Run Assessment Dimensions**:

   For each dimension, produce a verdict: **PASS**, **WARN**, or **FAIL**.

   ### D1: Task Coverage
   For each functional requirement in spec.md:
   - Find ≥1 task in tasks.md that implements it
   - FAIL if any P1 requirement has zero task coverage
   - WARN if any P2/P3 requirement has zero task coverage

   For each user story:
   - Verify tasks exist for all acceptance criteria
   - Verify at least one checkpoint/validation task per story phase

   ### D2: Ownership Compliance (I-02, I-03)
   For each task in tasks.md:
   - Verify `[@owner]` tag is present — FAIL if missing (I-02 violation)
   - Verify declared file paths are within owner's module boundary — FAIL if cross-boundary (I-03 violation)

   For each module:
   - Verify no two tasks from different owners declare the same file path

   ### D3: Contract Compliance (I-01)
   For each task referencing an API endpoint:
   - Verify endpoint exists in contracts/ — FAIL if missing

   For each task referencing a data entity:
   - Verify entity exists in data-model.md — FAIL if missing

   For each task that would modify a frozen contract:
   - FAIL unless Architect approval is documented in plan.md

   ### D4: Drift ② — Tasks vs Frozen Contracts
   Scope: implementation drift ONLY (not architectural drift — that is cadre.readiness D4).

   - Tasks reference only entities defined in data-model.md (no invented entities)
   - Tasks reference only endpoints defined in contracts/ (no invented endpoints)
   - Task file paths match the module structure declared in plan.md
   - No task introduces a new module not declared in spec CADRE Metadata
   - WARN if task scope appears to expand beyond spec user stories
   - FAIL if task explicitly contradicts a frozen contract definition

4. **Produce Preflight Report**:

   Write `FEATURE_DIR/preflight-report.md`:

   ```markdown
   # CADRE Preflight Report

   **Feature**: [feature name]
   **Date**: [DATE]
   **Gate**: Group B — Pre-Implementation

   ## Summary

   | Dimension | Verdict | Issues |
   |-----------|---------|--------|
   | Task Coverage | PASS/WARN/FAIL | [count] |
   | Ownership Compliance | PASS/WARN/FAIL | [count] |
   | Contract Compliance | PASS/WARN/FAIL | [count] |
   | Drift (tasks vs contracts) | PASS/WARN/FAIL | [count] |

   **Overall**: READY / READY_WITH_WARNINGS / NOT_READY

   ## Detailed Findings

   [per dimension]

   ## Recommended Actions

   [per finding with owner]

   ## Gate Decision
   - **READY**: Proceed to `/cadre.implement`
   - **READY_WITH_WARNINGS**: Proceed with documented risk acceptance
   - **NOT_READY**: Fix issues and re-run `/cadre.preflight`
   ```

5. **Red Phase Enforcement** (INC-001):
   If tasks.md contains contract test tasks (Phase 2 pattern):
   ```
   ⚠️ CADRE RED PHASE GATE: Before spawning implementation agents, orchestrator MUST run:
       bash scripts/bash/assert-red.sh <test_path>
   Gate must confirm FAIL count > 0 before Phase 3 agents are spawned.
   DO NOT skip this gate. Skipping = INC-001 class incident.
   ```
   Include this warning in preflight-report.md under "## Implementation Notes".

6. **Report and recommend**:
   - If READY: "Preflight Gate passed. Proceed to `/cadre.implement`"
   - If READY_WITH_WARNINGS: List warnings, ask user to acknowledge
   - If NOT_READY: List FAIL items, recommend fixes, block
