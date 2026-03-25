# P3 — Clarify + Assessment

## Overview

P3 is split into two sequential phases:

```
P3.A (Clarify) → P3.B (Readiness Assessment)
```

**P3.A** is Puma ↔ Archi (AI-to-AI).
**P3.B** is Archi's technical validation (no user input required).

---

## Project Stage Definitions

| Stage | Focus | What's included |
|-------|-------|-----------------|
| **POC** | Prove it works | Happy path only. No security, no edge cases, no failure scenarios. |
| **MVP** | Simplest that works | Basic success + obvious failure paths. Minimal viable. |
| **Production** | Robust | Security, edge cases, failure scenarios, monitoring, scale |

**SpecForge current stage:** MVP

---

## P3.A — Clarify

**Owner:** Puma + Archi
**Input:** spec.md with [NEEDS CLARIFICATION] markers
**Output:** spec.md with answers recorded

### Purpose
Resolve ambiguities flagged during spec creation. Puma asks, Archi reasons.

### Process
1. Puma scans spec for [NEEDS CLARIFICATION] markers
2. Puma spawns @archi with clarification questions
3. Archi responds with stage-grounded reasoning
4. Puma updates spec.md with answers

---

### Archi Reasoning Framework

When Puma asks, Archi considers:

#### 1. Project Stage
| Stage | Archi's question |
|-------|------------------|
| **POC** | "Is this necessary to prove the concept works? If not, defer." |
| **MVP** | "Is this necessary for the simplest viable product? If not, defer." |
| **Production** | "Is this necessary for robustness, security, scale? Add it." |

#### 2. Spec Conflict and Drift Prevention

| Check | What | If conflict |
|-------|------|------------|
| **Contract** | Does this spec depend on existing frozen contracts? | Flag if contract not frozen |
| **Plan** | Does this spec drift from plan.md? | Document deviation |
| **Ownership** | Module overlap with other active specs? | Escalate to Super |
| **Phase** | Stage-appropriate complexity? | Defer non-essential to later phase |

---

### Archi Response Format

```markdown
**Question:** [The question from Puma]

**Decision:** [Option letter or short answer]

**Stage Reasoning:**
- [Why this fits current stage]
- [What we defer to later stage]

**Contract Impact:**
- [Existing contracts affected?]
- [New contracts needed?]

**Spec Drift Risk:**
- [Conflicts with plan.md?]
- [Deviations from existing architecture?]
```

---

### Examples — Same Question, Different Stage

#### Q: "How do we handle password hashing?"

```
POC:  → "No hashing. Store as-is. POC = no security."
MVP:  → "bcrypt with default cost. Simple, works."
Prod: → "bcrypt cost=12. Password history (last 5). Breach check API. Rate limiting."
```

#### Q: "JWT token expiration?"

```
POC:  → "No expiration. Token lives forever. Works for testing."
MVP:  → "7-day expiration. Stateless, simple."
Prod: → "15-min access + 7-day refresh rotation. Blocklist. Re-auth for sensitive ops."
```

#### Q: "Account deletion?"

```
POC:  → "DELETE FROM users WHERE id = X. Done."
MVP:  → "Cascade delete user + projects + inputs. Irreversible in AC is enough."
Prod: → "Soft delete (deleted_at). 30-day retention. Audit log. Backup before delete.
         User notification before permanent removal."
```

#### Q: "Error messages?"

```
POC:  → "Technical errors visible. It's POC."
MVP:  → "'Something went wrong' for 500s. Inline validation for 400s."
Prod: → "Human-readable, consistent, actionable. No stack traces.
         Structured logging. Error tracking (Sentry)."
```

#### Q: "Session/logout?"

```
POC:  → "No logout. Close browser."
MVP:  → "Token expires in 7 days. That's the logout."
Prod: → "Token blocklist OR refresh rotation. 'Log out everywhere' button.
         Session dashboard in settings."
```

#### Q: "Email verification on registration?"

```
POC:  → "No email. Just username/password."
MVP:  → "No verification. Immediate access. Add abuse monitoring."
Prod: → "Verification required. Resend option. Verified flag in DB."
```

#### Q: "Password recovery?"

```
POC:  → "No recovery. Create new account."
MVP:  → "No recovery. Document: 'forgot password = delete and re-register.'"
Prod: → "Email reset link. Token expiration. Rate limiting. Account lockout."
```

---

## P3.B — Readiness Assessment

**Owner:** Archi
**Input:** spec.md (clarified)
**Output:** assessment-report.md

### Purpose
Technical validation before planning. Catch problems early.

### Assessment Dimensions

| Dimension | What to Check |
|-----------|---------------|
| **Completeness** | All required sections filled, no empty mandatory sections |
| **Contradiction** | No conflicting statements within spec |
| **Drift** | Spec vs plan — any deviations from agreed architecture? |
| **Technical** | Feasibility, stage constraints violations, missing NFRs |
| **Contracts** | Dependencies on frozen contracts, contract gaps |
| **Scope** | Clear in/out of scope, no ambiguous requirements |

### Gate Criteria

```
P3.B PASS:
- 0 contradictions
- 0 critical gaps (in completeness)
- All [NEEDS CLARIFICATION] markers resolved in P3.A
- Drift items documented and accepted

P3.B FAIL:
- Contradictions found → return to P3.A
- Critical gaps → spec update required
- Major drift → escalate to Super
```

### Loop Protocol
- Max 3 iterations through P3.B
- If not resolved after 3 → escalate to Super via `escalate.sh`

---

## Scripts

| Script | Phase | Owner |
|--------|-------|-------|
| `clarify.sh` | P3.A | Puma + Archi |
| `assess.sh` | P3.B | Archi |

---

## Workflow Example

```
S5-Polish+Auth:
  P2 (specify) → @puma fills spec.md

  P3.A (clarify) → Puma spawns @archi with questions
                 → Archi responds with MVP reasoning
                 → Puma updates spec.md

  P3.B (assessment) → @archi runs assess.sh
                   → archi writes assessment-report.md
                   → If PASS → proceed to P4
                   → If FAIL → spec update → re-run P3.A
```

---

## CADRE Phase Mapping

| Phase | Command | Owner |
|-------|---------|-------|
| P1 | constitution | Super |
| P2 | specify | Puma |
| P3.A | clarify | Puma + Archi |
| P3.B | assess | Archi |
| P4 | plan | Archi |
| P5 | readiness | Gate |
| P6a | tasks | Puma |
| P6b | preflight | Archi |
| P8 | implement | Module agents |
| P8b | review | Archi |
| validate | validate | Super |
