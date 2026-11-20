# Transition Runner User & Author Guide

The transition runner is the transactional state-machine engine for the `workflow-executor` skill. It provides authoritative persistence in SQLite, structured outcome-based state transitions, optimistic concurrency controls, explicit user-facing approval gates, loop thrash protection, and automatic Markdown journal generation.

---

## 1. Overview & Key Concepts

Historically, workflows tracked state through natural-language heuristics in chat and append-only Markdown logs. The transition runner establishes a formal system of record:

- **Authoritative System of Record**: All run metadata, state visits, transitions, child invocations, loop counters, and approval records live in a local SQLite database (`.workflow/state.db`) using WAL mode and strict foreign keys.
- **One-Way Journal Projection**: Markdown journals (`.workflow/runs/<workflow>/<task>/workflow-log.md`) are automatically rendered and synchronized from SQLite records. Markdown is never parsed to infer or reconstruct state.
- **Strict Separation of Powers**: Agents execute work inside states and submit structured outcome IDs with an expected revision counter. Users retain sole approval authority over gates through explicit TUI dialogs (`ctx.ui.confirm`). Agents cannot bypass or self-approve gates.
- **Safe Resumption**: Resuming an interrupted session reloads the exact committed state, checks definition fingerprints, and halts if unconfirmed external actions require user reconciliation.

---

## 2. User Workflow (Starting & Resuming Runs)

Users control workflows through the `/workflow` slash command in Pi.

### Starting a New Run
```text
/workflow <name> [task-slug] [instructions]
```
- `<name>`: The name of one of the 8 shipped workflows (e.g., `interactive-planning`, `task-implementation`, `bug-fix`).
- `[task-slug]`: Optional kebab-case identifier for the task (e.g. `add-auth-tokens`). Defaults to `main` if omitted.
- `[instructions]`: Optional instructions passed directly to the initial turn of the agent.

**Example**:
```text
/workflow interactive-planning user-pagination "Design pagination with cursor support"
```

### Resuming an Interrupted Run
You can resume runs explicitly or through the interactive selector:

#### 1. Interactive Selector (`/workflow` with no args or `/workflow list`)
Running `/workflow` with no arguments (or `/workflow list`) opens an interactive TUI selector:
```text
Select a workflow run to inspect or resume:
- [PAUSED] interactive-planning (user-pagination) - state: explore_approaches, rev: 4 - waiting for approval
- [ACTIVE] task-implementation (auth-token) - state: verify, rev: 3
- [COMPLETED] merge-review (against) - state: done, rev: 6
- [ABORTED] debug (login-bug) - state: abort, rev: 2
```
Selecting any **active** or **paused** run immediately resumes it, reloads the database state, checks definition fingerprints, and prompts the agent to continue. Selecting a completed/aborted run displays its terminal status and journal path.

#### 2. Direct Resume Command
```text
/workflow <name> <task-slug>
```
When resumed:
1. The runner matches `runId` (`<name>-<task-slug>`) in `.workflow/state.db`.
2. Verifies that the workflow YAML definition has not changed (sha256 fingerprint check). If the definition was modified, resume halts with a mismatch error.
3. Checks for any unresolved two-phase external actions (e.g. interrupted git pushes).
4. Synchronizes the Markdown journal and announces the current state and revision.

### Responding to Approval Gates
When an agent reaches an approval-gated transition (e.g., plan approval, spec confirmation, or deployment):
1. The agent calls the transition tool with the outcome ID.
2. The runner enters `pending_approval` status and binds an approval record to the active state visit and current revision.
3. Pi displays an interactive selection dialog to the user via `ctx.ui.select`:
   ```text
   Workflow 'interactive-planning' (user-pagination) requires approval to transition to 'task_breakdown'.
   Reason: plan approved; break it into worker-ready tasks

   1. Approve transition to 'task_breakdown'
   2. Reject transition
   3. Chat about it (ask question or discuss)
   ```
