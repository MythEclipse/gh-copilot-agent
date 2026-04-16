# TODO

Single source of truth for task queue.

## Rules

- Keep tasks atomic: one scope, one measurable acceptance criterion.
- Keep dependency references explicit (`depends_on`).
- Status values: `TODO`, `IN PROGRESS`, `BLOCKED`, `DONE`, `FAIL`.

## Task Queue

| Task | Description | Acceptance Criterion | Depends On | Status |
| --- | --- | --- | --- | --- |
| Task 1 | Replace with first task | Replace with measurable check | None | TODO |
