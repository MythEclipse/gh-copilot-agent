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
| repository manifest | none found | repository root | none | none | none | context7: not applicable | blocked | No package manifest present; dependency preflight cannot complete until a manifest is added or repo content is confirmed as workflow-only. |

## Conflict Log

| Dependency | Conflict Found In | Severity | Decision | Owner | Date |
| --- | --- | --- | --- | --- | --- |
| None | - | - | - | - | - |
