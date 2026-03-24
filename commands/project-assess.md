---
description: "CADRE Project-Level Assessment — evaluates Project System Specification completeness, quality, and risk before the first Epic starts. Produces a readiness score and go/no-go recommendation."
cadre:
  phase: P0-project-assessment
  invariants: [I-01, I-06, I-10, I-11]
  role: archi
  level: project
  artifacts_required: [project-spec]
  artifacts_produced: [project-assess-report.md]
triggers:
  - condition: before first Epic is created
    trigger: manual — Archi runs on Super request
  - condition: Project Spec has been significantly updated
    trigger: manual — re-run to update score
---

## Purpose

This is the **CADRE Project-Level Assessment**. It runs at Project Level — above Epic Level.

Evaluates the **Project System Specification** (the top-level document owned by Super) before the first Epic begins. Produces a readiness score and go/no-go recommendation.

**Super approves the start** — even if spec is incomplete, it must be a conscious decision with documented risks.

**Theoretical basis:**
- IEEE 830-1998: SRS quality attributes (correct, unambiguous, complete, consistent, ranked, verifiable, modifiable, traceable)
- SEI/ATAM: architectural risk is measurable before implementation
- Boehm's cost-of-change curve: requirements defect found early costs 1x; in production costs 100-200x
- SAFe Epic model: MVP definition required before Portfolio approval

---

## Outline

1. **Load Project Spec**

   Read the Project System Specification. Location may be:
   - Local file: `project-spec.md` in repo root
   - Notion: provided as argument (page ID or URL) — read via Zapier MCP

   If spec not found:
   ```
   ❌ PROJECT SPEC NOT FOUND
   Create project-spec.md or provide Notion page ID.
   Cannot assess without the source document.
   ```

2. **Inventory sections**

   Map the spec against the required section taxonomy:

   | Section | Required | Weight |
   |---------|----------|--------|
   | Purpose / Why we're building this | YES | 15% |
   | For whom (personas / target users) | YES | 10% |
   | Goals and Non-goals | YES | 15% |
   | Functional requirements | YES | 20% |
   | System architecture / components | YES | 10% |
   | Non-functional requirements (perf, security, scale) | YES | 15% |
   | Success criteria / MVP definition | YES | 10% |
   | Deployment / Operations | NO | 5% |

   For each section mark status:
   - **COMPLETE** — substantive content, specific, not vague placeholders
   - **PARTIAL** — exists but thin, vague, or missing sub-items
   - **EMPTY** — missing or contains only TODO/TBD

3. **Score each section**

   Per section score:
   - COMPLETE → 100% of section weight
   - PARTIAL → 50% of section weight
   - EMPTY → 0% of section weight

   **Overall Readiness Score** = sum of weighted section scores

4. **Quality checks (IEEE 830)**

   For each COMPLETE or PARTIAL section, run quality pass:

   ### Q1: Unambiguous
   - No vague adjectives without measurable criteria ("fast", "scalable", "secure", "robust")
   - Each requirement has single interpretation
   - WARN per violation

   ### Q2: Verifiable
   - Success criteria are measurable (numbers, rates, thresholds)
   - Functional requirements have testable acceptance conditions
   - WARN if criteria are purely qualitative with no metric

   ### Q3: Consistent
   - No conflicting statements across sections
   - Goals don't contradict non-goals
   - NFR targets don't contradict architecture constraints
   - FAIL if hard contradiction found

   ### Q4: Ranked
   - Requirements have priority indicators (P1/P2/P3 or MoSCoW or equivalent)
   - WARN if all requirements are flat (no prioritisation)

   ### Q5: Traceable
   - Each functional requirement maps to at least one user persona
   - Architecture decisions trace to at least one NFR or functional requirement
   - WARN if orphan requirements found

   Quality penalty: each WARN = -2% from overall score. Each FAIL = -5%.

