---
description: Execute Contract Freeze — decompose spec into plan, data-model, and API contracts. Triggers CADRE Assessment Gate.
cadre:
  phase: P4-contract-freeze
  invariants: [I-01, I-02, I-04, I-05, I-11]
  owner_required: true
  artifacts_produced: [plan.md, data-model.md, contracts/, research.md, quickstart.md, sprint-config.md]
  artifacts_required: [spec.md, constitution.md]
  triggers_assessment: true
handoffs: 
  - label: Run Assessment Gate
    agent: cadre.readiness
    prompt: Run readiness, completeness, contradiction, and drift assessment on the plan
    send: true
  - label: Create Tasks
    agent: cadre.tasks
    prompt: Break the plan into tasks
  - label: Create Checklist
    agent: cadre.checklist
    prompt: Create a checklist for the following domain...
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/setup-plan.ps1 -Json
agent_scripts:
  sh: scripts/bash/update-agent-context.sh __AGENT__
  ps: scripts/powershell/update-agent-context.ps1 -AgentType __AGENT__
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before planning)**:
- Check if `.cadre/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_plan` key
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Pre-Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```
  - **Mandatory hook** (`optional: false`):
    ```
    ## Extension Hooks

    **Automatic Pre-Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}

    Wait for the result of the hook command before proceeding to the Outline.
    ```
- If no hooks are registered or `.cadre/extensions.yml` does not exist, skip silently

## Outline

1. **Setup**: Run `{SCRIPT}` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load context**: Read FEATURE_SPEC and `/memory/constitution.md`. Load IMPL_PLAN template (already copied).

3. **CADRE Pre-Plan Validation** (I-02):
   - Check FEATURE_SPEC for `## CADRE Metadata` section
   - If missing: ERROR "Run /cadre.specify first — spec has no CADRE Metadata"
   - If `[NEEDS OWNER]` present: ERROR "CADRE I-02: Spec owner must be assigned before planning. Update CADRE Metadata."
   - If `Status` is not `Approved` or `Under Review`: WARN "Spec status is Draft — consider getting approval before freezing contracts"

4. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md
   - Phase 1: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

5. **CADRE Contract Freeze** (I-01):
   - Add `## CADRE Contract Status` section to plan.md:
     ```markdown
     ## CADRE Contract Status
     - **Frozen contracts**: [list data-model.md + each file in contracts/ + sprint-config.md]
     - **Contract owner**: [Architect / Contract Governor]
     - **Freeze date**: [DATE]
     - **Status**: Frozen — changes require Architect approval and re-assessment
     - **Dependent modules**: [list modules that will implement against these contracts]
     ```
   - Validate: every entity in data-model.md must have an owner module assigned
   - Validate: every contract in contracts/ must specify which modules are producer vs consumer
   - ERROR if any contract has no assigned owner: "CADRE I-02 violation: contract without explicit owner"

6. **Assessment Gate trigger** (I-01, I-10):
   - After plan completion, output: `⚠️ CADRE GATE: Plan complete. Assessment Gate REQUIRED before task decomposition.`
   - Recommend: `/cadre.readiness` to run readiness, completeness, contradiction, drift checks
   - Do NOT proceed to `/cadre.tasks` until assessment passes

7. **Stop and report**: Command ends after planning. Report branch, IMPL_PLAN path, generated artifacts, and contract freeze status.

8. **Check for extension hooks**: After reporting, check if `.cadre/extensions.yml` exists in the project root.
   - If it exists, read it and look for entries under the `hooks.after_plan` key
   - If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
   - Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
   - For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
     - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
     - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
   - For each executable hook, output the following based on its `optional` flag:
     - **Optional hook** (`optional: true`):
       ```
       ## Extension Hooks

       **Optional Hook**: {extension}
       Command: `/{command}`
       Description: {description}

       Prompt: {prompt}
       To execute: `/{command}`
       ```
     - **Mandatory hook** (`optional: false`):
       ```
       ## Extension Hooks

       **Automatic Hook**: {extension}
       Executing: `/{command}`
       EXECUTE_COMMAND: {command}
       ```
   - If no hooks are registered or `.cadre/extensions.yml` does not exist, skip silently

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:

   ```text
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Define interface contracts** (if project has external interfaces) → `/contracts/`:
   - Identify what interfaces the project exposes to users or other systems
   - Document the contract format appropriate for the project type
   - Examples: public APIs for libraries, command schemas for CLI tools, endpoints for web services, grammars for parsers, UI contracts for applications
   - Skip if project is purely internal (build scripts, one-off tools, etc.)

3. **Agent context update**:
   - Run `{AGENT_SCRIPT}`
   - These scripts detect which AI agent is in use
   - Update the appropriate agent-specific context file
   - Add only new technology from current plan
   - Preserve manual additions between markers

4. **Generate `sprint-config.md`** (Module Agent expertise declaration):
   - Use `templates/sprint-config-template.md` as base
   - For each module identified in plan.md: create a `### @[module]-agent` section
   - Fill expertise from tech stack decisions made in this plan
   - Fill "Does NOT know about" from module boundaries
   - Fill Inta Expertise Context (producer/consumer map, test paths)
   - Mark all three artifacts as frozen (data-model.md, contracts/, sprint-config.md)
   - This file is read by module agents at spawn time — must be precise and complete

**Output**: data-model.md, /contracts/*, quickstart.md, sprint-config.md, agent-specific file

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
