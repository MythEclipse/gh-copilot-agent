# TODO

Single source of truth for task queue.

## Rules

- Keep tasks atomic: one scope, one measurable acceptance criterion.
- Keep dependency references explicit (`depends_on`).
- Status values: `TODO`, `IN PROGRESS`, `BLOCKED`, `DONE`, `FAIL`.

## Task Queue

| Task | Description | Acceptance Criterion | Depends On | Status |
| --- | --- | --- | --- | --- |
| Task 1 | Bootstrap agent workflow artifacts | `docs/todo.md` exists with atomic tasks; `docs/workflow-state.json` lists the same tasks with valid transitions; `docs/dependency-map.md` documents manifest status; `docs/quality-gates.json` contains task metadata. | None | DONE |
| Task 2 | Create missing `Tester.agent.md` | `Tester.agent.md` exists and matches the project handoff protocol; it defines tester role, constraints, and verdict flow. | Task 1 | DONE |
| Task 3 | Analyze and improve existing agent definitions | `Auditor.agent.md`, `Coder.agent.md`, `Orchestrator.agent.md`, and `Planner.agent.md` are reviewed; any improvements are documented and implemented in the agent files. | Task 1 | TODO |
