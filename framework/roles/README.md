# CADRE Roles

## Overview

CADRE uses a four-role model that separates governance, product ownership, technical authority, and implementation into clearly bounded layers. Each role has an explicit domain it owns and an explicit set of things it never touches. This separation exists to prevent scope creep, eliminate ambiguous ownership, and make every decision traceable to a single accountable party.

The model is designed for multi-agent execution where AI agents need hard boundaries to avoid collisions. Human roles (Super, Puma) govern intent and outcome. AI roles (Archi, Module Agents) govern execution. No role can override another's ownership without going through the defined escalation path. The result is a system where contracts drive coordination instead of implicit conventions.

---

## Role: Super — Human Supervisor

| Field | Value |
|-------|-------|
| **Type** | Human |
| **Authority** | Final veto on any decision. Epic approval. Conflict resolution between roles. |

### Owns
- Nothing in code.
- The governance layer: `constitution.md`

### Intervenes When
- Escalations that no agent can resolve.
- Constitution changes are proposed.
- Epic close approval (when `/cadre.validate` passes and the epic is ready to close).

### Does NOT
- Review individual tasks.
- Write code.
- Approve or reject task-level work.

---

## Role: Puma — Product Manager

| Field | Value |
|-------|-------|
| **Type** | Human or AI agent |
| **Authority** | Spec ownership. Acceptance criteria. User story sign-off. |

### Owns
- `spec.md`
- User stories
- Acceptance criteria

### Runs
- `/cadre.specify` — author or update the spec
- `/cadre.clarify` — respond to clarification requests from Archi or Module Agents

### Does NOT
- Make technical decisions.
- Touch code.
- Define architecture.

---

## Role: Archi — Architect Agent

| Field | Value |
|-------|-------|
| **Type** | AI agent |
| **Authority** | Technical decisions, contract freeze, task review, commits. |

### Owns
- `plan.md`
- `data-model.md`
- `contracts/` — all contract files
- `review-request/` verdicts — Archi is the sole author of verdicts in these files

### Runs
- `/cadre.plan` — decompose spec into plan and tasks
- `/cadre.readiness` — verify all preconditions before implementation starts
- `/cadre.preflight` — pre-flight checks before a task is picked up
- `/cadre.review` — review tasks in "Ready for Review" status
- `/cadre.validate` — validate epic completion criteria

### Review Responsibility
1. Picks up tasks with status "Ready for Review"
2. Reviews against: contract compliance, ownership compliance, self-check assertions in `review-request/T00X.md`
3. **APPROVED** → commits via `task-commit.sh` + marks task Done
4. **NEEDS_WORK** → writes comment in `review-request/T00X.md` + moves task back to In Progress

### Does NOT
- Write module implementation code.
- Touch `api/`, `cli/`, or any other module-owned files.

---

## Role: Module Agent — @\<module-name>-agent

| Field | Value |
|-------|-------|
| **Type** | AI agent (one per module) |
| **Examples** | `@api-agent`, `@cli-agent`, `@frontend-agent` |
| **Authority** | Implementation within owned module boundary only (CADRE I-03). |

### Owns
- All files within the declared module directory (e.g. `api/*` only)

### Runs
- `/cadre.implement` — scoped strictly to owned tasks within the module

### Review Handoff
1. When a task is complete: creates `review-request/T00X.md` with a self-check
2. Moves the task to "Ready for Review"
3. Does NOT commit
4. If **NEEDS_WORK** verdict received: reads the comment, iterates, re-submits

### Does NOT
- Touch other modules.
- Commit code.
- Review other agents' work.
- Make contract decisions.

---

## Role: Inta — Integration Agent

| Field | Value |
|-------|-------|
| **Type** | AI agent |
| **Authority** | Cross-module compliance. Verifies that independently built modules work correctly together per frozen contracts. |

### Owns
- `integration-report.md`
- Integration test runner results

### Runs
- `/cadre.integrate` — verify cross-module contract compliance after all module agents complete

### Does NOT
- Write or modify source code in any module directory.
- Modify `contracts/` — discrepancies are escalated to Archi.
- Contact module agents directly — all coordination through Archi.
- Commit code.
- Approve or reject tasks.

---

## Role Interaction Map

```
┌─────────────────────────────────────────────────────────────────────┐
│                          SUPER (Human)                              │
│          Final veto · Constitution · Epic close approval            │
│                              ▲                                      │
│                  escalate only (no agent can resolve)               │
└──────────────────────────────┼──────────────────────────────────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                                         │
          ▼                                         ▼
┌─────────────────┐                     ┌─────────────────────┐
│  PUMA (PM)      │  ──spec.md──▶       │  ARCHI (Architect)  │
│  spec · stories │  ◀──clarify──       │  plan · contracts   │
│  acceptance     │                     │  review · commit    │
└─────────────────┘                     └──────────┬──────────┘
                                                   │
                              ┌────────────────────┼──────────────────┐
                              │                    │                  │
                              ▼                    ▼                  ▼
                   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
                   │  @api-agent  │    │  @cli-agent  │    │ @frontend-   │
                   │  api/* only  │    │  cli/* only  │    │    agent     │
                   └──────┬───────┘    └──────┬───────┘    └──────┬───────┘
                          │                   │                    │
                          └───────────────────┴────────────────────┘
                                review-request/T00X.md → Archi
                                    (all tasks Done)
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │  INTA (Integration)    │
                              │  read-only · contracts │
                              │  boundary checks       │
                              └───────────┬────────────┘
                                          │
                               INTEGRATED │ VIOLATIONS_FOUND
                                          │         │
                                          ▼         ▼
                                       validate   Archi → module agents fix
```

---

## Ownership Summary

| Role | Owns | Does NOT Touch |
|------|------|----------------|
| Super | `constitution.md`, governance layer | Code, task-level decisions, spec |
| Puma | `spec.md`, user stories, acceptance criteria | Code, architecture, technical decisions |
| Archi | `plan.md`, `data-model.md`, `contracts/`, `review-request/` verdicts | Module implementation files (`api/`, `cli/`, etc.) |
| Module Agent | Files within declared module directory | Other modules, commits, contracts, reviews |
| Inta | `integration-report.md`, integration test results | All module files (read-only), `contracts/` (read-only), `tasks.md` (read-only) |

---

## Review Loop

```
  Module Agent completes task
          │
          ▼
  Creates review-request/T00X.md
  (self-check assertions)
          │
          ▼
  Moves task ──▶ "Ready for Review"
          │
          ▼
      ARCHI picks up
          │
     ┌────┴────┐
     │         │
     ▼         ▼
 APPROVED   NEEDS_WORK
     │         │
     ▼         ▼
  Commits   Writes comment in
  via       review-request/T00X.md
  task-     │
  commit    ▼
  .sh    Moves task ──▶ "In Progress"
     │         │
     ▼         ▼
  Marks    Module Agent
  task     iterates and
  Done     re-submits

  [all tasks Done]
          │
          ▼
  ── P8c: INTEGRATION CHECK ──
  Archi spawns INTA
          │
     ┌────┴──────────┐
     │               │
     ▼               ▼
 INTEGRATED    VIOLATIONS_FOUND
     │               │
     ▼               ▼
  Archi runs    Archi reviews
  /cadre.       violations,
  validate      assigns fixes to
                module agents
                via review loop
```
