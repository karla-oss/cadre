# Agent Spawn Decisions Log

## 2026-03-25 — Agent Spawn Discussion

### Dimension 1: Tasked vs Un-tasked Launch

**Decision:**
- **Tasked agent** — запускается с конкретным заданием (bounded work, finite scope)
- **Un-tasked agent** — запускается без задания, идёт в таск-систему, получает таски оттуда

### Un-tasked Agent Lifecycle

```
Launch → Get tasks from system → If empty: terminate (sleep) → If tasks: prioritize → pick one → Execute → Done → repeat or terminate
```

**Decisions:**
1. Если тасков нет → terminate (самый быстрый путь)
2. Agent авторизуется в таск-системе через Notion API / Jira credentials
3. Agent self-prioritizes: P0 first, then by age/size

---

## Decisions Made

### Preconditions
- Agent НЕ проверяет readiness сам
- Если в task preconditions не выполнены → комментарий на таск + Blocked статус
- Task уже должен содержать все что нужно для исполнения

### Loop vs One-shot
- Agent может продолжать работать над тасками
- При взятии таска → статус "In Progress" (лок чтобы параллельный инстанс не взял тот же таск)
- Только таски в статусе TODO могут быть взяты

### Priority
- Приоритет из Jira (уже определён в таске)
- Если приоритета нет → от простого/быстрого к сложному

### State Persistence
- Jira = state системы
- Никакого отдельного state для агента не нужно
- Некоторые агенты имеют доступ к Notion

## Decisions Made (continued)

### Who Triggers Standing Agent?

**Triggers:**
- Другой агент (Puma → Archi, Archi → Module agents и т.д.)
- Hooks: создание таска, снятие блока, и т.п.
- P → P transition (переход к стадии где таски готовы)
- System limit на количество одновременно запущенных агентов одного типа

**Constraint:**
> Агент может тригернуть другого агента ТОЛЬКО в NO-TASK режиме.

**Пример:** Puma создал приоритетный тикет, триггернул исполнителя, исполнитель сам нашёл таск.

### Agent as Orchestrator vs Executor

**Decision (2026-03-25):**
- Agent НЕ может создавать саб-агента самого себя
- Agent может только выполнять свои задания
- Вопрос о self-spawn отложен на будущее

## Open Questions

1. ~~Agent как orchestrator vs executor~~ — CLOSED: Agent only executes own tasks
2. ~~Who triggers standing agent?~~ — CLOSED: Multiple triggers defined

---

## Implementation (2026-03-25)

### Task Scripts Created

```
scripts/bash/
├── task-get-todos.sh    # Get TODO tasks for agent type, sorted by priority
├── task-claim.sh        # Atomically claim task (TODO → IN_PROGRESS)
├── task-complete.sh      # Mark as READY_FOR_REVIEW (IN_PROGRESS → READY_FOR_REVIEW)
├── task-block.sh         # Mark as BLOCKED with reason comment
└── spawn-agent.sh        # Existing: generate agent prompt from ticket
```

### Task File Format
```markdown
**Status**: TODO / IN_PROGRESS / READY_FOR_REVIEW / BLOCKED / DONE
**Owner**: @api-agent
**Priority**: P0 / P1 / P2 / P3
```

### Correct Agent Workflow (READ before CLAIM)

```
1. Get TODO tasks
2. If empty → terminate
3. Pick first task
4. READ task file (understand what needs to be done)
5. Claim it (mark IN_PROGRESS)
   - If claim fails (race) → pick next task
6. Execute work (based on what you read)
7. Mark ready for review
8. Go back to step 1
```

### Race Condition Handling
- Two agents try to claim same task
- First one: sed succeeds → claimed
- Second one: sed doesn't find "TODO" anymore → fails, takes next task
- Simple but works for 2-3 agents

## Related Files

- `scripts/bash/spawn-agent.sh` — существующий фундамент для tasked agent
- `scripts/bash/task-*.sh` — new task system scripts
- OBS-010: ticket-per-agent context model

---

_Logged by Zazza during discussion with Torres_
