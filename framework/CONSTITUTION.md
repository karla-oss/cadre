# CADRE Constitution

## Core Principles

### Docs for Humans

**Implementation is optimized for AI. Docs are for Humans.**

Documentation should be:
- Clear, concise, actionable
- Human-readable format
- Focused on decisions, not implementation details
- Use markdown, tables, checklists

AI reads code directly. Humans need context.

---

## AI-Optimized Implementation

These principles guide all implementation work.

### Micro Tasks

Tasks are small, focused units of work:
- One task = one deliverable
- Max 1-2 days of work
- Clear acceptance criteria
- Single responsibility

### Micro Modules

Code files are small and focused:
- One file = one concept
- Max ~100 lines per file
- Clear naming
- No god files

### Micro Branches

One change per branch:
- Branch per task: `micro/T001-description`
- 1000 branches = OK
- Fast review cycles
- No merge conflicts by design

### Micro Changes

Minimal, incremental progress:
- Small PRs are better than large ones
- Easier to review = faster merge
- Lower risk = safer iteration

---

## Agent Responsibilities

| Agent | Domain |
|-------|--------|
| Super | Final decisions, veto power |
| Puma | Product, specs, tasks |
| Archi | Architecture, plans, reviews |
| Inta | Integration, contracts |
| Module Agents | Implementation |

---

## Sprint Workflow

```
Planning Phase (P1-P8):
P1 Specify → P2 Clarify → P3 Assess → P4 Plan → P5 Readiness → P6 Tasks → P7 Preflight → P8 Sprint Branch

Implementation Phase (I1-I6):
I1 Spawn → I2 Implement → I3 Integrate → I4 Review → I5 Fix → I6 Validate
```

---

## Enforcement

These principles are enforced by:
1. Constitution (this document)
2. Agent context (each agent knows)
3. Spawn prompt (spawn-agent.sh includes)
