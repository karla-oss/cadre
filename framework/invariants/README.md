# CADRE Invariants

Core rules that must never be violated. Phase-gated rules enforced at specific gates. Principles are guidance, not mechanically enforced.

---

## Core (never violated)

| ID | Name | Rule |
|----|------|------|
| I-01 | Contract Compliance | Only frozen contracts define endpoints, entities, and data shapes. No invented entities. |
| I-02 | Ownership | One owner per artifact. Changes outside owned boundary require escalation. |
| I-03 | Bounded Execution | One task = one module boundary. Task ≠ sprint. |
| I-04 | Contract-First | Spec → contracts → implementation. Never code-first. |
| I-06 | Review Protocol | Two-step: review-request.sh (draft) → review-submit.sh (submit) → review-approve.sh (approve). Archi cannot reconstruct self-check boxes. |

---

## Phase-Gated

| ID | Name | Rule | Gate |
|----|------|------|------|
| I-07 | Gate Before Execution | Readiness Gate (P5) + Preflight Gate (P6b) must pass before implement. | P5, P6b |
| I-08 | Epic Close Gate | Validate passes before Epic close. | P9 |

---

## Principles (guidance)

| ID | Name | Rule |
|----|------|------|
| I-10 | Micro-Modules | File ≤ 150 lines. If exceeded, split before finish. |
| I-11 | Single Responsibility | One file = one responsibility group. |
| I-12 | No Magic Numbers | Thresholds defined in contracts, not hardcoded. |

---

## Anti-Patterns

| Pattern | Why Violation |
|---------|---------------|
| Invented endpoint | I-01: only frozen contracts define API surface |
| Cross-boundary commit | I-02, I-03: ownership + bounded execution |
| Self-check boxes unchecked | I-06: module agent must complete C3 |
| Spec after code | I-04: contract-first violation |
| Bypass gate | I-07: implementation without readiness/preflight |

---

## Full Context

Detailed explanations and examples: `framework/assessments/README.md` (OBS-001 — Gate Loop Protocol)
