# CADRE Agent Metrics
Tracks quality and efficiency per sprint/phase. Used to measure improvement over time.

## Metrics Legend

| Metric | Description |
|--------|-------------|
| tasks_total | Total tasks in batch |
| tokens_per_task_avg | Average tokens consumed per task (in+out) |
| needs_work_rate | % tasks rejected on first review |
| c3_failures | % tasks with unchecked self-check boxes |
| c2_failures | % tasks with wrong "Files changed" |
| c1_deviations | Contract/spec deviations found by Archi |
| archi_iterations | How many review rounds needed |
| context_size_avg | Average lines of context given to agent |

---

## S1 Input Ingestion

### Phase 1 Setup — Batch approach
- tasks_total: 9
- approach: batch (3-4 tasks per agent)
- needs_work_rate: 0% (scaffolding, lenient)
- c3_failures: 100% (all unchecked)
- c2_failures: 30% (some wrong files)
- c1_deviations: 0
- archi_iterations: 1 (approved despite C3 per OBS-005)
- notes: Phase 1 lenient, C3 not enforced per OBS-005

### Phase 2 Contract Tests — Batch approach
- tasks_total: 7
- approach: 1 agent per module (3-4 tasks each)
- needs_work_rate: 57% (4/7 rejected first pass)
- c3_failures: 100%
- c2_failures: 100% (wrong files across all tasks)
- c1_deviations: 1 (INC-002: @frontend api.ts implemented in Phase 2)
- archi_iterations: 2
- context_size_avg: ~200 lines (full tasks.md + contract)

### Phase 3-6 — Batch approach
- tasks_total: 49
- approach: batch (5-10 tasks per agent)
- needs_work_rate: 65% avg
- c3_failures: ~95%
- c2_failures: ~90%
- c1_deviations: 3 (frequency field, empty list validation, commit bundling)
- archi_iterations: 2-3 per batch
- context_size_avg: ~250 lines

---

## S2 Analysis Pipeline

### Phase 1-2 — Mixed approach
- tasks_total: 8
- approach: 1 task per agent (T001/T002/T003/T004 parallel; T005/T006/T007/T008 parallel)
- needs_work_rate: 25% (2/8)
- c3_failures: 50% (improving)
- c2_failures: 25%
- c1_deviations: 0
- archi_iterations: 1-2

### Phase 3 — Parallel same-type agents (T010/T011/T012, T021/T022/T023)
- tasks_total: 6 (3+3)
- approach: 3 parallel instances of same agent type
- needs_work_rate: 33% (2/6 — T021 contract deviation, T023 stub)
- c3_failures: 0% (when pre-created review-request files used)
- c2_failures: 0%
- c1_deviations: 2 (output_schema param, anthropic stub)
- archi_iterations: 2
- notes: No merge conflict confirmed (OBS-002a). Archi caught cross-task port mismatch.

### Phase 3 US1 bulk — Batch approach (regression)
- tasks_total: 18
- approach: batch (6-7 tasks per agent)
- needs_work_rate: 100% (13/13 first pass rejected)
- c3_failures: 100%
- c2_failures: 100% (all files from all modules in every task)
- c1_deviations: 4 (frequency field, min_length, empty list tests, contract signature)
- archi_iterations: 3
- context_size_avg: ~300 lines
- notes: Clear degradation vs single-task approach. OBS-010 confirmed.

---



## Target Metrics (1 task per agent with ticket files)

| Metric | Current (batch) | Target (ticket) |
|--------|----------------|-----------------|
| needs_work_rate | 65-100% | <20% |
| c3_failures | 90-100% | 0% (review-submit.sh enforces) |
| c2_failures | 80-100% | <10% |
| c1_deviations | 2-4 per batch | <1 per sprint |
| archi_iterations | 2-3 | 1 |
| context_size_avg | 200-300 lines | <60 lines |
| tokens_per_task_avg | 15-25k (batch) | 2-4k |

---

## Telemetry Roadmap

### For Next Project: Collect Full Telemetry from Day 1

**What to measure per agent run:**
- `started_at`, `ended_at`, `duration_ms`
- `tokens_in`, `tokens_out`, `tokens_cache`
- `task_id`, `agent_type`, `phase`, `sprint`
- `approach` — ticket | batch
- `context_lines` — how many lines given to agent
- `result` — approved | needs_work | rejected
- `c1_deviations`, `c2_violations`, `c3_failures`
- `archi_iterations` — how many review rounds

**What to track over time:**
- Drift rate per sprint (D4 findings over time → detects project decay)
- Correctness rate per agent type (which agents drift most?)
- Cost per task (tokens × price) → ROI metric
- Time from task start to approved commit
- Phase efficiency (which phases consume most tokens?)

**How to implement:**
- `spawn-agent.sh` logs start event to `telemetry/runs.jsonl`
- `review-approve.sh` / `review-reject.sh` log outcome event
- `metrics-log.sh` aggregates per batch
- Weekly: `analytics.sh` reads runs.jsonl → generates report

**Format: `telemetry/runs.jsonl`**
```json
{"ts":"2026-03-24T08:00:00Z","task":"T033","agent":"api-agent","phase":"P8","sprint":"S2","approach":"ticket","tokens_in":1200,"tokens_out":800,"duration_ms":45000,"result":"approved","c1":0,"c2":0,"c3":0,"archi_iter":1}
```

**Key insight to watch:**
- If `c1_deviations` grows over sprints → agents drifting from contracts (architectural decay)
- If `tokens_per_task` grows → context bloat, need trimming
- If `archi_iterations` > 1 consistently → prompts need improvement
- If `drift_rate` in readiness gate grows → spec/plan quality degrading
