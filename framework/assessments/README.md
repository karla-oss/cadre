# ASSESSMENTS

TODO: Extract from CADRE v1 Notion spec
# CADRE Assessment Gates — Observations

## OBS-001: Gate Loop Protocol (2026-03-24)

**Rule**: Assessment gates (readiness, preflight, validate) run in a loop — max 3 iterations.

**Flow**:
```
Gate run → WARN/FAIL findings → assign to responsible agent → fix → re-run
                                          ↑_________________________|
                                    (max 3 loops total)
```

**Responsibility assignment rule**: assign to the agent with **maximum expertise** for the finding type:
- Contract contradiction → Archi
- Spec ambiguity → Puma
- Drift (plan vs spec) → Archi
- FR missing for implemented endpoint → Puma (spec owner)
- Tech decision conflict → Archi
- Security/NFR gap → Archi

**After 3 loops without resolution**:
- Escalate to Super via `escalate.sh`
- Document why it can't be resolved at current level
- Super decides: accept risk and proceed, or block

**Why max 3**: unbounded loops = blocked sprint. 3 iterations gives enough cycles to fix real issues without infinite gate ping-pong.

**Implementation needed**:
- `readiness.md`, `preflight.md`, `validate.md` should include this loop protocol explicitly
- Each re-run appends to the same report file under a dated header (already done for project-assess)
- Loop counter tracked in report header: `Run: 1/3`, `Run: 2/3`, etc.

## OBS-002: Parallel Agent Instances (2026-03-24)

**Observation**: `[P]` tasks within the same owner can be executed by multiple instances of the same agent type simultaneously.

**Example**: @api-agent-1 works on T017 (models.py), @api-agent-2 works on T019 (routers/projects.py) — both `[P] [@api-agent]`, different files, no shared state.

**Prerequisite for parallel spawn**:
- Tasks marked `[P]` within same owner
- Tasks touch strictly non-overlapping files (no shared file = no git conflict)
- Both instances load same expertise from sprint-config.md

**Performance gain**: reduces wall-clock time proportionally to parallel task count.

**Implementation needed**:
- Orchestrator reads `[P]` markers and groups by owner
- Groups with no file overlap → spawn N agent instances simultaneously
- Each instance receives: its specific task IDs + sprint-config expertise + file boundary list
- File boundary list must be explicit per instance (not whole module) to prevent overlap

**Risk**: if two parallel instances touch the same file → merge conflict. Mitigation: orchestrator must statically verify file disjointness before spawning. If overlap detected → serialize (no parallel spawn).
