# Agent Handoff Protocol

This document is the canonical specification for inter-agent communication in this workflow. Every agent **must** conform to the input and output formats defined here. Ambiguity in handoff messages is a protocol violation.

---

## Guiding Principles

1. **Explicit over implicit.** Every handoff must include all context the receiving agent needs to operate without asking clarifying questions. If the receiving agent needs to ask, the sending agent's output was incomplete.
2. **Verbatim over summarized.** Error outputs, stack traces, and audit results are passed verbatim — never paraphrased. A paraphrase introduces information loss and misdiagnosis risk.
3. **Structured over prose.** All handoffs use the structured formats defined below. Free-form prose is not a valid handoff format.
4. **Single source of truth.** `docs/todo.md` is the only authoritative task list. Handoff messages reference task entries by number; they do not redefine tasks inline.

---

## Handoff Specifications

### 1. Orchestrator → Planner

**Trigger:** `docs/todo.md` is missing, stale, or the objective has changed.

**Payload:**
```
## Planner Dispatch

Objective: <full project objective, unambiguous>

Constraints:
- <technical constraints — stack, framework, language, deployment target>
- <scope constraints — what is explicitly out of scope>
- <known dependencies — external services, APIs, existing modules>

Existing codebase context:
- Root path: <project root>
- Key modules: <list of relevant directories/files>

Current docs/todo.md status: MISSING | STALE (reason: <why stale>)
```

**Expected return:** Updated `docs/todo.md` + brief ambiguity report.

---

### 2. Planner → Architect

**Trigger:** Plan is ready and has passed Planner's self-validation checklist.

**Payload:**
```
## Architect Dispatch

Objective: <same as Planner received>

docs/todo.md: <full content of docs/todo.md>

Codebase snapshot:
- Architecture pattern: <layered | hexagonal | feature-based | monolithic | other>
- Key existing interfaces/contracts: <file paths>
- Existing ADRs: <docs/adr/ contents or "None">
- Tech stack: <language, framework, runtime, DB, external services>

Review requested: Plan Evaluation + Contract Definition + Parallelism Map
```

**Expected return:** Plan Evaluation table + Contracts Defined + Data Flow Maps + ADRs written + Parallelism Map + `STATUS: APPROVED | REQUIRES_REVISION`.

---

### 3. Architect → Orchestrator (approval or revision)

**On APPROVED:**
```
## Architect Verdict: APPROVED

Parallelism Map:
  Sequential: Task N → Task M → ...
  Parallelizable: Task A ‖ Task B (rationale: <no shared boundary>)

Contracts ready: <list of contract specs by task number>
Data flow maps ready: <list by task number>
ADRs written: <docs/adr/NNN-slug.md list or "None">
```

**On REQUIRES_REVISION:**
```
## Architect Verdict: REQUIRES_REVISION

Plan Defects:
1. <Task N>: <specific defect> → Required correction: <exact fix>
2. ...

Do not dispatch Coder until Planner resolves all defects above.
```

---

### 4. Figma → Orchestrator (for UI tasks only)

**Trigger:** Orchestrator identifies a task as UI/design-related.

**Payload to Figma:**
```
## Figma Dispatch

Source: <Figma link or node ID>
Task: <task number and description>
Target implementation files: <file paths>
```

**Expected return from Figma:** Full output per Figma agent Output Format section — Discrepancy Report + Token Manifest + Recommended Actions. These are incorporated into the task's acceptance criteria before Coder dispatch.

---

### 5. Orchestrator → Coder

**Trigger:** Task is unblocked, Architect has approved, Figma resolved (if applicable).

**Payload:**
```
## Coder Dispatch

Task: Task <N> — <task description>
Target file(s): <exact file paths>
Acceptance criterion: <measurable, testable statement>

Architect contract:
<paste contract spec for this task exactly>

Data flow map:
<paste data flow map for this task exactly>

ADR references:
<list of relevant ADR file paths or "None">

Context from prior tasks:
<any types, interfaces, or modules created in Tasks N-1, N-2 that this task depends on>

Constraints:
- Implement only this task. Do not touch out-of-scope files.
- All public API members must have JSDoc/TSDoc documentation comments.
- Zero stubs, no suppression annotations, no code truncation.
```

