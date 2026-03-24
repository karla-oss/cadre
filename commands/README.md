# Commands

Agent-executable prompts. One file per workflow phase.

## Workflow

```
PROJECT LEVEL (above Epics):
P0  project-assess → evaluate Project System Specification readiness
                     score: GREEN/YELLOW/RED → Super go/no-go decision

EPIC LEVEL (one per feature):
P1  constitution  → establish project governance principles
P2  specify       → create system specification (Epic)
P3  clarify       → resolve ambiguities (max 5 questions)
P4  plan          → contract freeze (data-model, API contracts, research)
P5  readiness     → [GATE A] architectural readiness: plan vs spec
                    checks: completeness, contradiction, readiness, drift①
P6a tasks         → task decomposition with ownership
P6b preflight     → [GATE B] implementation readiness: tasks vs contracts
                    checks: task coverage, ownership compliance, contract compliance, drift②
P8  implement     → bounded execution (one agent, one owner, one phase)
                    ↓ task done → review-request.sh → Ready for Review
P8b review        → Archi reviews: contract/ownership/self-check/completeness
                    APPROVED → review-approve.sh → commit → Done
                    NEEDS_WORK → review-reject.sh → back to In Progress (loop)
P9  validate      → [GATE C] Epic validation: all tasks Done, E2E, quickstart
                    EPIC_READY → Super sign-off → Epic close
```

## Gate Summary

| Gate | Command | Runs After | Blocks | Drift Scope |
|------|---------|------------|--------|-------------|
| A | `cadre.readiness` | plan | tasks | plan vs spec (Drift ①) |
| B | `cadre.preflight` | tasks | implement | tasks vs contracts (Drift ②) |
| C | `cadre.validate` | all tasks Done | Epic close | end-to-end (Drift ③) |

## Commands

| File | Phase | Role | Description |
|------|-------|------|-------------|
| `project-assess.md` | P0 | Archi | Project-level spec readiness score (IEEE 830 + risk) |
| `constitution.md` | P1 | Super/Puma | Project governance principles |
| `specify.md` | P2 | Puma | System specification from natural language |
| `clarify.md` | P3 | Puma | Ambiguity resolution (interactive, max 5 Q) |
| `plan.md` | P4 | Archi | Contract freeze: data-model, API contracts, research |
| `readiness.md` | P5 | Archi | Gate A — architectural readiness |
| `tasks.md` | P6a | Archi | Task decomposition with ownership and parallelism |
| `preflight.md` | P6b | Archi | Gate B — implementation readiness |
| `implement.md` | P8 | Module Agent | Bounded execution per owner/phase |
| `review.md` | P8b | Archi | Task review: approve or reject per task |
| `validate.md` | P9 | Archi + Super | Gate C — Epic validation before close |
| `checklist.md` | any | any | Checklist generation for any domain |

## Enforcement Scripts

| Script | Who Calls It | Purpose |
|--------|-------------|---------|
| `scripts/bash/assert-red.sh` | Orchestrator | Between Phase 2 and Phase 3 — confirms tests FAIL before impl |
| `scripts/bash/task-commit.sh` | Archi | After review approval — enforces task=commit (NOTE-001) |
| `scripts/bash/validate-commits.sh` | Archi (P9) | Before Epic close — audits all tasks have commits |
| `scripts/bash/review-request.sh` | Module Agent | Mark task Ready for Review, create review-request artifact |
| `scripts/bash/review-approve.sh` | Archi | Approve task, commit, mark Done |
| `scripts/bash/review-reject.sh` | Archi | Reject task, write actionable comment, move back to In Progress |
| `scripts/bash/review-status.sh` | Anyone | Show current review queue grouped by status |

## Roles Quick Reference

| Role | Type | Key Responsibility |
|------|------|--------------------|
| Super | Human | Final veto, Epic close sign-off |
| Puma | Human/AI | Spec ownership, acceptance criteria |
| Archi | AI Agent | Plan, contracts, review, commits, validation |
| Module Agent | AI Agent | Bounded implementation within owned module |

See `framework/roles/README.md` for full role definitions.
