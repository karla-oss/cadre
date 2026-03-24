# Commands

Agent-executable prompts. One file per workflow phase.

## Workflow

```
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
```

## Gate Summary

| Gate | Command | Runs After | Blocks | Drift Scope |
|------|---------|------------|--------|-------------|
| A | `cadre.readiness` | plan | tasks | plan vs spec |
| B | `cadre.preflight` | tasks | implement | tasks vs frozen contracts |

## Commands

| File | Phase | Description |
|------|-------|-------------|
| `constitution.md` | P1 | Project governance principles |
| `specify.md` | P2 | System specification from natural language |
| `clarify.md` | P3 | Ambiguity resolution (interactive, max 5 Q) |
| `plan.md` | P4 | Contract freeze: data-model, API contracts, research |
| `readiness.md` | P5 | Gate A — architectural readiness |
| `tasks.md` | P6a | Task decomposition with ownership and parallelism |
| `preflight.md` | P6b | Gate B — implementation readiness |
| `implement.md` | P8 | Bounded execution per owner/phase |
| `checklist.md` | any | Checklist generation for any domain |

## Enforcement Scripts

| Script | Purpose |
|--------|---------|
| `scripts/bash/assert-red.sh` | Between Phase 2 tasks and Phase 3 tasks — confirms tests FAIL before impl |
| `scripts/bash/task-commit.sh` | After each task — enforces task=commit rule (NOTE-001) |
| `scripts/bash/validate-commits.sh` | Before Phase 7 Polish — audits all tasks have commits |