**Expected return:** Full Coder output per Coder Output Format section.

---

### 6. Coder → Auditor

**Trigger:** Coder has completed implementation.

**Payload:** Coder's verbatim output — forwarded without modification. Orchestrator must not filter, summarize, or add to it.

```
## Auditor Dispatch

Original task: Task <N> — <task description>
Acceptance criterion: <same as sent to Coder>
Architect contract: <same contract spec>

Coder output:
<verbatim paste of Coder's full response>
```

**Expected return:** Full Auditor output per Auditor Output Format section.

---

### 7. Auditor → Tester (on PASS)

**Trigger:** Auditor returns `PASS` verdict.

**Payload:**
```
## Tester Dispatch

Task: Task <N> — <task description>
Acceptance criterion: <measurable criterion>

Implementation files:
<list of all modified file paths with line ranges>

Coder's test output (if any tests were run by Coder):
<verbatim — copied from Coder's output>

Auditor verdict: PASS
Auditor notes on test adequacy:
<any notes from Auditor Section 6 on test coverage gaps>
```

**Expected return:** Full Tester output per Tester Output Format section.

---

### 8. Tester → Debugger (on FAIL)

**Trigger:** Tester returns `STATUS: FAIL`.

**Payload:** Tester's verbatim FAIL report — forwarded without modification.

```
## Debugger Dispatch

Task: Task <N> — <task description>
Acceptance criterion: <criterion>
Implementation files: <file paths>

Tester output:
<verbatim paste of Tester's full FAIL response>
```

**Expected return:** Full Debugger output per Debugger Output Format section — root cause + Fix Specification + routing decision.

---

### 9. Debugger → Coder (on IMPLEMENTATION_DEFECT)

**Trigger:** Debugger returns `Route fix to: CODER`.

**Payload:**
```
## Coder Re-Dispatch (Fix Cycle)

Task: Task <N> — <task description>
Cycle: Fix attempt <N> of 2 (if this is attempt 2, Orchestrator will escalate after this)

Debugger Fix Specification:
<verbatim paste of Debugger's Fix Specification section>

Constraint: Implement only the changes specified in the Fix Specification above.
Do not modify tests. Do not modify out-of-scope files.
After implementing, re-run tests and report results.
```

After Coder re-implements, the flow re-enters **Auditor** (not Tester directly). Auditor reviews the fix first.

---

### 10. Tester PASS → DevOps

**Trigger:** Tester returns `STATUS: PASS` for all tasks in the current cycle.

**Payload:**
```
## DevOps Dispatch

Cycle summary:
- Tasks completed this cycle: Task <A>, Task <B>, Task <C>
- Total files modified: <list>

Version intent: MAJOR | MINOR | PATCH | UNKNOWN (Orchestrator assessment — DevOps validates)

Changeset rationale:
- Task A: <brief behavioral description>
- Task B: <brief behavioral description>
- Task C: <brief behavioral description>

Project root: <path>
```

**Expected return:** Full DevOps output per DevOps Output Format section.

---

### 11. DevOps → Orchestrator → Mark DONE

**Trigger:** DevOps returns `STATUS: PASS`.

**Action:** Orchestrator marks all tasks in the cycle as `DONE` in `docs/todo.md`, records the version number and changelog entry reference, and unlocks dependent tasks.

---

## Protocol Violation Handling

If any agent receives a handoff that does not conform to the specification above:

1. **Do not proceed.** Attempting to work from malformed input produces garbage output downstream.
2. **Return a PROTOCOL_VIOLATION response** immediately:
   ```
   ## Protocol Violation
   Expected: <format name from this document>
   Missing: <list of missing fields>
   Cannot proceed until: <exact fields required>
   ```
3. Orchestrator re-sends the correct payload.

---

## Message Integrity Rules

- **Never paraphrase** error messages, stack traces, or test output. Pass verbatim.
- **Never truncate** long outputs with "..." or "[...abbreviated...]". Pass the complete text.
- **Never merge** two agent outputs into one handoff message. Each handoff is from one specific agent.
- **Always include** the Task number and acceptance criterion in every handoff. Agents must never be asked to infer what task they are working on.
- **Always include** the Architect contract when dispatching Coder, even on fix cycles.
