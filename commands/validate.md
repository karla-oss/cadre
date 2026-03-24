---
description: "CADRE Epic Validation Gate — runs automatically after all tasks are Done. Validates E2E completeness, contract fulfilment, drift, and quickstart scenarios before Epic close."
cadre:
  phase: P9-epic-validation
  invariants: [I-01, I-04, I-06, I-10, I-12]
  role: archi
  artifacts_required: [spec.md, plan.md, tasks.md, contracts/, review-request/]
  artifacts_produced: [validate-report.md]
triggers:
  - condition: all tasks in tasks.md have status Done (marked [X])
    trigger: automatic — Archi runs this after approving the last task
---

## Purpose

This is the **CADRE Epic Validation Gate** — the final checkpoint before an Epic is closed.

Runs AFTER all tasks are Done (all `[X]` in tasks.md, all approved by Archi).
Triggered automatically by Archi after the last `review-approve.sh` call.

**On PASS**: Epic closes. Super is notified for final sign-off.
**On FAIL**: Epic stays open. Archi logs blockers. Module agents fix, re-submit via review loop.

This is NOT a code review (that's `cadre.review`).
This is NOT an implementation gate (that's `cadre.preflight`).
This is evidence collection that the system as a whole fulfils the Epic contract.

---

## Outline

1. **Setup**: Verify all tasks in `tasks.md` are marked `[X]`. If any unchecked task exists:
   ```
   ❌ VALIDATION BLOCKED: tasks.md has incomplete tasks.
   Remaining: [list T00X items]
   Run /cadre.review to process remaining tasks first.
   ```

2. **Load artifacts**:
   - **REQUIRED**: spec.md — acceptance criteria and success criteria
   - **REQUIRED**: plan.md — contract freeze status
   - **REQUIRED**: tasks.md — all tasks [X]
   - **REQUIRED**: contracts/ — frozen API contracts
   - **IF EXISTS**: data-model.md
   - **IF EXISTS**: quickstart.md — validation scenarios
   - **IF EXISTS**: review-request/ — audit trail of all approved tasks

3. **Run Validation Dimensions**:

   For each dimension, produce a verdict: **PASS**, **WARN**, or **FAIL**.

   ### V1: Task Completeness
   - All tasks in tasks.md are marked [X]
   - Every task has a corresponding approved review-request file (no orphan tasks)
   - No task has status `needs-work` in review-request/
   - FAIL if any task missing review-request or still in needs-work state

   ### V2: Acceptance Criteria Coverage
   - For each User Story in spec.md: verify at least one task addressed its acceptance criteria
   - For each Success Criterion in spec.md: verify it is met by implemented tasks
   - Cross-reference: spec.md functional requirements vs tasks.md deliverables
   - FAIL if any P1 acceptance criterion has no corresponding Done task
   - WARN if any P2/P3 acceptance criterion is unaddressed

   ### V3: Contract Fulfilment (I-01)
   - Every endpoint defined in contracts/ has a corresponding implemented task [X]
   - Every entity in data-model.md has a corresponding implementation task [X]
   - No frozen contract was modified without documented Architect approval
   - FAIL if any contract item has no implementation evidence

   ### V4: Drift — Final Check (I-01)
   - Scope: end-to-end drift — spec user stories vs what was actually built
   - Review all approved review-request/ files — did implementations match their task descriptions?
   - Verify no scope creep: no implemented features absent from spec
   - WARN if minor additions detected; FAIL if major undocumented features present

   ### V5: Quickstart Validation (I-10)
   - If quickstart.md exists: verify all scenarios were executed (evidence in validate-report or test output)
   - Integration tests pass (reference test output from last agent run)
   - E2E scenarios from quickstart.md map to passing tests
   - FAIL if quickstart scenarios have no test coverage
   - WARN if quickstart scenarios exist but test results not available

   ### V6: Commit Audit (NOTE-001)
   Run:
   ```bash
   bash scripts/bash/validate-commits.sh specs/<feature>/tasks.md
   ```
   - Every task ID in tasks.md must have a corresponding commit
   - FAIL if any task is missing a commit (NOTE-001 violation)

4. **Produce Validation Report**:

   Write `FEATURE_DIR/validate-report.md`:

   ```markdown
   # CADRE Epic Validation Report

   **Feature**: [feature name]
   **Date**: [DATE]
   **Validator**: Archi
   **Gate**: P9 — Epic Validation

   ## Summary

   | Dimension | Verdict | Issues |
   |-----------|---------|--------|
   | Task Completeness | PASS/WARN/FAIL | [count] |
   | Acceptance Criteria | PASS/WARN/FAIL | [count] |
   | Contract Fulfilment | PASS/WARN/FAIL | [count] |
   | Drift (end-to-end) | PASS/WARN/FAIL | [count] |
   | Quickstart Validation | PASS/WARN/FAIL | [count] |
   | Commit Audit | PASS/WARN/FAIL | [count] |

   **Overall**: EPIC_READY / EPIC_READY_WITH_WARNINGS / EPIC_BLOCKED

   ## Detailed Findings

   [per dimension]

   ## Evidence Summary

   | Task | Review Request | Commit | AC Coverage |
   |------|---------------|--------|-------------|
   | T001 | ✅ approved | abc1234 | FR-001, FR-002 |
   ...

   ## Gate Decision

   - **EPIC_READY**: Notify Super for final sign-off. Epic → Done.
   - **EPIC_READY_WITH_WARNINGS**: Document warnings, get Super acknowledgement, then close.
   - **EPIC_BLOCKED**: Fix listed issues. Re-run `/cadre.validate` after fixes.
   ```

5. **Notify Super**:

   If EPIC_READY or EPIC_READY_WITH_WARNINGS:
   ```
   ✅ CADRE EPIC READY FOR CLOSE

   Feature: [name]
   Tasks: [N] Done
   Validation: [overall verdict]
   Report: [path to validate-report.md]

   Super: review validate-report.md and approve Epic close.
   ```

   If EPIC_BLOCKED:
   ```
   ❌ CADRE EPIC BLOCKED

   Feature: [name]
   Blockers: [count]
   [list top 3 blocker findings]

   Fix blockers and re-run /cadre.validate.
   ```

6. **Epic close** (Super authority, I-06):
   - Super reviews validate-report.md
   - Super gives final approval (explicit sign-off required — cannot be automated)
   - On approval: Epic branch merges, Jira Epic → Done
   - CADRE I-06: Human Final Authority — Epic close is the ONE action that requires Super, not Archi
