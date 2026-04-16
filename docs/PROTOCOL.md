# Agent System Protocol

Canonical spec for all agents in this workflow. This doc is single source of truth.
Global canonical path: `~/.copilot/agents/docs/PROTOCOL.md`.
Project path `docs/PROTOCOL.md` is optional overlay only.

---

## § Caveman Mode

All agents run caveman mode by default (full intensity).
Respond terse, high signal, no fluff.

### Rules

- Drop filler, pleasantries, hedging.
- Keep technical terms exact.
- Keep code blocks unchanged.
- Quote errors exactly.

Pattern: `[thing] [action] [reason]. [next step].`

### Persistence

- Active every response.
- Off only: `stop caveman` or `normal mode`.
- Switch: `/caveman lite|full|ultra`.

### Auto-Clarity

Temporarily use normal style for security warnings, irreversible actions, and complex step ordering.

---

## § Universal Hard Constraints

- **NEVER hide mistakes.** Admit and fix immediately.
- **NEVER flatter.** Facts only.
- **NEVER stall on minor ambiguity.** Make robust technical assumption, document it, proceed.

---

## § Workflow State Machine (V2)

Every task must move through fixed states:

`DISCOVERED -> SPEC_READY -> CODED -> AUDIT_PASS -> TEST_PASS -> RELEASE_READY -> DONE`

### Transition Gates

1. `DISCOVERED -> SPEC_READY`
   - Docs sweep complete.
   - Dependency map current.
   - Risk score computed.
   - Task lock valid: one scope, one measurable acceptance criterion.
2. `SPEC_READY -> CODED`
   - Coder handoff envelope valid.
   - Contract + flow + ADR refs attached.
3. `CODED -> AUDIT_PASS`
   - Auditor verdict `PASS`.
4. `AUDIT_PASS -> TEST_PASS`
   - Tester verdict `STATUS: PASS`.
5. `TEST_PASS -> RELEASE_READY`
   - Quality Gate score `>= 85/100`.
   - Dependency security check complete.
6. `RELEASE_READY -> DONE`
   - DevOps verdict `STATUS: PASS`.
   - Version + changelog evidence recorded.

### State Blockers (Hard Stop)

- Dependency version status `unknown`.
- Cross-file dependency version conflict unresolved.
- Protocol violation in handoff envelope.
- Auditor `FAIL` or Tester `FAIL` unresolved.
- Quality Gate score `< 85`.

---

## § Zero-Setup Auto Bootstrap

Goal: no manual setup per project.

On first run in any repository, Orchestrator must auto-initialize required workflow artifacts before normal planning flow.

### Required Behavior

1. Ensure `docs/` directory exists.
2. Create missing files only (never overwrite existing content):
   - `docs/todo.md`
   - `docs/dependency-map.md`
   - `docs/workflow-state.json`
   - `docs/quality-gates.json`
   - `docs/handoff-log.jsonl`
   - `docs/observability.md`
3. Prefer global templates from `~/.copilot/agents/docs/*.template.*`.
4. If repository-local templates exist, allow them as overrides.
5. If templates are missing, generate minimal protocol-compliant defaults inline.
6. Append bootstrap metadata to `docs/handoff-log.jsonl`.

### Global vs Project Protocol Resolution

1. Always apply global canonical protocol from `~/.copilot/agents/docs/PROTOCOL.md`.
2. If target repo contains `docs/PROTOCOL.md`, treat as overlay.
3. On conflict, stricter rule wins.
4. If overlay weakens mandatory safety/quality gates, ignore weakening and keep global rule.

### Failure Policy

- If repository is read-only or writes fail, set workflow state to `BLOCKED` with explicit reason.
- Never ask user to do routine bootstrap manually unless write access is impossible.

---

## § Documentation-First Dependency Mapping

Mandatory before coding/audit/testing/release.

### Required Preflight

1. Read `README*`, `docs/**/*.md`, ADRs, runbooks, and manifest-adjacent docs.
2. Build/refresh `docs/dependency-map.md`.
3. Confirm versions from source-of-truth files (lockfiles/manifests).
4. Cross-check constraints against official docs.
5. Set status per dependency: `locked` | `floating` | `unknown`.
6. Any `unknown`/conflict blocks workflow until resolved or explicit risk acceptance.

### Dependency Map Minimum Schema

- Name
- Resolved Version
- Source of Truth (`package-lock.json`, `poetry.lock`, `go.sum`, etc.)
- Constraint Source (official doc URL/ref)
- Security Source (`OSV`/`CVE` ref) when available
- Status (`locked` | `floating` | `unknown`)
- Notes/Risk

---

## § MCP Tool Priority (No-Limit Path)

When available and not rate-limited, use this order:

1. `context-mode`: local discovery, indexing, code reasoning, large output processing.
2. `context7`: official API docs, version compatibility, migration guidance.
3. `firecrawl`: authoritative external docs/changelogs not covered by `context7`.
4. Security feeds via MCP if available (`OSV`/`CVE`) for dependency risk validation.
5. SCM MCP integration if available (PR/issue/release status sync).

### Fallback Policy

- Fallback allowed only if tool unavailable/limited.
- Record fallback event as `TOOL_LIMIT_FALLBACK` with:
  - tool
  - reason
  - impact
  - mitigation
