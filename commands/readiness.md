---
description: "CADRE Readiness Gate — mandatory checkpoint after plan and before task decomposition. Validates readiness, completeness, contradiction, and architectural drift (plan vs spec)."
cadre:
  phase: P5-readiness-gate
  invariants: [I-01, I-02, I-04, I-10, I-11, I-12]
  assessment_dimensions: [readiness, completeness, contradiction, drift-plan-vs-spec]
  owner_required: false
  artifacts_produced: [assessment-report.md]
  artifacts_required: [spec.md, plan.md]
handoffs:
  - label: Create Tasks
    agent: cadre.tasks
    prompt: Break the plan into tasks
    send: true
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/check-prerequisites.ps1 -Json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

This is `cadre.readiness` — the CADRE Readiness Gate. A mandatory checkpoint between contract freeze (plan) and task decomposition. It validates that the project is architecturally ready for parallel execution.

**This is Group A of two assessment gates. Runs AFTER `/cadre.plan` and BEFORE `/cadre.tasks`. It does NOT require tasks.md — that artifact does not exist yet.**

Two gates, two scopes:
- `cadre.readiness` (Group A): architectural readiness — plan vs spec ← this command
- `cadre.preflight` (Group B): implementation readiness — tasks vs contracts

## Outline

1. **Setup**: Run `{SCRIPT}` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS. All paths must be absolute.

2. **Load artifacts**:
   - **REQUIRED**: spec.md — system specification with CADRE Metadata
   - **REQUIRED**: plan.md — implementation plan with CADRE Contract Status
   - **IF EXISTS**: data-model.md — frozen data contracts
   - **IF EXISTS**: contracts/ — frozen API contracts
   - **IF EXISTS**: research.md — technical decisions
   - **IF EXISTS**: constitution.md — project governance principles

3. **Run Assessment Dimensions**:

   For each dimension, produce a verdict: **PASS**, **WARN**, or **FAIL**.

   ### D1: Completeness
   - Every functional requirement in spec.md has a corresponding section in plan.md
   - Every entity in spec.md Key Entities appears in data-model.md
   - Every user story has acceptance criteria that are testable
   - No `[NEEDS CLARIFICATION]` markers remain in spec or plan
   - No `[NEEDS OWNER]` markers remain in spec CADRE Metadata
   - FAIL if any requirement has no plan coverage

   ### D2: Contradiction
   - No conflicting requirements in spec.md (e.g., "must be real-time" vs "batch processing only")
   - Plan tech decisions align with constitution principles
   - Contract definitions in contracts/ are consistent with data-model.md entities
   - No two contracts define the same endpoint/entity differently
   - FAIL if any contradiction found

   ### D3: Readiness
   - CADRE Metadata section exists in spec.md with owner assigned
   - CADRE Contract Status section exists in plan.md with freeze date
   - Every contract has an assigned owner (producer + consumer modules)
   - Every module referenced in plan has a responsible agent/role
   - Dependencies are available or have documented fallback plan
   - Constitution exists and is non-empty
   - FAIL if owner missing on any contract or module

   ### D4: Drift
   Scope: **Drift ① — architectural drift: plan scope vs spec scope**.

   Does NOT check task-level drift — that is covered by `cadre.preflight` (Group B).

   - Plan scope matches spec scope (no undocumented additions)
   - Modules in plan.md match modules listed in spec CADRE Metadata
   - No contracts reference entities not in spec
   - No entities in data-model.md lack a traceable requirement in spec
   - WARN if minor scope expansion detected; FAIL if major

4. **Produce Assessment Report**:

   Write `FEATURE_DIR/assessment-report.md`:

   ```markdown
   # CADRE Assessment Report

   **Feature**: [feature name]
   **Date**: [DATE]
   **Assessor**: [agent or role that ran this]

   ## Summary

   | Dimension | Verdict | Issues |
   |-----------|---------|--------|
   | Completeness | PASS/WARN/FAIL | [count] |
   | Contradiction | PASS/WARN/FAIL | [count] |
   | Readiness | PASS/WARN/FAIL | [count] |
   | Drift (plan vs spec) | PASS/WARN/FAIL | [count] |

   **Overall**: READY / READY_WITH_WARNINGS / NOT_READY

   ## Detailed Findings

   ### Completeness
   - [finding 1]
   - [finding 2]

   ### Contradiction
   - [finding 1]

   ### Readiness
   - [finding 1]

   ### Drift ① — Architectural (plan vs spec)
   - [finding 1]

   ## Recommended Actions
   - [action 1 with owner]
   - [action 2 with owner]

   ## Gate Decision
   - **READY**: Proceed to `/cadre.tasks`
   - **READY_WITH_WARNINGS**: Proceed with documented risk acceptance
   - **NOT_READY**: Fix issues and re-run `/cadre.readiness`
   ```

5. **Report and recommend**:
   - If READY: "Readiness Gate passed. Proceed to `/cadre.tasks`"
   - If READY_WITH_WARNINGS: List warnings, ask user to acknowledge before proceeding
   - If NOT_READY: List FAIL items, recommend fixes, block progression to tasks

6. **Check for extension hooks**: After assessment, check `.cadre/extensions.yml` for `hooks.after_readiness` entries and execute as per standard hook protocol.
