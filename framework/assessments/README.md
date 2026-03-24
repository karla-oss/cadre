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

## OBS-003: Infra Files Need Explicit Ownership (2026-03-24)

**Observation**: Infrastructure files (docker-compose.yml, Makefile, .env.example, .github/, nginx.conf) live in repo root — outside all module boundaries (api/, cli/, frontend/, etc.). Current ownership model has no home for them.

**Problem**: 
- preflight D2 (Ownership Compliance) flags them as boundary violations
- Any module agent that touches them technically violates I-03
- docker-compose.yml is often owned by whoever started the project → implicit, not declared

**Solution: Add `@infra-agent` role (or "shared root" zone) to sprint-config.md**

```markdown
### @infra-agent (or: Shared Root)
**Module boundary**: repo root files ONLY
  - docker-compose.yml
  - Makefile
  - .env.example
  - .dockerignore, .gitignore
  - README.md (project-level)
**Does NOT touch**: any module subdirectory
```

**Alternative**: designate Archi as infra owner for small projects. Archi already owns plan.md (repo root). Consistent with technical authority role.

**Implementation needed**:
- sprint-config-template.md: add optional `@infra-agent` section with explicit root file list
- tasks.md rules: `[@infra-agent]` or `[@archi]` for root-level tasks
- preflight D2 check: exclude known infra files from boundary violation warnings IF declared in sprint-config

## OBS-002a: Conflict Resolution for Parallel Agents (addendum)

**Clarification to OBS-002**: The "strictly non-overlapping files" rule is a simplification.

In practice, **merge conflicts are a normal part of development** — not a blocker for parallel spawning.

**Revised approach**:
- `[P]` = safe to run in parallel regardless of file overlap
- File overlap → git merge conflict on completion → resolved by Archi before commit
- Archi's review step (P8b) is the natural conflict resolution point

**Two tiers of parallelism**:
1. **Clean parallel** (different files): agents commit independently, no merge needed
2. **Conflicting parallel** (shared files): agents work concurrently, Archi merges on review

**Orchestrator responsibility**:
- Detect file overlap statically from task descriptions
- For clean parallel: spawn N instances, each auto-commits via review-approve.sh
- For conflicting parallel: spawn N instances, collect all outputs, Archi reviews and merges manually before committing

**No need to serialize** purely to avoid conflicts. Conflicts = expected = handled by Archi.

## OBS-004: review-request.sh Must Be Non-Negotiable (2026-03-24)

**Incident**: @ingestion-agent completed Phase 1 tasks but did not run `review-request.sh`. Archi reconstructed review-request files from filesystem evidence and approved anyway.

**Problem**: This bypasses the review protocol entirely. If Archi can reconstruct + approve without a formal review-request, the protocol is optional in practice.

**Rule**: Archi MUST NOT reconstruct review-request files. If review-request file is missing:
1. Task is NOT in queue → Archi cannot review it
2. Archi notes the gap in review-status output
3. Archi sends NEEDS_WORK signal back to orchestrator
4. Orchestrator re-spawns module agent with explicit instruction to run review-request.sh
5. Only then does the task enter the queue

**Enforcement**: review-approve.sh should check that review-request/T00X.md was created by the agent (not Archi). Add a `created_by` field to review-request template.

## OBS-005: Self-Check C3 Phased Enforcement (2026-03-24)

**Observation**: Phase 1 (scaffolding) tasks had all self-check boxes unchecked. Archi approved anyway — correct decision for scaffolding.

**Rule**: C3 (Self-check) enforcement is phase-dependent:
- **Phase 1 (Setup)**: C3 optional — no contracts to check, no logic to verify
- **Phase 2+ (Contract Tests, Implementation)**: C3 MANDATORY — all boxes must be checked before Archi can approve
- Unchecked C3 in Phase 2+ = automatic NEEDS_WORK, no exceptions

**Add to review.md**: explicit phase-aware C3 rule.

## OBS-006: Plan-Level Addenda Need Explicit Annotation (2026-03-24)

**Observation**: Archi added `pending` status to AnalysisRun during Contract Freeze (P4) — a correct architectural decision, but not present in spec.md.

**Problem**: This is Drift ① — plan introduced an entity field not traceable to spec. Readiness Gate (P5) D4 would catch this as WARN.

**Rule**: When Archi makes additive decisions during plan that aren't in spec:
1. Add explicit `## Addenda` section in plan.md
2. For each addendum: `What was added`, `Why`, `Spec reference closest to it`
3. This creates a documented trail: spec → plan addendum → implementation

**Why not escalate to Puma?**: Small implemention-level additions (status enum values, internal tracking fields) are Archi authority. Only scope-level additions (new user stories, new functional requirements) need Puma/Super.

**Threshold**: Archi can add without escalation if:
- Doesn't change observable user behavior
- Doesn't affect acceptance criteria
- Is purely technical implementation detail

`pending` status = PASS (internal tracking, not user-visible behavior change).

## OBS-007: task-commit.sh Must Scope to Module Boundary (2026-03-24)

**Incident**: @frontend-agent bundled api/, ingestion/, and frontend/ changes into a single commit labeled T030. T039 (ingestion/parser.py) was never committed separately. Cross-boundary bundling violates NOTE-001 (task=commit) and CADRE I-03 (bounded execution).

**Root cause**: `task-commit.sh` runs `git add -A` — stages ALL changes in working tree regardless of module boundary.

**Fix needed in task-commit.sh**:
- Add optional `--path <dir>` flag
- If `--path` provided: `git add <dir>` instead of `git add -A`
- Module agents must be instructed to pass their module path: `bash task-commit.sh T001 "desc" --path api/`
- If cross-boundary files detected in staged area → WARN or BLOCK

**Enforcement in implement.md**:
After each task, agent runs:
```bash
bash scripts/bash/task-commit.sh T001 "description" --path <module_dir>
```
Where `<module_dir>` is declared in sprint-config.md module boundary.

**Why it matters**: Commit bundling makes git history unreadable, breaks `validate-commits.sh` audit, and hides which task introduced which change.

## OBS-008: review-request.sh Two-Step Protocol Required (2026-03-24)

**Pattern**: 4 consecutive failures of @frontend-agent submitting unchecked C3 boxes. Same class every time.

**Root cause**: `review-request.sh` creates the file AND sets status=ready-for-review in one step. Agent runs the script, file is created with `[ ]` boxes, agent exits. Script's C3 gate runs AFTER file is created — but agent is already done.

**Fix: Split into two commands**:
1. `review-request.sh T056 "desc"` → creates review-request/T056.md with `- [ ]` boxes, status=`draft`, prints "EDIT self-check boxes, then run: review-submit.sh T056"
2. `review-submit.sh T056` → checks C3 (all `[x]`), if PASS → sets status=`ready-for-review`, adds to queue

**Why this works**: Agent CANNOT skip the edit step — review-submit.sh blocks until boxes are checked. The workflow forces the two-step explicitly.

**Current workaround**: Archi/orchestrator manually fixes review-request files when C3 fails. Acceptable for now, should be automated.

**Priority**: HIGH — fix before T3 test run.