- If current agent lacks `context7`/`firecrawl`, escalate doc/dependency verification to Orchestrator.
- Using non-MCP path while MCP path available is protocol violation.

---

## § Risk Scoring and Depth Policy

Each task gets risk score `0..100`:

- Security impact: `0..30`
- Data integrity impact: `0..25`
- Concurrency/state complexity: `0..20`
- Blast radius (modules/APIs touched): `0..15`
- Dependency volatility: `0..10`

### Required Depth by Score

- `0..34` Low: standard audit + unit tests.
- `35..69` Medium: full checklist audit + unit + integration + edge tests.
- `70..100` High: full checklist audit + negative tests + regression suite + manual scenario trace.

---

## § Quality Gate (Definition of Done)

Task/cycle can progress to `RELEASE_READY` only if total score `>= 85/100`:

- Acceptance criteria completeness: `20`
- Scope compliance: `15`
- Audit quality: `20`
- Test adequacy and determinism: `20`
- Security and dependency hygiene: `15`
- Documentation integrity (ADR/changelog/notes): `10`

Any category scored `0` blocks release regardless of total.

---

## § Handoff Protocol

Inter-agent messages must be structured and verifiable.

### Handoff Envelope (Mandatory)

Every handoff must include this envelope:

```yaml
handoff_id: <uuid>
protocol_version: "2.0"
timestamp_utc: <ISO-8601 UTC>
from_agent: <agent>
to_agent: <agent>
task_ref: "Task <N>"
state_before: <state>
state_after_intent: <state>
checksum_sha256: <sha256 of canonical payload>
payload: <structured body>
```

If envelope field missing/invalid -> `PROTOCOL_VIOLATION`.

### Guiding Principles

1. Explicit over implicit.
2. Verbatim over summarized for logs/errors/traces.
3. Structured over prose.
4. `docs/todo.md` is single task source of truth.

---

### Handoff 1 - Orchestrator -> Figma (UI only)

Trigger: UI task and user provided Figma channel/code.

Payload must include:

- source
- task
- target_files
- acceptance_criteria

Return: Discrepancy report + token manifest + recommended actions.

---

### Handoff 2 - Orchestrator -> Coder

Trigger: task is `SPEC_READY`.

Payload must include:

- task and exact acceptance criterion
- target files
- orchestrator contract (exact)
- data flow map (exact)
- ADR refs
- prior-task dependency context
- constraints (no out-of-scope edits, no stubs/suppressions/truncation)
- risk score + required test depth

---

### Handoff 3 - Coder -> Auditor

Trigger: implementation complete (`CODED`).

Payload: Coder output verbatim. No filtering. No summary.

---

### Handoff 4 - Auditor -> Tester

Trigger: Auditor verdict `PASS`.

Payload must include:

- task + acceptance criterion
- modified files
- Coder test output (verbatim)
- Auditor coverage notes

---

### Handoff 5 - Tester FAIL -> Coder

Trigger: Tester `STATUS: FAIL` and class `IMPLEMENTATION_DEFECT`.

Payload: Tester FAIL report + fix specification verbatim.

If class `TEST_DEFECT`, route back to Tester (self-correction).

---

### Handoff 6 - Tester PASS -> DevOps

Trigger: all tasks in cycle are `TEST_PASS`.

Payload must include:

- cycle summary
- affected files
- version intent
- behavior deltas per task

---

### Handoff 7 - DevOps PASS -> DONE

Trigger: DevOps `STATUS: PASS`.

Action: mark tasks `DONE`, record version/changelog evidence, unlock dependencies.

---

## § Retry Policy and Error Taxonomy

Standard classes:

- `IMPLEMENTATION_DEFECT`
- `CONTRACT_VIOLATION`
- `UNHANDLED_ERROR_PATH`
- `STATE_CORRUPTION`
- `RACE_CONDITION`
- `INTEGRATION_DEFECT`
- `TEST_DEFECT`
- `ENVIRONMENT_ISSUE`
- `PROTOCOL_VIOLATION`

Retry policy:

- Coder: up to 3 attempts for implementation defects.
- Auditor fail 3x: halt and rerun planning/spec.
- Same class fails 2x in one task: mandatory mini postmortem.
- `PROTOCOL_VIOLATION`: no retry until payload schema fixed.

---

## § Observability and Postmortem

Track per cycle:

- lead time per state
- retries per error class
- audit pass rate
- test pass rate
- fallback events count
- blocked duration

Maintain:

- `docs/workflow-state.json` (current states + timestamps)
- `docs/quality-gates.json` (scores and rationale)
- `docs/handoff-log.jsonl` (envelope metadata)
- `docs/observability.md` (human summary)

Mini postmortem required when same error class repeats 2x+:

- timeline
- root cause
- corrective action
- prevention rule update

---

## § Protocol Violation Handling

If handoff invalid:

1. Do not proceed.
2. Return:

   ```
   ## Protocol Violation
   Expected: <format>
   Missing: <fields>
   Cannot proceed until: <required fields>
   ```

3. Orchestrator re-sends valid payload.

---

## § Message Integrity Rules

- Never paraphrase error/test/trace outputs.
- Never truncate required evidence.
- Never merge outputs from multiple agents into single handoff body.
- Always include task ref and acceptance criterion in handoff payload.
- Always include Orchestrator contract in Coder dispatch and re-dispatch.
