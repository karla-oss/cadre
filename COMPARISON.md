# CADRE ↔ spec-kit Framework Comparison

**Status:** Draft
**Date:** 2026-03-24
**Notion:** https://www.notion.so/CADRE-vs-spec-kit-Framework-Comparison-32d372dc2ae781eda7eef6828b536d03

Key insight: spec-kit operates at single-agent, single-feature scope. CADRE operates at multi-agent, multi-module project scope. Complementary layers, not competitors.

---

## Table 1: Artifacts

| # | spec-kit Artifact | Essence (spec-kit) | CADRE Equivalent | Essence (CADRE) | Jira Surface | Fit |
|---|---|---|---|---|---|---|
| A1 | `constitution.md` | Immutable project principles, quality gates | Project Mapping Spec + Core Invariants | Per-project governance + framework invariants | — | ✅ Direct |
| A2 | `spec.md` | System Specification — scope, user scenarios | System Spec → generates Epic(s) | Source of truth for work scope | Epic | ⭐ Key |
| A3 | `plan.md` | Decomposition: spec → tasks with AC, DoD, tech decisions | Contract Freeze + Assessment Gate trigger | Decomposition + launches assessments | Epic → Stories | ⭐ Key |
| A4 | `data-model.md` | Entity schemas, relationships | Shared Contract (data) | Frozen schema for parallel modules | — | ⭐ Contract |
| A5 | `contracts/` | API boundaries, interface definitions | Shared Contract (API) | Frozen interface between modules | — | ⭐ Contract |
| A6 | `research.md` | Alternatives, benchmarks, comparisons | Exploration Agent output | Pre-freeze exploration | — | ✅ Direct |
| A7 | `tasks.md` | Work units with `[P]` markers, `[Story]` labels | Tasks within Epic | Work unit → Deliverable OR Reasoned Rejection | Task | ⭐ Key |
| A8 | `quickstart.md` | Validation scenarios | Validation evidence | Input for I-10 Evidence-Based Readiness | — | ✅ Direct |
| A9 | `checklist.md` | Requirement completeness check | Compliance Review checklist | Structured assessment | — | ✅ Direct |
| A10 | ❌ | Not in spec-kit | Role Registry | Ownership: who owns what, authority chain | — | 🔴 Gap |
| A11 | ❌ | Not in spec-kit | ReadinessReport | Go/no-go assessment with evidence | — | 🔴 Gap |
| A12 | ❌ | Not in spec-kit | Escalation Record | Documented boundary violation decision | — | 🔴 Gap |
| A13 | ❌ | Not in spec-kit | Assessment Gate | Checkpoint: readiness, completeness, contradiction, drift | — | 🔴 Gap |

### Key Artifact Chain
```
constitution → spec (System Spec) → plan (Decomposition) → [Assessment Gate] → tasks (Execution) → deliverables
```

### Notes
- A2: spec.md is a System Specification (foundation for Epics), not a Jira ticket
- A3: plan.md triggers (1) contract freeze per I-01 and (2) assessment gate
- A7: task result = Deliverable OR Reasoned Rejection. Tasks cannot stall
- A4+A5 are CADRE frozen contracts — must exist before parallel work (I-01)

---

## Table 2: Roles

| # | CADRE Role | Authority Level | spec-kit Equivalent | How Realized | Fit |
|---|---|---|---|---|---|
| R1 | Human Supervisor | Final authority, escalation, exceptions | User (developer) | Writes spec, approves plan, reviews | ✅ Implicit |
| R2 | Architect / Contract Governor | Owns contracts, boundaries, freezes | `/speckit.plan` + `constitution.md` | Function exists, dedicated role doesn't | ⚠️ Partial |
| R3 | PM / Workflow Agent | Decomposition, task flow, tracking | `/speckit.specify` + `/speckit.tasks` | Decomposition yes, tracking/ownership no | ⚠️ Partial |
| R4 | Module Agent (Worker) | Executes within owned scope → deliverables | `/speckit.implement` | One agent, sequential | ✅ Direct |
| R5 | Integration Agent | Cross-module consistency, contract compliance | ❌ | Not present | 🔴 Gap |
| R6 | Validation Agent | Evidence-based checks, readiness, go/no-go | Constitution Gates + `quickstart.md` | Pre-gates yes, post-validation no | ⚠️ Partial |
| R7 | Exploration Agent | Advisory, widens solution space | `research.md` | Alternatives, benchmarks | ✅ Direct |
| R8 | Assessment Function | Checkpoint between plan and execution | `/speckit.clarify` (partial) | Completeness + contradiction only. No readiness/drift | ⚠️ Partial |

### Assessment Dimensions in Roles
- Completeness: ✅ covered by `/speckit.clarify`
- Contradiction: ✅ covered by `/speckit.clarify`
- Readiness: 🔴 Gap
- Drift: 🔴 Gap

---

## Table 3: Workflow Phases

