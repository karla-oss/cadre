# CADRE Workflow

## Project Phases

CADRE adapts its process strictness based on the project phase declared in `constitution.md`.

```
phase: poc | mvp | production
```

---

## Phase: POC (Proof of Concept)

**Goal**: Validate the core hypothesis. Speed > process.

**When to use**: First sprint of a new project, or experimental feature with high uncertainty.

| Gate | Strictness | Notes |
|------|-----------|-------|
| P0 project-assess | SKIP | No formal assessment needed |
| P5 readiness | WARN → auto-proceed | No Super escalation on WARN |
| P6b preflight | SKIP | Optional |
| P8b review (Archi) | OPTIONAL | Super may review directly |
| P8c integrate (Inta) | SKIP | Single module = no integration needed |
| P9 validate | SIMPLIFIED | Super reviews output, no formal report |

**Constitution**: Minimal — 1-3 principles max. Focus on the riskiest assumption.

**Contracts**: Draft only — not frozen. Can change freely.

**Review**: Optional per-task review. Super sees output directly.

**Outcome**: "Does this work at all?" — yes/no answer, not a shippable product.

---

## Phase: MVP (Minimum Viable Product)

**Goal**: First real users. Reliability matters. Balance speed and process.

**When to use**: Once hypothesis is validated, building toward first external users.

| Gate | Strictness | Notes |
|------|-----------|-------|
| P0 project-assess | REQUIRED | Score ≥60% to start |
| P5 readiness | REQUIRED | FAIL blocks progress |
| P6b preflight | REQUIRED | FAIL blocks implementation |
| P8b review (Archi) | REQUIRED | Every task reviewed before commit |
| P8c integrate (Inta) | REQUIRED | Multi-module verification |
| P9 validate | REQUIRED | Full report, Super sign-off |

**Constitution**: Full — all principles active.

**Contracts**: Frozen at P4. Changes require Archi approval + re-assessment.

**Review**: Full Archi review per task. C3 self-check mandatory.

**Outcome**: "Can we give this to real users?" — shippable increment.

---

## Phase: Production

**Goal**: Scale, reliability, team. Everything from MVP plus:

| Addition | Description |
|----------|-------------|
| @infra-agent | Mandatory every sprint with infra changes |
| Security gate | Separate security review before deploy |
| Performance gate | Benchmarks against NFRs before Epic close |
| Rollback plan | Required in validate-report.md |
| On-call runbook | Required before production deploy |
| Load test | Required before P9 validate passes |

**Constitution**: Full + production addenda (SLA, on-call, incident response).

**Contracts**: Versioned. Breaking changes require deprecation period.

**Outcome**: "Does this work under load and without us?" — production-grade.

---

## How to Declare Phase

In `memory/constitution.md`:

```markdown
## Project Phase

**Phase**: mvp

**Phase escalation criteria**:
- POC → MVP: hypothesis validated, first external user sprint
- MVP → Production: >100 active users OR team >3 people OR SLA required
```

## Gate Behavior by Phase

| Gate | POC | MVP | Production |
|------|-----|-----|------------|
| P0 project-assess | SKIP | REQUIRED ≥60% | REQUIRED ≥80% |
| P5 readiness WARN | auto-proceed | Super acknowledges | blocks |
| P5 readiness FAIL | auto-proceed | blocks | blocks |
| P6b preflight | SKIP | REQUIRED | REQUIRED |
| P8b review | OPTIONAL | REQUIRED | REQUIRED |
| P8c integrate | SKIP | REQUIRED | REQUIRED |
| P9 validate | SIMPLIFIED | FULL | FULL + perf + security |
| Infra agent | optional | optional | REQUIRED |

## Loop Protocol (all phases)

Assessment gates run max 3 iterations. See `framework/assessments/README.md` OBS-001.
