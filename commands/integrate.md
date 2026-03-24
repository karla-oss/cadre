---
description: "CADRE Integration Gate — Inta verifies cross-module contract compliance after all module agents complete. Runs between implement and validate."
cadre:
  phase: P8c-integration-gate
  invariants: [I-01, I-02, I-03, I-10]
  role: inta
  artifacts_required: [contracts/, data-model.md, tasks.md]
  artifacts_produced: [integration-report.md]
triggers:
  - condition: all module agents have submitted tasks to Ready for Review and Archi has approved them
    trigger: Archi spawns Inta after last review-approve.sh
---

## Role

This command is executed by **Inta** (Integration Agent). See `framework/roles/inta.md`.

**READ-ONLY access to all module files.** Inta does not write code.

## When to run

After all module tasks are Done (approved by Archi), before `/cadre.validate`.
Triggered by Archi:

```bash
# Archi spawns Inta after last review-approve.sh
/cadre.integrate
```

## Outline

1. **Load contracts**: Read all files in `contracts/`. Build boundary map:
   - For each contract: identify producer module and consumer module
   - Map: which module produces, which module consumes

2. **Load data model**: Read `data-model.md`. Extract entity schemas.

3. **For each module boundary** (producer → consumer pair):

   ### B1: Request Contract Check
   - Does consumer call the correct endpoint? (method + path)
   - Does consumer send correct request shape? (fields, types, required/optional)
   - Does consumer handle all documented error codes?

   ### B2: Response Contract Check
   - Does producer return correct response shape? (fields, types)
   - Does producer return correct status codes per scenario?
   - Does producer error response match contract error format?

   ### B3: Data Schema Check
   - Do entity field names match between producer and consumer?
   - Do field types match `data-model.md` definitions?
   - Are required fields always present?

   ### B4: Error Handling Check
   - 404 → consumer handles gracefully?
   - 422 → consumer surfaces correct error to user?
   - 409 → consumer handles conflict correctly?

4. **Run integration tests** (if `*/tests/test_integration*` or `*/tests/test_api*` exist):
   ```bash
   pytest */tests/test_integration*.py -v --tb=short 2>&1 | tail -30
   ```
   Report: pass count / fail count.

5. **Produce `FEATURE_DIR/integration-report.md`**:

   ```markdown
   # CADRE Integration Report

   **Feature**: [name]
   **Date**: [DATE]
   **Gate**: P8c — Integration

   ## Boundary Map

   | Producer | Consumer | Contract | Status |
   |----------|----------|----------|--------|
   | @api-agent | @cli-agent | contracts/api-contract.md | ✅ PASS |

   ## Findings

   ### Boundary: @api-agent → @cli-agent

   #### B1: Request Contract — PASS/FAIL
   [findings]

   #### B2: Response Contract — PASS/FAIL
   [findings]

   #### B3: Data Schema — PASS/FAIL
   [findings]

   #### B4: Error Handling — PASS/FAIL
   [findings]

   ## Integration Tests

   [N passed / N failed]

   ## Summary

   | Dimension | Verdict |
   |-----------|---------|
   | Request contracts | PASS/FAIL |
   | Response contracts | PASS/FAIL |
   | Data schemas | PASS/FAIL |
   | Error handling | PASS/FAIL |
   | Integration tests | PASS/FAIL |

   **Overall**: INTEGRATED / VIOLATIONS_FOUND

   ## Escalations to Archi

   [list violations that require Archi decision]

   ## Gate Decision

   - **INTEGRATED**: Proceed to `/cadre.validate`
   - **VIOLATIONS_FOUND**: Archi reviews violations, assigns fixes to module agents
   ```

6. **Escalate to Archi** if violations found:

   ```
   ⚠️ INTA ESCALATION → ARCHI

   Feature: [name]
   Violations: N
   Report: integration-report.md

   Archi: review violations, assign fixes to module agents via review loop.
   DO NOT fix directly.
   DO NOT contact module agents directly.
   ```

7. If INTEGRATED: notify Archi to proceed to `/cadre.validate`.

## Rules

- READ-ONLY on all module files — never write to `api/`, `cli/`, or any module directory
- Never modify `contracts/` — escalate discrepancies to Archi
- One integration report per feature — append new run results under dated header
- Never contact module agents directly — all coordination through Archi
