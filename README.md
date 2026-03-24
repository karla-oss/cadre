# CADRE — Contract-Driven Agent Delivery & Review Framework

Supervised multi-agent software delivery framework with contract-first governance.

## Status

Draft v1 — extracting executable patterns from spec-kit, filling CADRE structure.

## Repo Structure

```
cadre/
├── framework/              # Framework specification (the "what")
│   ├── invariants/         # Core invariants (I-01 through I-12)
│   ├── roles/              # Role definitions and authority model
│   ├── artifacts/          # Artifact specifications
│   ├── workflow/           # Workflow phases and transitions
│   └── assessments/        # Assessment dimensions and gates
│
├── commands/               # Agent-executable prompts (the "how")
│   └── *.md                # One file per workflow phase — LLM instructions
│
├── templates/              # Constraint templates for artifacts
│   ├── specs/              # System Specification templates
│   ├── plans/              # Plan / Contract Freeze templates
│   ├── tasks/              # Task decomposition templates
│   ├── contracts/          # API / Data contract templates
│   └── reports/            # Assessment / Readiness report templates
│
├── scripts/                # Prerequisite checks, hard gates
│
├── hooks/                  # Extension hooks for assessment gates
│
├── examples/               # Project mapping examples
│
└── COMPARISON.md           # CADRE ↔ spec-kit entity mapping
```

## Design Principle

CADRE defines governance (invariants, roles, workflow).
Commands + templates + scripts make governance **executable by AI agents**.

Framework tells agents WHAT must happen.
Commands tell agents HOW to do it.
Templates constrain WHAT agents produce.
Scripts enforce WHEN phases can transition.
Hooks insert assessment gates WHERE needed.

## Origin

CADRE framework spec: [Notion](https://www.notion.so/CADRE-v1-32b372dc2ae780ffa0ebe8362bfdc1bd)
spec-kit patterns: [GitHub](https://github.com/github/spec-kit)
Mapping: see COMPARISON.md
