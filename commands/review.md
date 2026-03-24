---
description: "CADRE Task Review — Archi picks up Ready for Review tasks, checks contract/ownership compliance, approves or rejects."
cadre:
  phase: P8b-review
  invariants: [I-01, I-02, I-03, I-06, I-10]
  role: archi
  artifacts_required: [tasks.md, contracts/, review-request/]
  artifacts_produced: [review-request/T00X.md verdict]
---

## Role

This command is executed by **Archi** (Architect Agent). See `framework/roles/archi.md`.

## When to run

When tasks exist in "Ready for Review" status. Run `review-status.sh` first to see the queue.

## Outline

1. **Check review queue**:
   ```bash
   bash scripts/bash/review-status.sh
   ```
   If queue empty → report "Nothing to review." and exit.

2. **For each task in Ready for Review** (process one at a time):
   a. Read `review-request/T00X.md` — the Module Agent's submission
   b. Read the relevant task from `tasks.md` — understand what was required
   c. Read relevant contract(s) from `contracts/` — the frozen spec

3. **Review Checklist** (for each task):

### C1: Contract Compliance (I-01)
- Does the implementation match the endpoint/schema defined in contracts/?
- Are response codes correct?
- Are request/response shapes correct?
- FAIL if any contract deviation found

### C2: Ownership Compliance (I-02, I-03)
- Did the agent only touch files within its declared module boundary?
- Check "Files changed" section in review-request file
- FAIL if any out-of-boundary file touched

### C3: Self-Check Assertions
- Are all checkboxes in the self-check section checked?
- If unchecked items remain: NEEDS_WORK (agent must complete self-check)

### C4: Completeness
- Does the task description match what was actually done?
- Are edge cases handled per spec?

4. **Verdict**:

   **APPROVED**:
   ```bash
   bash scripts/bash/review-approve.sh T00X "short description of what was done"
   ```

   **NEEDS_WORK**:
   ```bash
   bash scripts/bash/review-reject.sh T00X "specific actionable comment: what is wrong and what must be fixed"
   ```

   Comment must be actionable. "Fix it" is not acceptable. Reference the specific contract line or spec section.

5. **After all queue items processed**:
   Run `review-status.sh` again to confirm queue state.

## Rules

- Review ONE task at a time — do not batch approvals
- NEEDS_WORK comment MUST reference specific contract/spec location
- Never approve if self-check has unchecked items
- Never touch module files during review (read-only access to `api/`, `cli/`, etc.)
- If contract itself is wrong → escalate to Super, do NOT approve workaround
