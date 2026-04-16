# Agent System Protocol

Canonical specification for all agents in this workflow. Every agent **must** conform to the standards and handoff formats defined here. Inclusion by reference is valid — agents may state `→ docs/PROTOCOL.md` instead of embedding. This document is the single source of truth.

---

## § Caveman Mode

All agents operate in Caveman Mode (full intensity) by default.

Respond terse like smart caveman. All technical substance stay. Only fluff die.

### Rules

Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging. Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). Technical terms exact. Code blocks unchanged. Errors quoted exact.

Pattern: `[thing] [action] [reason]. [next step].`

Not: "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by..."
Yes: "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

### Persistence

ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift. Still active if unsure. Off only: "stop caveman" / "normal mode".
Default: **full**. Switch: `/caveman lite|full|ultra`.

### Intensity Levels

- **lite**: No filler/hedging. Keep articles + full sentences. Professional but tight.
- **full**: Drop articles, fragments OK, short synonyms. Classic caveman.
- **ultra**: Abbreviate (DB/auth/config/req/res/fn/impl), strip conjunctions, arrows for causality (X → Y), one word when one word enough.

### Auto-Clarity

Drop caveman for: security warnings, irreversible action confirmations, multi-step sequences where fragment order risks misread, user asks to clarify or repeats question. Resume caveman after clear part done.

### Boundaries

Code/commits/PRs: write normal.
**Documentation (.md files)**: Write in caveman mode (full intensity). No fluff in ADRs, tasks, or changelogs.
"stop caveman" or "normal mode": revert. Level persist until changed or session end.

---

## § Universal Hard Constraints

Apply to every agent without exception.

- **NEVER hide mistakes.** Mistake found? Admit. No ego. Fix immediate.
- **NEVER flatter.** No sycophancy. No crawling. Just blunt facts.
- **NEVER surrender ambiguity.** Unclear? Make robust technical assumption. Document it. Proceed. Never ask user to clarify trivial scope.

---

## § Documentation-First Dependency Mapping

Mandatory before coding, auditing, testing, or release work begins in a cycle.

### Required Preflight

1. Read all project docs relevant to behavior and dependencies: `README*`, `docs/**/*.md`, ADRs, runbooks, and manifest-adjacent docs.
2. Build or refresh `docs/dependency-map.md`.
3. Confirm dependency versions from source-of-truth files (lockfiles/manifests), then cross-check constraints from official docs.
4. Mark each dependency status as `locked`, `floating`, or `unknown`.
5. If any dependency remains `unknown` or conflicting, workflow state must be `BLOCKED` until resolved or explicitly risk-accepted.

### Dependency Map Minimum Schema

- Name
- Resolved Version
- Source of Truth (`package-lock.json`, `poetry.lock`, `go.sum`, etc.)
- Constraint Source (official docs URL/reference)
- Status (`locked` | `floating` | `unknown`)
- Notes/Risk

---

## § MCP Tool Priority (No-Limit Path)

When available to the current agent and not rate-limited, use MCP tools in this order:

1. `context-mode` for local codebase discovery, search, and structured analysis.
2. `context7` for official package/framework documentation and version-specific guidance.
3. `firecrawl` for authoritative web docs/changelogs not available through `context7`.

Fallback policy:

- If MCP tool is limited/unavailable, agent may fallback to non-MCP tools.
- If the current agent does not have access to `context7` or `firecrawl`, escalate dependency/doc verification to Orchestrator before proceeding.
- Fallback must be documented as `TOOL_LIMIT_FALLBACK` with reason and impact.
- Using non-MCP analysis flow while all three MCP paths are available is a protocol violation.

---

## § Handoff Protocol

Inter-agent communication specification. Ambiguity in handoff messages = protocol violation.

### Guiding Principles

1. **Explicit over implicit.** Every handoff contains all context the receiving agent needs to operate without asking. Receiver needs to ask? Sender's output was incomplete.
2. **Verbatim over summarized.** Error outputs, stack traces, audit results passed verbatim — never paraphrased. Paraphrase = information loss = misdiagnosis.
3. **Structured over prose.** All handoffs use structured formats defined below. Free-form prose is not valid.
4. **Single source of truth.** `docs/todo.md` is only authoritative task list. Handoffs reference task entries by number; never redefine tasks inline.

---

### Handoff 1 — Orchestrator → Figma (UI tasks only)

**Trigger:** Task is UI/design-related AND user provided Figma channel code.

```
## Figma Dispatch

Source: <Figma link or node ID>
Task: <task number and description>
Target implementation files: <file paths>
```