4. **Outcomes**:
   - **Approve**: The transition commits, revision increments, and the workflow advances to the next state.
   - **Reject**: The pending approval is recorded as rejected and the run remains paused in the current state.
   - **Chat about it**: Pi opens a text input dialog (`ctx.ui.input`) where the user enters a question or prompt for the agent. The agent answers the question in chat and immediately re-invokes `workflow_transition`, presenting the 3-option dialog again with the latest context. This loop can repeat as many times as desired until the user chooses to approve or reject. Stale approvals from prior visits or revisions cannot be reused.

---

## 3. Agent Workflow (Submitting Transitions)

Agents working inside a workflow communicate state advancements through the registered `workflow_transition` tool.

### Tool Call Parameters
- `runId` (string, required): The active workflow run ID (provided in the initial agent prompt).
- `outcomeId` (string, required): The outcome identifier declared in the YAML transitions of the current state.
- `expectedRevision` (integer, required): The revision number the agent expects to advance from.
- `evidence` (array of strings, optional): File paths, command outputs, or test results supporting the transition.

### Tool Call Example
```json
{
  "runId": "task-implementation-transition-runner",
  "outcomeId": "verified",
  "expectedRevision": 3,
  "evidence": ["skills/workflow-executor/runner/test/scenarios.test.ts", "41 passing tests"]
}
```

### Tool Responses
- **Advanced**:
  ```text
  Workflow transitioned: status=advanced, state=report, revision=4
  ```
- **Terminal State**:
  ```text
  Workflow transitioned: status=terminal, state=done, revision=5
  ```
- **Gate Approved**:
  ```text
  Gate approved by user. Advanced to state 'task_breakdown' [revision 4].
  ```
- **Gate Rejected**:
  ```text
  Gate transition to 'task_breakdown' was REJECTED by user. Run paused at 'write_plan'.
  ```
- **Unknown Outcome**:
  The run immediately transitions to `paused` without altering state or corrupting revision numbers:
  ```text
  Workflow transitioned: status=paused, state=write_plan, revision=3
  ```
- **Revision Conflict**:
  If another process or turn updated the run in the meantime, the tool rejects the call:
  ```text
  Transition error: Revision conflict: expected 2, found 3
  ```

---

## 4. Authoring Workflows with Structured Outcomes

Workflow definitions live under `skills/workflow-executor/workflows/<name>/<name>.yaml`.

### Anatomy of a State Definition
```yaml
states:
  assess:
    goal: "Judge the change against the criteria from scope."
    subagent: reviewer  # Indicates work should be handed over to the 'reviewer' subagent
    produces: [findings]
    exit_gate: "Every issue found is recorded as an actionable finding."
    transitions:
      - outcome: assessed
        when: "exit_gate holds"
        to: triage
        reason: "assessment complete; findings recorded"

  write_plan:
    goal: "Author the implementation plan artifact."
    produces: [plan]
    exit_gate: "The plan artifact is written and confirmed."
    transitions:
      # Approval-gated forward transition
      - outcome: plan_approved
        when: "exit_gate holds"
        to: task_breakdown
        reason: "plan approved; break it into worker-ready tasks"
        requires_approval: true

      # Refinement loop with thrash bounding
      - outcome: design_gap_found
        when: "Writing the plan exposed an unresolved design gap."
        to: validate_design
        reason: "refinement: writing the plan exposed a design gap"
        max_retries: 2
```

### Fields in States:
- `goal` (string, optional): Prose explanation of what the state achieves.
- `consumes` / `produces` (string[], optional): Declared artifact dependencies.
- `exit_gate` (string, optional): Qualitative predicate that must hold before advancing.
- `subagent` (string | object, optional): Declares that the state should be handed over to a named subagent (e.g. `reviewer`, `worker`, `scout`). The orchestrator dispatches the subagent to perform the state's work, inspects the delivered artifacts, and executes the transition.
- `terminal` (boolean, optional): If `true`, marks the end of the run (`completed`/`aborted`).
- `invoke` (object, optional): Runs a child workflow as a sub-routine.
- `transitions` (object[], required for non-terminal): Ordered list of possible state transitions.

