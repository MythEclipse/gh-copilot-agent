# Dependency Version Map

Single source for dependency version visibility across project.
Update in Orchestrator Phase 1 before any implementation dispatch.

## Status Rules

- `locked`: exact version pinned from lockfile/manifests.
- `floating`: range/alias used; risk of drift.
- `unknown`: version not resolved yet. Workflow must block until resolved or risk-accepted.
- `vulnerable`: known advisory exists and mitigation is pending.

## Dependency Table

| Name | Resolved Version | Source of Truth | Constraint Source | Security Source | Security Status | MCP Verification | Status | Notes/Risk |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TBD | TBD | TBD | TBD | TBD | unknown | context7: pending, firecrawl: pending | unknown | Fill during discovery |

## Conflict Log

| Dependency | Conflict Found In | Severity | Decision | Owner | Date |
| --- | --- | --- | --- | --- | --- |
| None | - | - | - | - | - |