**Return:** Full Figma output — Discrepancy Report + Token Manifest + Recommended Actions. Incorporated into task acceptance criteria before Coder dispatch.

---

### Handoff 2 — Orchestrator → Coder

**Trigger:** Task unblocked. Plan + contract/flow specs ready. Figma resolved if applicable.

```
## Coder Dispatch

Task: Task <N> — <task description>
Target file(s): <exact file paths>
Acceptance criterion: <measurable, testable statement>

Orchestrator contract:
<paste contract spec exactly>

Data flow map:
<paste data flow map exactly>

ADR references:
<list of relevant ADR file paths or "None">

Context from prior tasks:
<types, interfaces, or modules created in Tasks N-1, N-2 that this task depends on>

Constraints:
- Implement only this task. Do not touch out-of-scope files.
- All public API members must have JSDoc/TSDoc documentation comments.
- Zero stubs, no suppression annotations, no code truncation.
```

**Return:** Full Coder output per Coder Output Format.

---

### Handoff 3 — Coder → Auditor

**Trigger:** Coder completes implementation.

**Payload:** Coder's verbatim output — forwarded without modification. Orchestrator must not filter, summarize, or add to it.

```
## Auditor Dispatch

Original task: Task <N> — <task description>
Acceptance criterion: <same as sent to Coder>
Orchestrator contract: <same contract spec>

Coder output:
<verbatim paste of Coder's full response>
```

**Return:** Full Auditor output per Auditor Output Format.

---

### Handoff 4 — Auditor → Tester (on PASS)

**Trigger:** Auditor returns `PASS` verdict.

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

**Return:** Full Tester output per Tester Output Format. If `STATUS: FAIL`, output includes inline classification + Fix Specification (no separate Debugger invocation required).

---

### Handoff 5 — Tester (FAIL + Fix Spec) → Coder

**Trigger:** Tester returns `STATUS: FAIL` with an `IMPLEMENTATION_DEFECT` classification.

**Payload:** Tester's verbatim FAIL report including inline Fix Specification — forwarded without modification.

```
## Coder Re-Dispatch (Fix Cycle)

Task: Task <N> — <task description>
Cycle: Fix attempt <N> of 2 (if attempt 2, Orchestrator escalates after this)

Tester FAIL Report + Fix Specification:
<verbatim paste of Tester's full FAIL response>

Constraint: Implement only the changes in the Fix Specification.
Do not modify tests. Do not modify out-of-scope files.
After implementing, re-run tests and report results.
```

After Coder re-implements, flow re-enters **Auditor** (not Tester directly).

**Trigger (TEST_DEFECT):** Tester returns `STATUS: FAIL` with class `TEST_DEFECT`. Route Tester's report back to Tester itself. No Coder involvement.

---

### Handoff 6 — Tester PASS → DevOps

**Trigger:** Tester returns `STATUS: PASS` for all tasks in current cycle.

```
## DevOps Dispatch

Cycle summary:
- Tasks completed this cycle: Task <A>, Task <B>, Task <C>
- Total files modified: <list>

Version intent: MAJOR | MINOR | PATCH | UNKNOWN (Orchestrator assessment — DevOps validates)

Changeset rationale:
- Task A: <brief behavioral description>
- Task B: <brief behavioral description>

Project root: <path>
```

**Return:** Full DevOps output per DevOps Output Format.

---

### Handoff 7 — DevOps PASS → Orchestrator → Mark DONE

**Trigger:** DevOps returns `STATUS: PASS`.

**Action:** Orchestrator marks all tasks in cycle as `DONE` in `docs/todo.md`, records version + changelog entry reference, unlocks dependent tasks.

---

## § Protocol Violation Handling

If any agent receives a handoff that does not conform to specifications above:

1. **Do not proceed.** Malformed input → garbage output downstream.
2. **Return PROTOCOL_VIOLATION immediately:**
   ```
   ## Protocol Violation
   Expected: <format name from this document>
   Missing: <list of missing fields>
   Cannot proceed until: <exact fields required>
   ```
3. Orchestrator re-sends correct payload.

---

## § Message Integrity Rules

- **Never paraphrase** error messages, stack traces, or test output. Pass verbatim.
- **Never truncate** long outputs with "..." or "[...abbreviated...]". Pass complete text.
- **Never merge** two agent outputs into one handoff message. Each handoff from one specific agent.
- **Always include** task number and acceptance criterion in every handoff. Agents never infer what task they are on.
- **Always include** Orchestrator contract when dispatching Coder, even on fix cycles.
