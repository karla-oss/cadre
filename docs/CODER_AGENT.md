# Coder Agent — CADRE Implementation

## Why coder?

| Metric | Generic Subagent | coder |
|--------|-----------------|-------|
| Tokens/task | 100k-500k | 1k-10k |
| Cost | $0.10-0.50 | $0.001-0.01 |
| Speed | 5-15 min | 12s-2 min |

**Reduction: 50-500x cheaper!**

## How to spawn

```python
sessions_spawn(
    task="Add skeleton loading to ProjectList.tsx",
    agentId="coder",  # ← USE THIS
    runtime="subagent"
)
```

**NOT:** `runtime="subagent"` alone (generic, expensive)

## coder vs generic

- **coder**: Has qdrant semantic retrieval, minimal context, low tokens
- **generic subagent**: Reads everything, no retrieval, high tokens

## When to use

| Task Type | Agent |
|-----------|-------|
| Implementation (coding) | **coder** |
| Planning/Puma tasks | generic (puma) |
| Review (Archi) | generic |
| Infrastructure | coder or generic |

## Token tracking

```
coder tasks: ~1-10k tokens
generic tasks: ~100-500k tokens
```

## Setup check

coder workspace: `/workspace/empty_workspace/`

If SOUL.md missing, copy from `/workspace/`:
```bash
cp /workspace/SOUL.md /workspace/empty_workspace/
cp /workspace/AGENTS.md /workspace/empty_workspace/
cp /workspace/USER.md /workspace/empty_workspace/
cp /workspace/MEMORY.md /workspace/empty_workspace/
```
