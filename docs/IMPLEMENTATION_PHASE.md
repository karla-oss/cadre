# Planning Phase (P1-P8)

## Sprint Planning Master Script

**Script:** `sprint-plan.sh`

**Owner:** @Archi

**Runs:** P1 → P2 → P3 → P4 → P5 → P6 → P7 → P8

```
bash scripts/bash/sprint-plan.sh specs/S5-polish---auth
```

---

## Phase Flow

```
P1 Specify → P2 Clarify → P3 Assess → P4 Plan → P5 Readiness → P6 Tasks → P7 Preflight → P8 Sprint Branch
```

---

# Implementation Phase (I1-I6)

## Core Principle

**Implementation is optimized for AI. Docs are for Humans.**

---

## P8 (sprint-branch.sh) — Create Sprint Branch

**Owner:** @Archi

**Script:** sprint-branch.sh

**Phase:** Planning Phase — last step (P8)

**Called by:** Automatic (when P7 preflight passes)

**Purpose:** Sprint branch created = signal to start implementation

**Flow:**
```
P7 Preflight ✅ (all green)
    ↓
sprint-branch.sh runs automatically
    ↓
Creates: sprint/S5-polish-auth
    ↓
Git Hook: sprint branch created
    ↓
Implementation Phase (I1-I6) starts
```

```
bash scripts/bash/sprint-branch.sh specs/S5-polish---auth
    ↓
Creates sprint branch: sprint/S5-polish-auth
    ↓
All PRs target this branch
    ↓
Branch created = signal to start implementation
```

---

## I1 (implement.sh) — Spawn Module Agents

**Owner:** @Archi

**Script:** implement.sh

**Called by:** Git Hook

```
Git Hook triggers implement.sh
    ↓
@Archi reads tasks/
    ↓
@Archi spawns module agents in parallel
    ↓
Agents work autonomously
```

---

## I2 — Implement Task (Microbranch)

**Owner:** Module Agent

**Called by:** Git Hook (post-checkout, pre-commit)

**Internal flow:**
```
Agent creates microbranch
    ↓
Implements (micro-modules: small focused files)
    ↓
git add . && git commit -m "[T001] description"
    ↓
Git Hook: pre-push runs tests, lint
    ↓
If pass: push succeeds
If fail: push blocked, agent fixes
    ↓
Creates PR: gh pr create --target sprint/S5-polish-auth
    ↓
Git Hook: post-push updates task status → READY_FOR_REVIEW
Done
```

---

## I3 (integrate.sh) — Cross-Module Integration Review

**Owner:** @Inta

**Script:** integrate.sh

**Called by:** Git Hook (on PR created/updated)

```
Git Hook triggers integrate.sh
    ↓
@Inta reads PR diff
    ↓
@Inta validates contracts between modules
    ↓
If OK: APPROVED → passes to I4
If issues: NEEDS_WORK → PR comment
    ↓
Git Hook: NEVER MERGE at this stage
Done
```

---

## I4 (review-prs.sh) — Code Review + Merge

**Owner:** @Archi

**Script:** review-prs.sh

**Called by:** Git Hook (on PR approval)

```
Git Hook triggers review-prs.sh
    ↓
@Archi reads PR diff
    ↓
@Archi validates code quality, spec, security
    ↓
If OK: APPROVED → Git Hook MERGES PR
If issues: NEEDS_WORK → PR comment
Done
```

---

## I5 — Fix Integration Issues

**Owner:** Module Agent

**Called by:** Git Hook (on PR comment)

**Internal flow:**
```
Agent reads NEEDS_WORK comment
    ↓
Creates fix branch: micro/fix/TXXX
    ↓
Implements fix
    ↓
Git Hook: pre-push tests
    ↓
Push → Git Hook triggers I3 → I4
    ↓
Repeat until clean
Done
```

---

## I6 (validate.sh) — Validate Epic

**Owner:** @Archi + Super

**Script:** validate.sh

**Called by:** Human (when all PRs merged)

```
bash scripts/bash/validate.sh specs/S5
    ↓
@Archi reviews all tasks
    ↓
Writes validation report
    ↓
Super reviews and approves
    ↓
Git Hook: merge sprint branch to main
Epic closed ✅
```

---

## Git Hooks Reference

| Event | Hook | Action |
|-------|------|--------|
| Push to micro/* | pre-push | Run tests, lint. Block if fail. |
| Push to micro/* (success) | post-push | Update task status → READY_FOR_REVIEW |
| PR created/updated | post-push | Trigger I3 integrate.sh |
| PR approved | post-approval | Trigger I4 review-prs.sh |
| PR merged to sprint | post-merge | Notify completion |
| All PRs merged | manual | Trigger I6 validate.sh |

---

## Full Workflow

```
Planning Phase ends
    ↓
P8: sprint-branch.sh → sprint/S5-polish-auth
    ↓
I1: implement.sh → spawn @api, @frontend agents
    ↓
I2: Agent implements → Git Hook: pre-push tests → PR created
    ↓
I3: Git Hook → @Inta validates contracts
    ↓
I4: Git Hook → @Archi reviews + MERGES
    ↓
I5: Fix if needed (Git Hook loop)
    ↓
I6: validate.sh → Super approves
    ↓
Git Hook: merge sprint to main
Epic closed ✅
```

---

## Scripts Reference

| Phase | Script | Owner | Called by | When | What's doing |
|-------|--------|-------|-----------|------|--------------|
| **P8** | sprint-branch.sh | @Archi | Automatic (P7 passed) | Planning ends | Creates sprint branch. All PRs target it. |
| I1 | implement.sh | @Archi | Git Hook | Sprint branch created | Spawns module agents in parallel |
| I2 | — | Module Agent | Git Hook | Agent spawned | Creates microbranch, implements, commits, creates PR, updates task |
| I3 | integrate.sh | @Inta | Git Hook | PR created/updated | Validates contracts between modules. NEVER merges. |
| I4 | review-prs.sh | @Archi | Git Hook | PR approved | Reviews code quality, SPEC compliance, micro-modules. MERGES. |
| I5 | — | Module Agent | Git Hook | NEEDS_WORK comment | Fixes issues, push triggers re-review loop |
| I6 | validate.sh | @Archi + Super | Human | All PRs merged | Validates epic. Super approves. Sprint branch merged to main. |