### Fields in Transitions:
- `outcome` (string, required): Unique identifier for this transition branch.
- `when` (string, optional): Prose rule and predicate explaining when the outcome is valid.
- `to` (string, required): Target state ID (must exist in definition).
- `reason` (string, optional): One-line explanation recorded in audit logs and user prompts.
- `requires_approval` (boolean, optional): If `true`, prompts user via `ctx.ui.confirm` before advancing.
- `max_retries` (integer, optional): Maximum consecutive backward loops before the thrash guard pauses the run for user intervention.

### Child Workflow Invocations
A state can invoke another workflow as a sub-routine:
```yaml
  debug:
    invoke:
      workflow: debug
      inputs:
        require_openspec: true
    goal: "Run the debug sub-workflow to isolate root cause."
    transitions:
      - outcome: debug_completed
        when: "exit_gate holds"
        to: plan
        reason: "root cause proven"
      - outcome: debug_aborted
        when: "The child ended in abort."
        to: abort
        reason: "debug aborted; nothing to plan"
```
- Re-entries into child workflows carry an `entry` override (e.g. `entry: diagnose`). The runner applies the override once per child invocation; upon resumption from interruption, the child continues from its last committed state.

---

## 5. Two-Phase External Action Reconciliation

Any workflow operation with remote side effects (such as creating a PR, pushing commits, or triggering CI) must record intent prior to execution:

1. **Record Intent**:
   ```typescript
   const actionId = recordActionIntent(db, runId, "git_push", { branch: "feat/my-branch" });
   ```
2. **Execute External Side-Effect**:
   ```bash
   git push origin feat/my-branch
   ```
3. **Record Confirmation**:
   ```typescript
   recordActionConfirmed(db, actionId, { remoteSha: "abc1234" });
   ```

If the process terminates between step 1 and step 3, resuming the run detects the unconfirmed action and halts with a prompt for explicit user reconciliation rather than automatically re-running the command.

---

## 6. Architecture & File Layout

```text
dot_pi/agent/extensions/workflow-executor/
├── index.ts              # Extension entry point: registers /workflow, /workflows, tools
├── README.md             # Technical guide, schema specification, and architecture
├── runner/               # Decoupled state-machine engine
│   ├── index.ts          # Central facade exporting all runner primitives
│   ├── types.ts          # Data contracts and schema interfaces
│   ├── validator.ts      # Sha256 fingerprinting and structural graph validation
│   ├── db.ts             # SQLite schema, WAL configuration, and atomic transactions
│   ├── engine.ts         # State machine engine, revision verification, approvals
│   ├── invocations.ts    # Loop thrash guards and child invocation tracking
│   ├── actions.ts        # Two-phase external action intent/confirmation
│   └── journal.ts        # Markdown projection generator
└── test/                 # Automated test suite (node --test)
    ├── helpers.ts        # Dynamic module resolver and test utilities
    ├── smoke-pi-runtime.ts # Zero-dependency environment verification
    ├── validator.test.ts # Graph validation unit tests
    ├── db.test.ts        # SQLite transactional and concurrency tests
    ├── engine.test.ts    # Engine and approval gate unit tests
    ├── invocations.test.ts # Thrash limit and child invocation tests
    ├── actions.test.ts   # Two-phase external action tests
    ├── journal.test.ts   # Markdown projection tests
    ├── workflows.test.ts # Validation of all 8 shipped workflow YAMLs
    ├── extension.test.ts # Pi extension adapter tests
    ├── runner.test.ts    # Comprehensive test suite covering ISC 1-11
    └── scenarios.test.ts # End-to-end simulated execution of all 8 workflows
```

---

## 7. Verification

To run the complete automated test suite (47 tests, 100% pass rate):
```bash
node --test dot_pi/agent/extensions/workflow-executor/test/*.test.ts
```