5. **Risk assessment**

   Identify high-risk gaps — sections where uncertainty is most expensive to fix later:

   | Risk | Trigger | Impact |
   |------|---------|--------|
   | CRITICAL | Any section with weight ≥10% is EMPTY | Automatic RED regardless of score |
   | HIGH | NFR section PARTIAL or EMPTY | Security/performance defects found in production |
   | HIGH | Goals/Non-goals PARTIAL or EMPTY | Scope creep, expensive rework |
   | HIGH | Success criteria EMPTY | No definition of done at project level |
   | MEDIUM | Architecture PARTIAL | Technical debt, integration surprises |
   | LOW | Deployment/Operations EMPTY | Deferred to later — acceptable |

6. **Produce assessment report**

   Write `project-assess-report.md`:

   ```markdown
   # CADRE Project Assessment Report

   **Project**: [project name]
   **Date**: [DATE]
   **Assessor**: Archi
   **Spec source**: [file path or Notion URL]

   ## Readiness Score: XX%

   **Verdict**: 🟢 GREEN / 🟡 YELLOW / 🔴 RED

   | Section | Status | Weight | Score | Notes |
   |---------|--------|--------|-------|-------|
   | Purpose / Why | COMPLETE | 15% | 15% | |
   | For whom | PARTIAL | 10% | 5% | Missing B2B persona |
   | Goals / Non-goals | COMPLETE | 15% | 15% | |
   | Functional requirements | PARTIAL | 20% | 10% | 3 of 8 FRs have no AC |
   | Architecture | EMPTY | 10% | 0% | ⚠️ HIGH RISK |
   | NFR | EMPTY | 15% | 0% | ⚠️ HIGH RISK — CRITICAL |
   | Success criteria | COMPLETE | 10% | 10% | |
   | Deployment / Ops | EMPTY | 5% | 0% | Acceptable |
   | **TOTAL** | | **100%** | **55%** | |

   Quality penalties: -4% (2 WARNs)
   **Adjusted Score: 51%** → 🔴 RED

   ## Risk Summary

   ### CRITICAL (blocks start)
   - NFR section EMPTY (weight 15%) → automatic RED

   ### HIGH
   - Architecture EMPTY — integration risks unknown
   - 3 functional requirements have no acceptance criteria

   ### MEDIUM
   - For whom: B2B persona not defined — Epic AC will be guesswork

   ## Quality Findings

   | Check | Status | Location | Issue |
   |-------|--------|----------|-------|
   | Q1 Unambiguous | WARN | FR-003 | "system must be fast" — no metric |
   | Q4 Ranked | WARN | Functional reqs | No priority indicators |

   ## Recommendation

   🔴 **DO NOT START** — fill CRITICAL gaps first.

   Required before start:
   1. NFR section: define performance targets, security requirements, scale assumptions
   2. Architecture: outline major components and integration points

   Acceptable to defer:
   - Deployment/Operations details
   - Full B2B persona (HIGH but not CRITICAL)

   ## Super Decision

   **Options:**
   - [ ] APPROVED — start after fixing CRITICAL gaps
   - [ ] APPROVED WITH RISK — start now, accept documented risks
   - [ ] HOLD — complete spec first

   **Super sign-off**: _________________ **Date**: _______
   ```

7. **Present to Super**

   ```
   📋 PROJECT ASSESSMENT COMPLETE

   Score: XX% → [GREEN/YELLOW/RED]
   Critical issues: N
   High risk: N
   Report: project-assess-report.md

   Super: review report and make go/no-go decision.
   This decision is yours alone (CADRE I-06).
   ```

---

## Scoring Reference

| Score | Verdict | Recommendation |
|-------|---------|----------------|
| ≥80% | 🟢 GREEN | Start approved — proceed to first Epic |
| 60-79% | 🟡 YELLOW | Start with documented risks — Super must acknowledge |
| <60% | 🔴 RED | Do not start — fill critical gaps first |

**Override rule**: Any section with weight ≥10% and status EMPTY → automatic RED, regardless of total score.

---

## Re-assessment

Run again after significant spec updates:
```
/cadre.project-assess [notion-page-id or file path]
```

Score history is preserved in `project-assess-report.md` under `## History` section.
New runs append a dated entry — progress is visible over time.