| # | Phase | spec-kit | CADRE | Input | Output | Owner (CADRE) | Fit |
|---|---|---|---|---|---|---|---|
| P1 | Governance Setup | `/speckit.constitution` | Project Mapping Spec + Role Registry | Scope, team, principles | constitution.md | Human Supervisor + Architect | ✅ |
| P2 | System Specification | `/speckit.specify` | Human Supervisor → Epic | Idea, requirements | spec.md → Epic | Human Supervisor / PM | ✅ |
| P3 | Exploration | `/speckit.clarify` + research.md | Exploration Agent + partial Assessment | Ambiguities, unknowns | research.md, clarified spec | Exploration Agent | ⚠️ Partial |
| P4 | Contract Freeze | `/speckit.plan` | I-01: Contract Freeze | Approved spec | plan.md + data-model.md + contracts/ | Architect | ⭐ Key |
| P5 | Assessment Gate | ❌ | Readiness/Completeness/Contradiction/Drift | plan, contracts, spec | Assessment Report, go/no-go | Validation + Architect | 🔴 Gap |
| P6 | Task Decomposition | `/speckit.tasks` | PM → Jira tickets + owners | plan, contracts | tasks.md → Tasks | PM | ⚠️ Partial |
| P7 | Parallel Execution | `/speckit.implement` (1 agent) | Module Agents (N agents) | Tasks, contracts | Deliverables / Rejections | Module Agent(s) | ⚠️ Partial |
| P8 | Integration | ❌ | Integration Agent | Deliverables, contracts | Compliance report | Integration Agent | 🔴 Gap |
| P9 | Validation | Gates + quickstart (pre) | Validation Agent | Deliverables, evidence | ReadinessReport | Validation Agent | ⚠️ Partial |
| P10 | Review & Release | ❌ | Compliance Review → Human decision | ReadinessReport | Merge/release decision | Human Supervisor | 🔴 Gap |

### Key Flow Differences
- **spec-kit:** P1 → P2 → P3 → P4 → P6 → P7 (linear, single agent, no gates)
- **CADRE:** P1 → P2 → P3 → P4 → **P5** → P6 → P7 → **P8** → **P9** → **P10** (gates, parallel, multi-agent)
- 3 phases absent in spec-kit: P5, P8, P10
- 2 phases partial: P3, P9

---

## Table 4: Assessment Dimensions

| # | Dimension | When | What it checks | spec-kit | CADRE | Fit |
|---|---|---|---|---|---|---|
| D1 | Completeness | After plan (P5) | All spec aspects covered? Gaps in contracts/tasks? | `/speckit.clarify` + `[NEEDS CLARIFICATION]` | Compliance Review | ✅ |
| D2 | Contradiction | After plan (P5) | Conflicts between tasks? Between contracts and spec? | `/speckit.clarify` | Compliance Review | ✅ |
| D3 | Readiness | After plan (P5) | Dependencies available? Env ready? Ownership assigned? | ❌ | Readiness Review | 🔴 Gap |
| D4 | Drift | During execution | Deviated from spec? Contracts violated? Scope expanded? | ❌ | Compliance Review (triggered) | 🔴 Gap |
| D5 | Contract Compliance | At integration (P8) | Modules match frozen contracts? APIs intact? | ❌ (implicit via tests) | Integration Agent | 🔴 Gap |
| D6 | Evidence Sufficiency | At validation (P9) | Proof that deliverable works? Tests passed? | `quickstart.md` + Gates (pre) | I-10 Evidence-Based Readiness | ⚠️ Partial |

---

## Table 5: Gap Summary

| # | Gap | Severity | Why Critical | CADRE Solution | Proposal |
|---|---|---|---|---|---|
| G1 | Assessment Gate absent | 🔴 Critical | Plan → Execute without check = primary drift source | Mandatory P5 with 4 dimensions | Add gate between plan and tasks |
| G2 | Integration Agent absent | 🔴 Critical | 3+ modules → nobody verifies stitch | Dedicated role R5 | Add integration phase |
| G3 | Drift Detection absent | 🔴 Critical | Long execution without checks = unnoticed deviation | Compliance Review triggered | Periodic drift check |
| G4 | Ownership Model absent | 🟡 High | Who owns contract? Who escalates? | Role Registry + I-02 | Owner field on artifacts/tasks |
| G5 | Readiness Assessment absent | 🟡 High | Starting execution without readiness check | Readiness Review | Readiness checklist |
| G6 | Post-validation absent | 🟡 High | Code written — who collects evidence? | Validation Agent + Report | Validation phase |
| G7 | Escalation Protocol absent | 🟡 High | Module conflict — no resolution path | I-06 + Escalation Record | Escalation path |
| G8 | Formal Review absent | 🟡 Medium | No go/no-go before release | P10 Review | Review phase |
| G9 | Parallel Model limited | 🟡 Medium | 1 agent vs N agents | I-03 + ownership | Add ownership + boundaries |
