# spec-kit → CADRE Adoption Plan

What to take from spec-kit, where it goes in CADRE, and what it fixes.

## Root Problem

CADRE is declarative governance. Agents can't execute declarations.
spec-kit is executable workflow. Agents follow it because prompts, templates, scripts, and validation loops leave no room for drift.

**CADRE needs spec-kit's enforcement mechanisms to become executable.**

---

## Adoption Table

| # | spec-kit Mechanism | Source File(s) | CADRE Target | What It Fixes | Priority | Status |
|---|---|---|---|---|---|---|
| M1 | **Agent-executable prompts** — step-by-step LLM instructions with ERROR conditions, format requirements, validation loops | `commands/specify.md`, `commands/plan.md`, `commands/tasks.md`, `commands/implement.md` | `commands/` | Invariants become executable. Agents get instructions, not declarations | 🔴 Critical | ☐ TODO |
| M2 | **Constraint templates** — forced structure that limits what agent can produce | `templates/spec-template.md`, `templates/plan-template.md`, `templates/tasks-template.md` | `templates/` | Artifacts are consistent. LLM output bounded by template, not free-form | 🔴 Critical | ☐ TODO |
| M3 | **Prerequisite scripts** — hard gates that verify artifacts exist before next phase | `scripts/check-prerequisites.sh`, `scripts/create-new-feature.sh`, `scripts/setup-plan.sh` | `scripts/` | Phases can't be skipped. Contract freeze is enforced, not requested | 🔴 Critical | ☐ TODO |
| M4 | **Self-validation loops** — agent checks own output, iterates up to N times | Validation in `commands/specify.md` (step 6), checklist check in `commands/implement.md` (step 2) | Inside `commands/` | Agents catch their own mistakes before handing off | 🟡 High | ☐ TODO |
| M5 | **Explicit handoffs** — frontmatter declares next phase + prompt | `handoffs` in every command frontmatter | `commands/` frontmatter | Workflow transitions are deterministic, not implicit | 🟡 High | ☐ TODO |
| M6 | **Hook system** — before/after hooks per phase, mandatory + optional | `extensions.yml` pattern in every command | `hooks/` | CADRE Assessment Gates become insertable mandatory hooks | 🟡 High | ☐ TODO |
| M7 | **Analyze command** — read-only cross-artifact consistency check | `commands/analyze.md` | `commands/assess.md` | Integration Agent + Validation Agent + Compliance Review in one executable step | 🔴 Critical | ☐ TODO |

---

## Adoption Sequence

### Phase 1: Foundation (M1 + M2 + M3) — make CADRE executable

1. Port spec-kit command pattern → `commands/specify.md` (System Specification)
2. Port spec-kit command pattern → `commands/plan.md` (Contract Freeze)
3. Port spec-kit command pattern → `commands/tasks.md` (Task Decomposition)
4. Port spec-kit command pattern → `commands/implement.md` (Execution)
5. Create CADRE-specific templates for each artifact type
6. Create prerequisite scripts for phase transitions

### Phase 2: Assessment (M7 + M4) — add what spec-kit lacks

7. Create `commands/assess.md` — CADRE Assessment Gate (readiness, completeness, contradiction, drift)
8. Add self-validation loops to each command
9. Create `commands/integrate.md` — Integration Agent cross-module check
10. Create `commands/validate.md` — Validation Agent evidence collection

### Phase 3: Governance (M5 + M6) — wire it together

11. Add handoffs to all commands
12. Create hook system for assessment gates
13. Create `commands/review.md` — Compliance & Readiness Review

### Phase 4: Multi-Agent (CADRE-only) — what spec-kit can't do

14. Add ownership model to templates (owner field on every artifact)
15. Add escalation protocol to commands
16. Add drift detection as periodic hook
17. Add parallel execution boundaries and contract enforcement
18. Create Role Registry template

---

## Pattern Extraction Rules

When porting a spec-kit mechanism to CADRE:

1. **Keep the enforcement pattern** (validation loops, ERROR conditions, prerequisite checks)
2. **Replace single-agent assumptions** with multi-agent ownership model
3. **Add CADRE invariant references** — each command step should cite which invariant it enforces
4. **Add assessment hooks** — before/after each phase, mandatory for CADRE compliance
5. **Keep templates constraint-driven** — templates restrict output, not suggest it

---

## Insight: clarify = Assessment Layer foundation

**Discovered during T2 test (2026-03-24):**

`clarify` is the natural place to expand CADRE Assessment capabilities. Currently covers completeness + contradiction only. Should be extended to become the full Assessment Layer covering all 4 dimensions:

1. **Completeness** ✅ (already in clarify)
2. **Contradiction** ✅ (already in clarify)
3. **Readiness** ❌ (needs to be added — owner assigned? deps available? env ready?)
4. **Drift** ❌ (needs to be added — scope matches original? contracts intact?)

The current `assess.md` command is a separate gate. Future consideration: merge assess into an expanded clarify that runs at multiple points (post-spec, post-plan, during execution) rather than only as a one-shot gate.

This means `clarify` evolves from "ask 5 questions about ambiguity" into "structured assessment that can run against any artifact set at any phase."

## Insight: Jira = Separate Operational Layer

**Discovered during T2 test (2026-03-24):**

Jira integration (CADRE I-07) is a separate layer on top of the framework, not part of core workflow. Core CADRE works without Jira:
- constitution → specify → clarify → plan → assess → tasks → analyze → implement

Jira layer adds:
- `cadre.taskstoissues` — sync tasks.md to Jira Epic + tickets
- Visual tracking surface (boards, status, assignment)
- Bidirectional sync (Jira status → tasks.md checkbox)

Build core framework first. Add Jira layer as optional integration.
