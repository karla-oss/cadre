# Import Log — spec-kit → CADRE

Source: github/spec-kit (cloned 2026-03-24)

## Imported 1:1 (no changes needed)

These files work as-is. They define single-agent workflow that becomes the Module Agent workflow in CADRE.

### Templates (constraint forms)

| File | Source | Notes |
|---|---|---|
| `templates/specs/system-spec-template.md` | `spec-template.md` | User stories, ACs, requirements, success criteria. Format-agnostic |
| `templates/plans/plan-template.md` | `plan-template.md` | Tech context, constitution gates, project structure, complexity tracking |
| `templates/tasks/tasks-template.md` | `tasks-template.md` | Phase structure, [P] markers, [Story] labels, checkpoints |
| `templates/constitution-template.md` | `constitution-template.md` | Principles, governance, versioning |
| `templates/reports/checklist-template.md` | `checklist-template.md` | Domain-specific quality checklists |

### Commands (agent prompts)

| File | Source | Works as-is? | CADRE adaptation needed |
|---|---|---|---|
| `commands/specify.md` | `commands/specify.md` | ✅ Yes | Later: add ownership field, Epic linkage |
| `commands/plan.md` | `commands/plan.md` | ✅ Yes | Later: add contract freeze gate, assessment trigger |
| `commands/tasks.md` | `commands/tasks.md` | ✅ Yes | Later: add owner per task, escalation path |
| `commands/implement.md` | `commands/implement.md` | ✅ Yes | Later: add bounded scope enforcement, drift check |
| `commands/clarify.md` | `commands/clarify.md` | ✅ Yes | Maps to assessment function (completeness + contradiction) |
| `commands/analyze.md` | `commands/analyze.md` | ✅ Yes | Closest to CADRE Assessment Gate. Later: add readiness + drift dimensions |
| `commands/checklist.md` | `commands/checklist.md` | ✅ Yes | Domain checklists as validation artifacts |
| `commands/constitution.md` | `commands/constitution.md` | ✅ Yes | Later: extend to Project Mapping Spec format |

### Scripts (hard gates)

| File | Source | Notes |
|---|---|---|
| `scripts/bash/check-prerequisites.sh` | Same | Verifies artifacts exist before phase transition |
| `scripts/bash/common.sh` | Same | Shared utilities |
| `scripts/bash/create-new-feature.sh` | Same | Branch + directory + template scaffolding |
| `scripts/bash/setup-plan.sh` | Same | Pre-plan validation |
| `scripts/bash/update-agent-context.sh` | Same | Agent config update |

## Not yet imported (CADRE-specific, to build)

| Target | Purpose | Priority |
|---|---|---|
| `commands/assess.md` | Assessment Gate — readiness, completeness, contradiction, drift | 🔴 Phase 2 |
| `commands/integrate.md` | Integration Agent — cross-module contract compliance | 🔴 Phase 2 |
| `commands/validate.md` | Validation Agent — evidence collection, ReadinessReport | 🟡 Phase 3 |
| `commands/review.md` | Compliance & Readiness Review — go/no-go | 🟡 Phase 3 |
| `templates/contracts/` | API + data contract templates with ownership | 🟡 Phase 2 |
| `templates/reports/readiness-report-template.md` | ReadinessReport template | 🟡 Phase 3 |
| `templates/reports/escalation-record-template.md` | Escalation Record template | 🟡 Phase 3 |
| `hooks/extensions.yml` | Hook definitions for assessment gates | 🟡 Phase 3 |
| `framework/invariants/*.md` | 12 invariants extracted from CADRE v1 | Phase 2 |
| `framework/roles/*.md` | Role definitions with authority model | Phase 2 |
