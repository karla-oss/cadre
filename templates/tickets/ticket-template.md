# {TASK_ID}: {TITLE}

**Epic**: {EPIC_BRANCH}
**Owner**: @{agent-name}
**Phase**: {phase}
**File**: {exact/file/path.py}
**Status**: todo | in-progress | ready-for-review | done

## What to do

[10-20 lines max. Specific, actionable. No background, no context.]

## Contract snippet

[Only the relevant part — one endpoint, one schema, one entity. Max 30 lines. Copy-paste from frozen contract.]

## Acceptance Criteria

- [ ] AC1: [testable condition]
- [ ] AC2: [testable condition]
- [ ] AC3: [testable condition]

## After task complete

1. Mark [X] in tasks.md
2. Run: `bash scripts/bash/review-request.sh {TASK_ID} "description"`
3. Fill self-check in review-request/{TASK_ID}.md
4. Run: `bash scripts/bash/review-submit.sh {TASK_ID}`
