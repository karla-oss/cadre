# Sprint Configuration

**Sprint**: [NUMBER]
**Epic**: [feature-branch-name]
**Date**: [DATE]
**Author**: Archi
**Status**: draft | frozen

> This file is produced by Archi during `/cadre.plan` as part of Contract Freeze.
> Frozen on the same date as contracts/. Changes require Archi approval.
> Module agents read their section to load expertise at spawn time.

---

## Module Agents

<!-- One section per module. Archi defines these based on plan.md tech decisions. -->

### @[module]-agent

**Module boundary**: `[module]/` — agent touches ONLY these files

**Expertise declaration** (loaded at spawn):
- **Language**: [e.g. Python 3.11]
- **Framework**: [e.g. FastAPI + uvicorn]
- **Storage**: [e.g. SQLite, PostgreSQL, Redis]
- **Testing**: [e.g. pytest + TestClient + httpx]
- **Key patterns**: [e.g. Pydantic v2 models, dependency injection, async handlers]
- **HTTP semantics**: [e.g. REST, status codes, error format per api-contract.md]

**Does NOT know about**: [other modules — list explicitly]

---

### @[module2]-agent

**Module boundary**: `[module2]/`

**Expertise declaration**:
- **Language**:
- **Framework**:
- **Testing**:
- **Key patterns**:

**Does NOT know about**:

---

## Inta Expertise Context

<!-- Inta reads this to know what tech stack to expect when running integration checks -->

**Producer modules**: [@api-agent → contracts/api-contract.md]
**Consumer modules**: [@cli-agent → calls api-contract.md endpoints]
**Integration test paths**: [e.g. api/tests/test_api.py, cli/tests/test_cli.py]
**Expected test runner**: [e.g. pytest from repo root]

---

## Freeze Status

| Artifact | Frozen | Date |
|----------|--------|------|
| data-model.md | [ ] | |
| contracts/api-contract.md | [ ] | |
| sprint-config.md | [ ] | |

**All three must be frozen before implementation begins (CADRE I-01).**
