---
description: "CADRE Refactor Pass — scans for files exceeding micro-module limit, generates refactor tickets, executes splits with shim pattern."
cadre:
  phase: P9b-refactor
  invariants: [I-03, I-04]
  role: archi
  triggers_after: [validate, epic-close]
  artifacts_produced: [refactor-report.md, tickets/REFACTOR-T*.md]
---

## Purpose

Runs between Epics to prevent codebase viscosity. Finds files that have grown beyond the micro-module limit and splits them into focused modules.

**When to run**: After `/cadre.validate` passes, before next Epic's `/cadre.specify`.

## Outline

1. **Scan for violations**:
   ```bash
   find . -name "*.py" -o -name "*.ts" -o -name "*.tsx" | \
     grep -v "test_\|.test.\|spec.\|node_modules\|__pycache__\|shim" | \
     xargs wc -l 2>/dev/null | awk '$1 > 150' | sort -rn
   ```

2. **For each violation**, analyze responsibility boundaries:
   - Read the file
   - Identify natural function groups
   - Propose split: which functions go to which new file
   - Each new file should be ≤ 100 lines

3. **Generate refactor tickets** in `specs/{epic}/tickets/`:
   - One ticket per file to split
   - Ticket contains: current file, proposed split, shim pattern
   - Owner: @refactor-agent (or the module's owning agent)

4. **Execute splits** (Archi can do directly for small files, or spawn @refactor-agent):
   - Create new micro-module files
   - Create shim in original location
   - Verify imports work: `python -c "import module"` or `tsc --noEmit`

5. **Write `refactor-report.md`**:
   - Files scanned
   - Violations found
   - Splits applied
   - Before/after line counts
   - Token savings estimate: `(old_lines - new_max_lines) / old_lines * 100%`

## Shim Pattern

```python
# original_file.py — backward compat shim
# This file preserved for import compatibility
from original_file.create import create_thing  # noqa
from original_file.list import list_things  # noqa
```

## Rules

- NEVER change logic — pure structural moves only
- ALWAYS create shim — never break existing imports
- Tests should NOT need updating (they import via shims)
- One commit per file split (NOTE-001)
